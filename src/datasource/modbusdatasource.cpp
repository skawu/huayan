#include "modbusdatasource.h"
#include <QThread>
#include <QCoreApplication>

/**
 * @file modbusdatasource.cpp
 * @brief Modbus数据源实现
 * 
 * 实现了ModbusDataSource类的核心功能，包括Modbus TCP服务器的连接、读写和数据同步
 * 支持与Huayan点位管理系统的绑定，确保数据的实时更新
 */

ModbusDataSource::ModbusDataSource(HYTagManager *tagManager, QObject *parent) 
    : DataSource(tagManager, parent),
      m_client(nullptr),
      m_syncTimer(new QTimer(this)),
      m_slaveId(1),
      m_port(502)
{
    // 初始化同步定时器
    m_syncTimer->setInterval(100); // 默认100ms同步一次
    QObject::connect(m_syncTimer, &QTimer::timeout, this, &ModbusDataSource::syncData);
}

ModbusDataSource::~ModbusDataSource()
{
    disconnectFromServer();
    delete m_syncTimer;
}

bool ModbusDataSource::connectToServer(const QString &host, quint16 port, quint8 slaveId)
{
    QMutexLocker locker(&m_mutex);

    // 断开现有连接
    if (m_client) {
        delete m_client;
        m_client = nullptr;
    }

    // 创建Modbus TCP客户端
    m_client = new QModbusTcpClient(this);
    m_slaveId = slaveId;
    
    // 连接信号槽
    QObject::connect(m_client, &QModbusDevice::stateChanged, this, &ModbusDataSource::onConnectionStateChanged);

    // 设置连接参数
    m_client->setConnectionParameter(QModbusDevice::NetworkPortParameter, port);
    m_client->setConnectionParameter(QModbusDevice::NetworkAddressParameter, host);

    // 连接到服务器
    m_client->connectDevice();

    // 等待连接完成（最多5秒）
    int timeout = 5000;
    int interval = 100;
    int elapsed = 0;
    while (m_client->state() != QModbusDevice::State::ConnectedState && elapsed < timeout) {
        QThread::msleep(interval);
        QCoreApplication::processEvents();
        elapsed += interval;
    }

    if (m_client->state() == QModbusDevice::State::ConnectedState) {
        // 启动同步定时器
        m_syncTimer->start();
        return true;
    }

    return false;
}

void ModbusDataSource::disconnectFromServer()
{
    disconnect();
}

void ModbusDataSource::disconnect()
{
    QMutexLocker locker(&m_mutex);

    // 停止同步定时器
    m_syncTimer->stop();

    // 断开连接
    if (m_client) {
        m_client->disconnectDevice();
        delete m_client;
        m_client = nullptr;
    }

    // 清空寄存器绑定
    m_registerBindings.clear();

    emit connectionStatusChanged(false);
}

bool ModbusDataSource::connect(const QMap<QString, QVariant> &parameters)
{
    QString host = parameters.value("host").toString();
    quint16 port = parameters.value("port", 502).toUInt();
    quint8 slaveId = parameters.value("slaveId", 1).toUInt();
    
    return connectToServer(host, port, slaveId);
}

QString ModbusDataSource::type() const
{
    return "modbus";
}

QString ModbusDataSource::name() const
{
    return "Modbus TCP";
}

bool ModbusDataSource::parseAddress(const QString &address, QModbusDataUnit::RegisterType &registerType, quint16 &regAddress) const
{
    // 地址格式: "coil:100", "input:200", "holding:300", "discrete:400"
    QStringList parts = address.split(":");
    if (parts.size() != 2) {
        return false;
    }
    
    QString typeStr = parts[0].toLower();
    bool ok;
    regAddress = parts[1].toUInt(&ok);
    if (!ok) {
        return false;
    }
    
    if (typeStr == "coil") {
        registerType = QModbusDataUnit::Coils;
    } else if (typeStr == "input") {
        registerType = QModbusDataUnit::InputRegisters;
    } else if (typeStr == "holding") {
        registerType = QModbusDataUnit::HoldingRegisters;
    } else if (typeStr == "discrete") {
        registerType = QModbusDataUnit::DiscreteInputs;
    } else {
        return false;
    }
    
    return true;
}

QString ModbusDataSource::createAddressString(QModbusDataUnit::RegisterType registerType, quint16 address) const
{
    QString typeStr;
    switch (registerType) {
    case QModbusDataUnit::Coils:
        typeStr = "coil";
        break;
    case QModbusDataUnit::InputRegisters:
        typeStr = "input";
        break;
    case QModbusDataUnit::HoldingRegisters:
        typeStr = "holding";
        break;
    case QModbusDataUnit::DiscreteInputs:
        typeStr = "discrete";
        break;
    default:
        typeStr = "unknown";
        break;
    }
    return typeStr + ":" + QString::number(address);
}

bool ModbusDataSource::bindAddressToTag(const QString &address, const QString &tagName, int samplingInterval)
{
    QModbusDataUnit::RegisterType registerType;
    quint16 regAddress;
    
    if (!parseAddress(address, registerType, regAddress)) {
        return false;
    }
    
    return bindRegisterToTag(registerType, regAddress, tagName, samplingInterval);
}

bool ModbusDataSource::unbindAddressFromTag(const QString &address)
{
    QModbusDataUnit::RegisterType registerType;
    quint16 regAddress;
    
    if (!parseAddress(address, registerType, regAddress)) {
        return false;
    }
    
    return unbindRegisterFromTag(registerType, regAddress);
}

QVariant ModbusDataSource::readData(const QString &address)
{
    QModbusDataUnit::RegisterType registerType;
    quint16 regAddress;
    
    if (!parseAddress(address, registerType, regAddress)) {
        return QVariant();
    }
    
    if (registerType == QModbusDataUnit::Coils || registerType == QModbusDataUnit::DiscreteInputs) {
        if (registerType == QModbusDataUnit::Coils) {
            return readCoil(regAddress);
        } else {
            QVector<quint16> values = readRegisters(registerType, regAddress, 1);
            return !values.isEmpty() && values[0] != 0;
        }
    } else {
        QVector<quint16> values = readRegisters(registerType, regAddress, 1);
        if (values.isEmpty()) {
            return QVariant();
        }
        return values[0];
    }
}

bool ModbusDataSource::writeData(const QString &address, const QVariant &value)
{
    QModbusDataUnit::RegisterType registerType;
    quint16 regAddress;
    
    if (!parseAddress(address, registerType, regAddress)) {
        return false;
    }
    
    if (registerType == QModbusDataUnit::Coils) {
        return writeCoil(regAddress, value.toBool());
    } else if (registerType == QModbusDataUnit::HoldingRegisters) {
        QVector<quint16> values = {static_cast<quint16>(value.toUInt())};
        return writeRegisters(registerType, regAddress, values);
    } else {
        // InputRegisters和DiscreteInputs是只读的
        return false;
    }
}

bool ModbusDataSource::isConnected() const
{
    return m_client && m_client->state() == QModbusDevice::State::ConnectedState;
}

bool ModbusDataSource::bindRegisterToTag(QModbusDataUnit::RegisterType registerType, quint16 address, 
                                         const QString &tagName, int samplingInterval)
{
    QMutexLocker locker(&m_mutex);

    if (!m_client || m_client->state() != QModbusDevice::State::ConnectedState) {
        return false;
    }

    // 检查点位是否存在
    if (!m_tagManager->getTag(tagName)) {
        // 点位不存在，创建新点位
        if (!m_tagManager->addTag(tagName, "Modbus", 0, "Modbus tag", "Modbus")) {
            return false;
        }
    }

    // 添加到绑定映射
    QPair<QModbusDataUnit::RegisterType, quint16> key(registerType, address);
    RegisterBinding binding;
    binding.tagName = tagName;
    binding.samplingInterval = samplingInterval;
    m_registerBindings[key] = binding;

    return true;
}

bool ModbusDataSource::unbindRegisterFromTag(QModbusDataUnit::RegisterType registerType, quint16 address)
{
    QMutexLocker locker(&m_mutex);

    QPair<QModbusDataUnit::RegisterType, quint16> key(registerType, address);
    if (!m_registerBindings.contains(key)) {
        return false;
    }

    // 从映射中移除
    m_registerBindings.remove(key);

    return true;
}

QVector<quint16> ModbusDataSource::readRegisters(QModbusDataUnit::RegisterType registerType, quint16 address, quint16 count)
{
    QMutexLocker locker(&m_mutex);

    if (!m_client || m_client->state() != QModbusDevice::State::ConnectedState) {
        return QVector<quint16>();
    }

    // 创建数据单元
    QModbusDataUnit dataUnit(registerType, address, count);
    
    // 发送读取请求
    QModbusReply *reply = m_client->sendReadRequest(dataUnit, m_slaveId);
    if (!reply) {
        return QVector<quint16>();
    }

    // Use a local event loop to wait for the reply
    QEventLoop loop;
    QObject::connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    
    // Wait for the reply with a timeout
    QTimer timer;
    timer.setSingleShot(true);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    timer.start(1000);
    
    loop.exec();
    
    // Check if the reply is finished
    QVector<quint16> values;
    if (reply->error() == QModbusDevice::NoError) {
        const QModbusDataUnit unit = reply->result();
        for (int i = 0; i < unit.valueCount(); ++i) {
            values.append(unit.value(i));
        }
    }

    delete reply;
    return values;
}

bool ModbusDataSource::writeRegisters(QModbusDataUnit::RegisterType registerType, quint16 address, const QVector<quint16> &values)
{
    QMutexLocker locker(&m_mutex);

    if (!m_client || m_client->state() != QModbusDevice::State::ConnectedState) {
        return false;
    }

    // 创建数据单元
    QModbusDataUnit dataUnit(registerType, address, values.size());
    for (int i = 0; i < values.size(); ++i) {
        dataUnit.setValue(i, values[i]);
    }
    
    // 发送写入请求
    QModbusReply *reply = m_client->sendWriteRequest(dataUnit, m_slaveId);
    if (!reply) {
        return false;
    }

    // Use a local event loop to wait for the reply
    QEventLoop loop;
    QObject::connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    
    // Wait for the reply with a timeout
    QTimer timer;
    timer.setSingleShot(true);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    timer.start(1000);
    
    loop.exec();
    
    // Check if the reply is finished
    bool success = (reply->error() == QModbusDevice::NoError);
    delete reply;
    return success;
}

bool ModbusDataSource::readCoil(quint16 address)
{
    QVector<quint16> values = readRegisters(QModbusDataUnit::Coils, address, 1);
    return !values.isEmpty() && values[0] != 0;
}

bool ModbusDataSource::writeCoil(quint16 address, bool value)
{
    QVector<quint16> values = {static_cast<quint16>(value ? 0xFF00 : 0x0000)};
    return writeRegisters(QModbusDataUnit::Coils, address, values);
}

QList<bool> ModbusDataSource::readMultipleCoils(quint16 address, quint16 count)
{
    QVector<quint16> values = readRegisters(QModbusDataUnit::Coils, address, count);
    QList<bool> result;
    
    for (quint16 value : values) {
        result.append(value != 0);
    }
    
    return result;
}

void ModbusDataSource::onConnectionStateChanged(QModbusDevice::State state)
{
    bool connected = (state == QModbusDevice::State::ConnectedState);
    emit connectionStatusChanged(connected);

    if (connected) {
        m_syncTimer->start();
    } else {
        m_syncTimer->stop();
    }
}

void ModbusDataSource::onReadFinished(QModbusReply *reply)
{
    if (!reply) {
        return;
    }

    if (reply->error() == QModbusDevice::NoError) {
        const QModbusDataUnit unit = reply->result();
        QModbusDataUnit::RegisterType registerType = unit.registerType();
        quint16 address = unit.startAddress();
        
        // 检查是否有绑定
        QPair<QModbusDataUnit::RegisterType, quint16> key(registerType, address);
        if (m_registerBindings.contains(key)) {
            const RegisterBinding &binding = m_registerBindings[key];
            
            // 获取值
            QVariant value;
            if (registerType == QModbusDataUnit::Coils) {
                value = (unit.value(0) != 0);
            } else {
                value = unit.value(0);
            }
            
            // 更新Huayan点位值
            m_tagManager->setTagValue(binding.tagName, value);
            
            // 发出数据更新信号
            emit dataUpdated(binding.tagName, value);
        }
    }

    delete reply;
}

void ModbusDataSource::syncData()
{
    QMutexLocker locker(&m_mutex);

    if (!m_client || m_client->state() != QModbusDevice::State::ConnectedState) {
        return;
    }

    // 同步所有绑定的寄存器数据
    for (const auto &key : m_registerBindings.keys()) {
        QModbusDataUnit::RegisterType registerType = key.first;
        quint16 address = key.second;
        
        // 创建数据单元
        QModbusDataUnit dataUnit(registerType, address, 1);
        
        // 发送读取请求
        QModbusReply *reply = m_client->sendReadRequest(dataUnit, m_slaveId);
        if (reply) {
            QObject::connect(reply, &QModbusReply::finished, this, [this, reply]() {
                onReadFinished(reply);
            });
        }
    }
}
