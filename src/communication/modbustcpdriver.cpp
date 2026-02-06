#include "modbustcpdriver.h"

ModbusTcpDriver::ModbusTcpDriver(QObject *parent) : QObject(parent)
{
    m_modbusClient = new QModbusTcpClient(this);
    m_reconnectTimer = new QTimer(this);
    m_reconnectInterval = 5000; // 5 seconds default
    m_responseTimeout = 1000;  // 1 second default
    m_autoReconnect = true;
    m_slaveId = 1;

    // Connect signals and slots
    connect(m_modbusClient, &QModbusClient::stateChanged, this, &ModbusTcpDriver::onStateChanged);
    connect(m_modbusClient, &QModbusClient::errorOccurred, this, &ModbusTcpDriver::onErrorOccurred);
    connect(m_reconnectTimer, &QTimer::timeout, this, &ModbusTcpDriver::attemptReconnect);

    // Set default timeout
    m_modbusClient->setTimeout(m_responseTimeout);
    m_modbusClient->setNumberOfRetries(3);
}

ModbusTcpDriver::~ModbusTcpDriver()
{
    disconnectFromDevice();
    delete m_modbusClient;
    delete m_reconnectTimer;
}

bool ModbusTcpDriver::connectToDevice(const QString &ipAddress, int port, int slaveId)
{
    m_ipAddress = ipAddress;
    m_port = port;
    m_slaveId = slaveId;

    // Disconnect if already connected
    if (m_modbusClient->state() == QModbusDevice::ConnectedState) {
        m_modbusClient->disconnectDevice();
    }

    // Set connection parameters
    m_modbusClient->setConnectionParameter(QModbusDevice::NetworkAddressParameter, ipAddress);
    m_modbusClient->setConnectionParameter(QModbusDevice::NetworkPortParameter, port);

    // Connect
    bool success = m_modbusClient->connectDevice();
    if (!success) {
        emit connectionError(tr("Failed to connect to %1:%2").arg(ipAddress).arg(port));
        if (m_autoReconnect) {
            m_reconnectTimer->start(m_reconnectInterval);
        }
    }

    return success;
}

void ModbusTcpDriver::disconnectFromDevice()
{
    m_reconnectTimer->stop();
    if (m_modbusClient->state() == QModbusDevice::ConnectedState) {
        m_modbusClient->disconnectDevice();
    }
}

bool ModbusTcpDriver::isConnected() const
{
    return m_modbusClient->state() == QModbusDevice::ConnectedState;
}

bool ModbusTcpDriver::readCoil(int address, bool &value)
{
    if (!isConnected()) {
        emit dataReadError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::Coils, address, 1);
    auto *reply = m_modbusClient->sendReadRequest(unit, m_slaveId);
    if (!reply) {
        emit dataReadError(tr("Failed to send read request: %1").arg(m_modbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_responseTimeout);
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

bool ModbusTcpDriver::readDiscreteInput(int address, bool &value)
{
    if (!isConnected()) {
        emit dataReadError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::DiscreteInputs, address, 1);
    auto *reply = m_modbusClient->sendReadRequest(unit, m_slaveId);
    if (!reply) {
        emit dataReadError(tr("Failed to send read request: %1").arg(m_modbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_responseTimeout);
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

bool ModbusTcpDriver::readHoldingRegister(int address, quint16 &value)
{
    if (!isConnected()) {
        emit dataReadError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::HoldingRegisters, address, 1);
    auto *reply = m_modbusClient->sendReadRequest(unit, m_slaveId);
    if (!reply) {
        emit dataReadError(tr("Failed to send read request: %1").arg(m_modbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_responseTimeout);
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

bool ModbusTcpDriver::readInputRegister(int address, quint16 &value)
{
    if (!isConnected()) {
        emit dataReadError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::InputRegisters, address, 1);
    auto *reply = m_modbusClient->sendReadRequest(unit, m_slaveId);
    if (!reply) {
        emit dataReadError(tr("Failed to send read request: %1").arg(m_modbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_responseTimeout);
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

bool ModbusTcpDriver::writeCoil(int address, bool value)
{
    if (!isConnected()) {
        emit dataWriteError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::Coils, address, 1);
    unit.setValue(0, value ? 1 : 0);

    auto *reply = m_modbusClient->sendWriteRequest(unit, m_slaveId);
    if (!reply) {
        emit dataWriteError(tr("Failed to send write request: %1").arg(m_modbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_responseTimeout);
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

bool ModbusTcpDriver::writeHoldingRegister(int address, quint16 value)
{
    if (!isConnected()) {
        emit dataWriteError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::HoldingRegisters, address, 1);
    unit.setValue(0, value);

    auto *reply = m_modbusClient->sendWriteRequest(unit, m_slaveId);
    if (!reply) {
        emit dataWriteError(tr("Failed to send write request: %1").arg(m_modbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_responseTimeout);
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

bool ModbusTcpDriver::readMultipleCoils(int startAddress, int count, QVector<bool> &values)
{
    if (!isConnected()) {
        emit dataReadError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::Coils, startAddress, count);
    auto *reply = m_modbusClient->sendReadRequest(unit, m_slaveId);
    if (!reply) {
        emit dataReadError(tr("Failed to send read request: %1").arg(m_modbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_responseTimeout);
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

bool ModbusTcpDriver::readMultipleHoldingRegisters(int startAddress, int count, QVector<quint16> &values)
{
    if (!isConnected()) {
        emit dataReadError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::HoldingRegisters, startAddress, count);
    auto *reply = m_modbusClient->sendReadRequest(unit, m_slaveId);
    if (!reply) {
        emit dataReadError(tr("Failed to send read request: %1").arg(m_modbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_responseTimeout);
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

bool ModbusTcpDriver::writeMultipleCoils(int startAddress, const QVector<bool> &values)
{
    if (!isConnected()) {
        emit dataWriteError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::Coils, startAddress, values.size());
    for (int i = 0; i < values.size(); ++i) {
        unit.setValue(i, values[i] ? 1 : 0);
    }

    auto *reply = m_modbusClient->sendWriteRequest(unit, m_slaveId);
    if (!reply) {
        emit dataWriteError(tr("Failed to send write request: %1").arg(m_modbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_responseTimeout);
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

bool ModbusTcpDriver::writeMultipleHoldingRegisters(int startAddress, const QVector<quint16> &values)
{
    if (!isConnected()) {
        emit dataWriteError(tr("Not connected to device"));
        return false;
    }

    QModbusDataUnit unit(QModbusDataUnit::HoldingRegisters, startAddress, values.size());
    for (int i = 0; i < values.size(); ++i) {
        unit.setValue(i, values[i]);
    }

    auto *reply = m_modbusClient->sendWriteRequest(unit, m_slaveId);
    if (!reply) {
        emit dataWriteError(tr("Failed to send write request: %1").arg(m_modbusClient->errorString()));
        return false;
    }

    // Use blocking approach with event loop
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QModbusReply::finished, &loop, &QEventLoop::quit);
    timer.start(m_responseTimeout);
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

void ModbusTcpDriver::setReconnectInterval(int interval)
{
    m_reconnectInterval = interval;
}

void ModbusTcpDriver::setResponseTimeout(int timeout)
{
    m_responseTimeout = timeout;
    m_modbusClient->setTimeout(timeout);
}

void ModbusTcpDriver::onStateChanged(QModbusDevice::State state)
{
    switch (state) {
    case QModbusDevice::ConnectedState:
        emit connected();
        m_reconnectTimer->stop();
        break;
    case QModbusDevice::UnconnectedState:
        emit disconnected();
        if (m_autoReconnect) {
            m_reconnectTimer->start(m_reconnectInterval);
        }
        break;
    default:
        break;
    }
}

void ModbusTcpDriver::onErrorOccurred(QModbusDevice::Error error)
{
    if (error != QModbusDevice::NoError) {
        emit connectionError(tr("Modbus error: %1").arg(m_modbusClient->errorString()));
    }
}

void ModbusTcpDriver::attemptReconnect()
{
    if (m_modbusClient->state() != QModbusDevice::ConnectedState) {
        m_modbusClient->connectDevice();
    }
}
