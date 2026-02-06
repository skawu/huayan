#ifndef DATAPROCESSOR_H
#define DATAPROCESSOR_H

#include <QObject>
#include <QTimer>
#include <QThread>
#include <QMutex>
#include <QMap>
#include <QString>
#include <QVariant>

class ModbusTcpDriver;
class TagManager;

class DataProcessor : public QObject
{
    Q_OBJECT

public:
    explicit DataProcessor(QObject *parent = nullptr);
    ~DataProcessor();

    // Initialization
    void initialize(ModbusTcpDriver *driver, TagManager *tagManager);

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

    ModbusTcpDriver *m_modbusDriver;
    TagManager *m_tagManager;
    QTimer *m_collectionTimer;
    int m_collectionInterval;
    QMutex m_mutex;
    QMap<QString, RegisterMapping> m_tagRegisterMappings;
};

#endif // DATAPROCESSOR_H
