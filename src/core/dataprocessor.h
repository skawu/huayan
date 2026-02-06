#ifndef HYDATAPROCESSOR_H
#define HYDATAPROCESSOR_H

#include <QObject>
#include <QTimer>
#include <QThread>
#include <QMutex>
#include <QMap>
#include <QString>
#include <QVariant>

class HYModbusTcpDriver;
class HYTagManager;

class HYDataProcessor : public QObject
{
    Q_OBJECT

public:
    explicit HYDataProcessor(QObject *parent = nullptr);
    ~HYDataProcessor();

    // Initialization
    void initialize(HYModbusTcpDriver *driver, HYTagManager *tagManager);

    // Data collection
    void startDataCollection(int interval = 1000); // Default 1 second
    void stopDataCollection();
    void setCollectionInterval(int interval);

    // Command sending
    bool sendCommand(const QString &tagName, const QVariant &value);

    // Tag-device mapping
    bool mapTagToDeviceRegister(const QString &tagName, int registerAddress, bool isHoldingRegister = true);
    bool unmapTagFromDeviceRegister(const QString &tagName);

signals:
    void dataCollectionStarted();
    void dataCollectionStopped();
    void commandSent(const QString &tagName, const QVariant &value, bool success);

private slots:
    void collectData();

private:
    // Tag-device register mapping
    struct RegisterMapping {
        int address;
        bool isHoldingRegister;
    };

    HYModbusTcpDriver *m_hyModbusDriver;
    HYTagManager *m_hyTagManager;
    QTimer *m_hyCollectionTimer;
    int m_hyCollectionInterval;
    QMutex m_hyMutex;
    QMap<QString, RegisterMapping> m_hyTagRegisterMappings;
};

#endif // HYDATAPROCESSOR_H
