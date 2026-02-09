#include "hymodbustcpdriver.h"
#include <QCoreApplication>
using namespace std;

HYModbusTcpDriver::HYModbusTcpDriver(QObject *parent) : QObject(parent)
{
    m_hyModbusClient = new QModbusTcpClient(this);
    m_hyReconnectTimer = new QTimer(this);
    m_hyReconnectInterval = 5000; // 5 seconds default
    m_hyResponseTimeout = 1000;  // 1 second default
    m_hyAutoReconnect = true;
    m_hySlaveId = 1;

    // Connect signals and slots
    connect(m_hyModbusClient, &QModbusClient::stateChanged, this, &HYModbusTcpDriver::onStateChanged);
    connect(m_hyModbusClient, &QModbusClient::errorOccurred, this, &HYModbusTcpDriver::onErrorOccurred);
    connect(m_hyReconnectTimer, &QTimer::timeout, this, &HYModbusTcpDriver::attemptReconnect);

    // Set default timeout
    m_hyModbusClient->setTimeout(m_hyResponseTimeout);
    m_hyModbusClient->setNumberOfRetries(3);
}

HYModbusTcpDriver::~HYModbusTcpDriver()
{
    disconnectFromDevice();
    delete m_hyModbusClient;
    delete m_hyReconnectTimer;
}

bool HYModbusTcpDriver::connectToDevice(const QString &host, int port, int slaveId)
{
    m_hyIpAddress = host;
    m_hyPort = port;
    m_hySlaveId = slaveId;

    // Disconnect if already connected
    if (m_hyModbusClient->state() == QModbusDevice::ConnectedState) {
        m_hyModbusClient->disconnectDevice();
    }

    // Set connection parameters
    m_hyModbusClient->setConnectionParameter(QModbusDevice::NetworkAddressParameter, m_hyIpAddress);
    m_hyModbusClient->setConnectionParameter(QModbusDevice::NetworkPortParameter, m_hyPort);

    // Connect
    bool success = m_hyModbusClient->connectDevice();
    if (!success) {
        emit connectionError(tr("Failed to connect to %1:%2").arg(m_hyIpAddress).arg(m_hyPort));
        if (m_hyAutoReconnect) {
            m_hyReconnectTimer->start(m_hyReconnectInterval);
        }
    }

    return success;
}

void HYModbusTcpDriver::disconnectFromDevice()
{
    m_hyReconnectTimer->stop();
    if (m_hyModbusClient->state() == QModbusDevice::ConnectedState) {
        m_hyModbusClient->disconnectDevice();
    }
}

bool HYModbusTcpDriver::isConnected() const
{
    return m_hyModbusClient->state() == QModbusDevice::ConnectedState;
}

bool HYModbusTcpDriver::readCoil(int address, bool &value)
{
    if (!isConnected()) {
        emit dataReadError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::Coils, address, 1);
    auto *reply = m_hyModbusClient->sendReadRequest(unit, m_hySlaveId);
    if (!reply) {
        emit dataReadError(tr("Failed to send read request: %1").arg(m_hyModbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_hyResponseTimeout);
    loop.exec();

    if (timer.isActive()) {
        timer.stop();
        if (reply->error() != QModbusDevice::NoError) {
            emit dataReadError(tr("Read error: %1").arg(reply->errorString()));
            reply->deleteLater();
            return false;
        }

        const QModbusDataUnit result = reply->result();
        if (result.valueCount() > 0) {
            value = result.value(0) != 0;
            reply->deleteLater();
            return true;
        }

        emit dataReadError(tr("No data returned"));
        reply->deleteLater();
        return false;
    } else {
        emit dataReadError(tr("Read request timed out"));
        reply->deleteLater();
        return false;
    }
}

bool HYModbusTcpDriver::readDiscreteInput(int address, bool &value)
{
    if (!isConnected()) {
        emit dataReadError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::DiscreteInputs, address, 1);
    auto *reply = m_hyModbusClient->sendReadRequest(unit, m_hySlaveId);
    if (!reply) {
        emit dataReadError(tr("Failed to send read request: %1").arg(m_hyModbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_hyResponseTimeout);
    loop.exec();

    if (timer.isActive()) {
        timer.stop();
        if (reply->error() != QModbusDevice::NoError) {
            emit dataReadError(tr("Read error: %1").arg(reply->errorString()));
            reply->deleteLater();
            return false;
        }

        const QModbusDataUnit result = reply->result();
        if (result.valueCount() > 0) {
            value = result.value(0) != 0;
            reply->deleteLater();
            return true;
        }

        emit dataReadError(tr("No data returned"));
        reply->deleteLater();
        return false;
    } else {
        emit dataReadError(tr("Read request timed out"));
        reply->deleteLater();
        return false;
    }
}

bool HYModbusTcpDriver::readHoldingRegister(int address, quint16 &value)
{
    if (!isConnected()) {
        emit dataReadError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::HoldingRegisters, address, 1);
    auto *reply = m_hyModbusClient->sendReadRequest(unit, m_hySlaveId);
    if (!reply) {
        emit dataReadError(tr("Failed to send read request: %1").arg(m_hyModbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_hyResponseTimeout);
    loop.exec();

    if (timer.isActive()) {
        timer.stop();
        if (reply->error() != QModbusDevice::NoError) {
            emit dataReadError(tr("Read error: %1").arg(reply->errorString()));
            reply->deleteLater();
            return false;
        }

        const QModbusDataUnit result = reply->result();
        if (result.valueCount() > 0) {
            value = result.value(0);
            reply->deleteLater();
            return true;
        }

        emit dataReadError(tr("No data returned"));
        reply->deleteLater();
        return false;
    } else {
        emit dataReadError(tr("Read request timed out"));
        reply->deleteLater();
        return false;
    }
}

bool HYModbusTcpDriver::readInputRegister(int address, quint16 &value)
{
    if (!isConnected()) {
        emit dataReadError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::InputRegisters, address, 1);
    auto *reply = m_hyModbusClient->sendReadRequest(unit, m_hySlaveId);
    if (!reply) {
        emit dataReadError(tr("Failed to send read request: %1").arg(m_hyModbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_hyResponseTimeout);
    loop.exec();

    if (timer.isActive()) {
        timer.stop();
        if (reply->error() != QModbusDevice::NoError) {
            emit dataReadError(tr("Read error: %1").arg(reply->errorString()));
            reply->deleteLater();
            return false;
        }

        const QModbusDataUnit result = reply->result();
        if (result.valueCount() > 0) {
            value = result.value(0);
            reply->deleteLater();
            return true;
        }

        emit dataReadError(tr("No data returned"));
        reply->deleteLater();
        return false;
    } else {
        emit dataReadError(tr("Read request timed out"));
        reply->deleteLater();
        return false;
    }
}

bool HYModbusTcpDriver::writeCoil(int address, bool value)
{
    if (!isConnected()) {
        emit dataWriteError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::Coils, address, 1);
    unit.setValue(0, value ? 1 : 0);

    auto *reply = m_hyModbusClient->sendWriteRequest(unit, m_hySlaveId);
    if (!reply) {
        emit dataWriteError(tr("Failed to send write request: %1").arg(m_hyModbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_hyResponseTimeout);
    loop.exec();

    if (timer.isActive()) {
        timer.stop();
        if (reply->error() != QModbusDevice::NoError) {
            emit dataWriteError(tr("Write error: %1").arg(reply->errorString()));
            reply->deleteLater();
            return false;
        }

        reply->deleteLater();
        return true;
    } else {
        emit dataWriteError(tr("Write request timed out"));
        reply->deleteLater();
        return false;
    }
}

bool HYModbusTcpDriver::writeHoldingRegister(int address, quint16 value)
{
    if (!isConnected()) {
        emit dataWriteError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::HoldingRegisters, address, 1);
    unit.setValue(0, value);

    auto *reply = m_hyModbusClient->sendWriteRequest(unit, m_hySlaveId);
    if (!reply) {
        emit dataWriteError(tr("Failed to send write request: %1").arg(m_hyModbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_hyResponseTimeout);
    loop.exec();

    if (timer.isActive()) {
        timer.stop();
        if (reply->error() != QModbusDevice::NoError) {
            emit dataWriteError(tr("Write error: %1").arg(reply->errorString()));
            reply->deleteLater();
            return false;
        }

        reply->deleteLater();
        return true;
    } else {
        emit dataWriteError(tr("Write request timed out"));
        reply->deleteLater();
        return false;
    }
}

bool HYModbusTcpDriver::readCoils(int startAddress, int count, QVector<bool> &values)
{
    if (!isConnected()) {
        emit dataReadError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::Coils, startAddress, count);
    auto *reply = m_hyModbusClient->sendReadRequest(unit, m_hySlaveId);
    if (!reply) {
        emit dataReadError(tr("Failed to send read request: %1").arg(m_hyModbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_hyResponseTimeout);
    loop.exec();

    if (timer.isActive()) {
        timer.stop();
        if (reply->error() != QModbusDevice::NoError) {
            emit dataReadError(tr("Read error: %1").arg(reply->errorString()));
            reply->deleteLater();
            return false;
        }

        const QModbusDataUnit result = reply->result();
        values.clear();
        for (int i = 0; i < result.valueCount(); ++i) {
            values.append(result.value(i) != 0);
        }

        reply->deleteLater();
        return true;
    } else {
        emit dataReadError(tr("Read request timed out"));
        reply->deleteLater();
        return false;
    }
}

bool HYModbusTcpDriver::readMultipleCoils(int startAddress, int count, QList<bool> &values)
{
    // 转换QList<bool>为QVector<bool>，然后调用readCoils方法
    QVector<bool> vectorValues;
    bool result = readCoils(startAddress, count, vectorValues);
    if (result) {
        values = vectorValues.toList();
    }
    return result;
}

bool HYModbusTcpDriver::readMultipleHoldingRegisters(int startAddress, int count, QVector<quint16> &values)
{
    if (!isConnected()) {
        emit dataReadError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::HoldingRegisters, startAddress, count);
    auto *reply = m_hyModbusClient->sendReadRequest(unit, m_hySlaveId);
    if (!reply) {
        emit dataReadError(tr("Failed to send read request: %1").arg(m_hyModbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_hyResponseTimeout);
    loop.exec();

    if (timer.isActive()) {
        timer.stop();
        if (reply->error() != QModbusDevice::NoError) {
            emit dataReadError(tr("Read error: %1").arg(reply->errorString()));
            reply->deleteLater();
            return false;
        }

        const QModbusDataUnit result = reply->result();
        values.clear();
        for (int i = 0; i < result.valueCount(); ++i) {
            values.append(result.value(i));
        }

        reply->deleteLater();
        return true;
    } else {
        emit dataReadError(tr("Read request timed out"));
        reply->deleteLater();
        return false;
    }
}

bool HYModbusTcpDriver::writeMultipleCoils(int startAddress, const QVector<bool> &values)
{
    if (!isConnected()) {
        emit dataWriteError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::Coils, startAddress, values.size());
    for (int i = 0; i < values.size(); ++i) {
        unit.setValue(i, values[i] ? 1 : 0);
    }

    auto *reply = m_hyModbusClient->sendWriteRequest(unit, m_hySlaveId);
    if (!reply) {
        emit dataWriteError(tr("Failed to send write request: %1").arg(m_hyModbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_hyResponseTimeout);
    loop.exec();

    if (timer.isActive()) {
        timer.stop();
        if (reply->error() != QModbusDevice::NoError) {
            emit dataWriteError(tr("Write error: %1").arg(reply->errorString()));
            reply->deleteLater();
            return false;
        }

        reply->deleteLater();
        return true;
    } else {
        emit dataWriteError(tr("Write request timed out"));
        reply->deleteLater();
        return false;
    }
}

bool HYModbusTcpDriver::writeMultipleHoldingRegisters(int startAddress, const QVector<quint16> &values)
{
    if (!isConnected()) {
        emit dataWriteError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::HoldingRegisters, startAddress, values.size());
    for (int i = 0; i < values.size(); ++i) {
        unit.setValue(i, values[i]);
    }

    auto *reply = m_hyModbusClient->sendWriteRequest(unit, m_hySlaveId);
    if (!reply) {
        emit dataWriteError(tr("Failed to send write request: %1").arg(m_hyModbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_hyResponseTimeout);
    loop.exec();

    if (timer.isActive()) {
        timer.stop();
        if (reply->error() != QModbusDevice::NoError) {
            emit dataWriteError(tr("Write error: %1").arg(reply->errorString()));
            reply->deleteLater();
            return false;
        }

        reply->deleteLater();
        return true;
    } else {
        emit dataWriteError(tr("Write request timed out"));
        reply->deleteLater();
        return false;
    }
}

void HYModbusTcpDriver::setReconnectInterval(int interval)
{
    m_hyReconnectInterval = interval;
}

void HYModbusTcpDriver::setResponseTimeout(int timeout)
{
    m_hyResponseTimeout = timeout;
    m_hyModbusClient->setTimeout(timeout);
}

void HYModbusTcpDriver::onStateChanged(QModbusDevice::State state)
{
    switch (state) {
    case QModbusDevice::ConnectedState:
        emit connected();
        m_hyReconnectTimer->stop();
        break;
    case QModbusDevice::UnconnectedState:
        emit disconnected();
        if (m_hyAutoReconnect) {
            m_hyReconnectTimer->start(m_hyReconnectInterval);
        }
        break;
    default:
        break;
    }
}

void HYModbusTcpDriver::onErrorOccurred(QModbusDevice::Error error)
{
    if (error != QModbusDevice::NoError) {
        emit connectionError(tr("Modbus error: %1").arg(m_hyModbusClient->errorString()));
    }
}

void HYModbusTcpDriver::attemptReconnect()
{
    if (m_hyModbusClient->state() != QModbusDevice::ConnectedState) {
        m_hyModbusClient->connectDevice();
    }
}
