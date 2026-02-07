#ifndef HYDATAPROCESSOR_H
#define HYDATAPROCESSOR_H

#include <QObject>
#include <QTimer>
#include <QThread>
#include <QMutex>
#include <QMap>
#include <QString>
#include <QVariant>
#include <QDateTime>

class HYModbusTcpDriver;
class HYTagManager;
class HYTimeSeriesDatabase;

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

    // Time-series database methods
    void setTimeSeriesDatabase(HYTimeSeriesDatabase *db);
    bool storeHistoricalData(const QString &tagName, const QVariant &value, const QDateTime &timestamp = QDateTime::currentDateTime());
    QMap<QDateTime, QVariant> queryHistoricalData(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime, int limit = 1000);

    HYModbusTcpDriver *m_hyModbusDriver;
    HYTagManager *m_hyTagManager;
    HYTimeSeriesDatabase *m_hyTimeSeriesDatabase;
    QTimer *m_hyCollectionTimer;
    int m_hyCollectionInterval;
    QMutex m_hyMutex;
    QMap<QString, RegisterMapping> m_hyTagRegisterMappings;
};

#endif // HYDATAPROCESSOR_H
