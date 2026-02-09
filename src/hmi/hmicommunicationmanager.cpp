#include "hmicommunicationmanager.h"
#include "../communication/hymodbustcpdriver.h"
#include "../datasource/opcuadatasource.h"
#include "../core/tagmanager.h"

HMICommunicationManager::HMICommunicationManager(QObject *parent) : QObject(parent)
{
    m_modbusDriver = nullptr;
    m_opcuaDataSource = nullptr;
    m_protocol = ModbusTCP;
    m_updateInterval = 200; // 默认200ms更新间隔
    m_connected = false;

    initializeDrivers();

    // 创建同步定时器
    m_syncTimer = new QTimer(this);
    m_syncTimer->setInterval(m_updateInterval);
    connect(m_syncTimer, &QTimer::timeout, this, &HMICommunicationManager::syncData);
}

HMICommunicationManager::~HMICommunicationManager()
{
    cleanupDrivers();
    if (m_syncTimer) {
        delete m_syncTimer;
    }
}

void HMICommunicationManager::initializeDrivers()
{
    // 初始化Modbus TCP驱动
    m_modbusDriver = new HYModbusTcpDriver(this);
    
    // 初始化OPC UA数据源
    // 注意：需要HYTagManager实例，这里暂时使用nullptr
    m_opcuaDataSource = new OpcUaDataSource(nullptr, this);
    
    // 连接信号
    connect(m_opcuaDataSource, &OpcUaDataSource::dataUpdated, this, &HMICommunicationManager::onDataUpdated);
}

void HMICommunicationManager::cleanupDrivers()
{
    if (m_modbusDriver) {
        delete m_modbusDriver;
        m_modbusDriver = nullptr;
    }
    
    if (m_opcuaDataSource) {
        delete m_opcuaDataSource;
        m_opcuaDataSource = nullptr;
    }
}

bool HMICommunicationManager::connect(const QString &url, const QString &username, const QString &password)
{
    m_url = url;
    m_username = username;
    m_password = password;

    bool success = false;

    switch (m_protocol) {
    case ModbusTCP:
        if (m_modbusDriver) {
            // 解析Modbus URL格式: modbus://ip:port/slaveId
            QUrl modbusUrl(url);
            QString host = modbusUrl.host();
            int port = modbusUrl.port(502);
            int slaveId = modbusUrl.path().mid(1).toInt();
            if (slaveId == 0) slaveId = 1;

            success = m_modbusDriver->connectToDevice(host, port, slaveId);
        }
        break;
    
    case OPCUA:
        if (m_opcuaDataSource) {
            success = m_opcuaDataSource->connectToServer(url, username, password);
        }
        break;
    }

    m_connected = success;
    emit connectionStatusChanged(success);

    if (success) {
        m_syncTimer->start();
    }

    return success;
}

void HMICommunicationManager::disconnect()
{
    switch (m_protocol) {
    case ModbusTCP:
        if (m_modbusDriver) {
            m_modbusDriver->disconnectFromDevice();
        }
        break;
    
    case OPCUA:
        if (m_opcuaDataSource) {
            m_opcuaDataSource->disconnectFromServer();
        }
        break;
    }

    m_connected = false;
    emit connectionStatusChanged(false);
    m_syncTimer->stop();
}

bool HMICommunicationManager::isConnected() const
{
    return m_connected;
}

bool HMICommunicationManager::bindPoint(const QString &tagName, const QString &deviceAddress, int dataType)
{
    QMutexLocker locker(&m_mutex);

    PointBinding binding;
    binding.deviceAddress = deviceAddress;
    binding.dataType = dataType;
    binding.lastValue = QVariant();
    binding.updateCount = 0;

    m_pointBindings[tagName] = binding;
    return true;
}

bool HMICommunicationManager::unbindPoint(const QString &tagName)
{
    QMutexLocker locker(&m_mutex);

    if (m_pointBindings.contains(tagName)) {
        m_pointBindings.remove(tagName);
        return true;
    }
    return false;
}

bool HMICommunicationManager::isPointBound(const QString &tagName) const
{
    QMutexLocker locker(&m_mutex);
    return m_pointBindings.contains(tagName);
}

QVariant HMICommunicationManager::readPoint(const QString &tagName)
{
    QMutexLocker locker(&m_mutex);

    if (m_pointBindings.contains(tagName)) {
        return m_pointBindings[tagName].lastValue;
    }
    return QVariant();
}

bool HMICommunicationManager::writePoint(const QString &tagName, const QVariant &value)
{
    QMutexLocker locker(&m_mutex);

    if (!m_pointBindings.contains(tagName)) {
        return false;
    }

    PointBinding &binding = m_pointBindings[tagName];

    switch (m_protocol) {
    case ModbusTCP:
        if (m_modbusDriver && m_connected) {
            // 解析设备地址格式: registerType:address
            QStringList parts = binding.deviceAddress.split(":");
            if (parts.size() == 2) {
                QString registerType = parts[0];
                int address = parts[1].toInt();

                if (registerType == "coil") {
                    return m_modbusDriver->writeCoil(address, value.toBool());
                } else if (registerType == "holding") {
                    return m_modbusDriver->writeHoldingRegister(address, value.toUInt());
                }
            }
        }
        break;
    
    case OPCUA:
        if (m_opcuaDataSource && m_connected) {
            return m_opcuaDataSource->writeNodeValue(binding.deviceAddress, value);
        }
        break;
    }

    return false;
}

void HMICommunicationManager::updatePoint(const QString &tagName, const QVariant &value)
{
    QMutexLocker locker(&m_mutex);

    if (m_pointBindings.contains(tagName)) {
        PointBinding &binding = m_pointBindings[tagName];
        binding.lastValue = value;
        binding.updateCount++;

        emit pointUpdated(tagName, value);
    }
}

QString HMICommunicationManager::protocol() const
{
    return m_protocol == ModbusTCP ? "ModbusTCP" : "OPCUA";
}

void HMICommunicationManager::setProtocol(const QString &protocol)
{
    if (protocol == "ModbusTCP") {
        m_protocol = ModbusTCP;
    } else if (protocol == "OPCUA") {
        m_protocol = OPCUA;
    }
    emit protocolChanged();
}

void HMICommunicationManager::setUpdateInterval(int interval)
{
    m_updateInterval = interval;
    m_syncTimer->setInterval(interval);
}

int HMICommunicationManager::updateInterval() const
{
    return m_updateInterval;
}

void HMICommunicationManager::onDataUpdated(const QString &tagName, const QVariant &value)
{
    updatePoint(tagName, value);
}

void HMICommunicationManager::onConnectionStateChanged(bool connected)
{
    m_connected = connected;
    emit connectionStatusChanged(connected);
}

void HMICommunicationManager::syncData()
{
    if (!m_connected) {
        return;
    }

    QMutexLocker locker(&m_mutex);

    switch (m_protocol) {
    case ModbusTCP:
        syncModbusData();
        break;
    
    case OPCUA:
        syncOpcUaData();
        break;
    }
}

void HMICommunicationManager::syncModbusData()
{
    if (!m_modbusDriver || !m_connected) {
        return;
    }

    for (auto it = m_pointBindings.begin(); it != m_pointBindings.end(); ++it) {
        const QString &tagName = it.key();
        PointBinding &binding = it.value();

        // 解析设备地址格式: registerType:address
        QStringList parts = binding.deviceAddress.split(":");
        if (parts.size() == 2) {
            QString registerType = parts[0];
            int address = parts[1].toInt();

            if (registerType == "coil") {
                bool value;
                if (m_modbusDriver->readCoil(address, value)) {
                    if (binding.lastValue != value) {
                        binding.lastValue = value;
                        emit pointUpdated(tagName, value);
                    }
                }
            } else if (registerType == "holding") {
                quint16 value;
                if (m_modbusDriver->readHoldingRegister(address, value)) {
                    if (binding.lastValue != value) {
                        binding.lastValue = value;
                        emit pointUpdated(tagName, value);
                    }
                }
            }
        }
    }
}

void HMICommunicationManager::syncOpcUaData()
{
    if (!m_opcuaDataSource || !m_connected) {
        return;
    }

    for (auto it = m_pointBindings.begin(); it != m_pointBindings.end(); ++it) {
        const QString &tagName = it.key();
        PointBinding &binding = it.value();

        QVariant value = m_opcuaDataSource->readNodeValue(binding.deviceAddress);
        if (value.isValid() && binding.lastValue != value) {
            binding.lastValue = value;
            emit pointUpdated(tagName, value);
        }
    }
}
