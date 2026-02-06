#ifndef MODBUSTCPDRIVER_H
#define MODBUSTCPDRIVER_H

#include <QObject>
#include <QTcpSocket>
#include <QTimer>
#include <QEventLoop>
#include <QModbusClient>
#include <QModbusTcpClient>
#include <QModbusDataUnit>

class ModbusTcpDriver : public QObject
{
    Q_OBJECT

public:
    explicit ModbusTcpDriver(QObject *parent = nullptr);
    ~ModbusTcpDriver();

    // Connection management
    bool connectToDevice(const QString &ipAddress, int port, int slaveId);
    void disconnectFromDevice();
    bool isConnected() const;

    // Data reading/writing
    bool readCoil(int address, bool &value);
    bool readDiscreteInput(int address, bool &value);
    bool readHoldingRegister(int address, quint16 &value);
    bool readInputRegister(int address, quint16 &value);

    bool writeCoil(int address, bool value);
    bool writeHoldingRegister(int address, quint16 value);

    // Batch operations
    bool readMultipleCoils(int startAddress, int count, QVector<bool> &values);
    bool readMultipleHoldingRegisters(int startAddress, int count, QVector<quint16> &values);
    bool writeMultipleCoils(int startAddress, const QVector<bool> &values);
    bool writeMultipleHoldingRegisters(int startAddress, const QVector<quint16> &values);

    // Configuration
    void setReconnectInterval(int interval);
    void setResponseTimeout(int timeout);

signals:
    void connected();
    void disconnected();
    void connectionError(const QString &error);
    void dataReadError(const QString &error);
    void dataWriteError(const QString &error);

private slots:
    void onStateChanged(QModbusDevice::State state);
    void onErrorOccurred(QModbusDevice::Error error);
    void attemptReconnect();

private:
    QModbusTcpClient *m_modbusClient;
    QString m_ipAddress;
    int m_port;
    int m_slaveId;
    int m_reconnectInterval;
    int m_responseTimeout;
    QTimer *m_reconnectTimer;
    bool m_autoReconnect;
};

#endif // MODBUSTCPDRIVER_H
