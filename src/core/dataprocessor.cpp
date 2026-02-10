#include "dataprocessor.h"
#include "../communication/hymodbustcpdriver.h"
#include "tagmanager.h"
#include "timeseriesdatabase.h"


HYDataProcessor::HYDataProcessor(QObject *parent) : QObject(parent),
    m_hyModbusDriver(nullptr),
    m_hyTagManager(nullptr),
    m_hyTimeSeriesDatabase(nullptr),
    m_hyCollectionTimer(nullptr),
    m_hyCollectionInterval(1000),
    m_hyVisibleUpdateInterval(100), // 可见标签更新间隔（毫秒）
    m_hyHiddenUpdateInterval(1000) // 不可见标签更新间隔（毫秒）
{
    m_hyCollectionTimer = new QTimer(this);
    connect(m_hyCollectionTimer, &QTimer::timeout, this, &HYDataProcessor::collectDataIntelligently);
}

HYDataProcessor::~HYDataProcessor()
{
    stopDataCollection();
    if (m_hyCollectionTimer) {
        delete m_hyCollectionTimer;
        m_hyCollectionTimer = nullptr;
    }
}

void HYDataProcessor::initialize(HYModbusTcpDriver *driver, HYTagManager *tagManager)
{
    m_hyModbusDriver = driver;
    m_hyTagManager = tagManager;
}

void HYDataProcessor::startDataCollection(int interval)
{
    setCollectionInterval(interval);
    m_hyCollectionTimer->start(m_hyCollectionInterval);
    emit dataCollectionStarted();
}

void HYDataProcessor::stopDataCollection()
{
    if (m_hyCollectionTimer->isActive()) {
        m_hyCollectionTimer->stop();
        emit dataCollectionStopped();
    }
}

void HYDataProcessor::setCollectionInterval(int interval)
{
    m_hyCollectionInterval = interval;
    if (m_hyCollectionTimer->isActive()) {
        m_hyCollectionTimer->start(m_hyCollectionInterval);
    }
}

bool HYDataProcessor::sendCommand(const QString &tagName, const QVariant &value)
{
    QMutexLocker locker(&m_hyMutex);

    if (!m_hyModbusDriver || !m_hyTagManager) {
        return false;
    }

    if (!m_hyTagRegisterMappings.contains(tagName)) {
        return false;
    }

    const RegisterMapping &mapping = m_hyTagRegisterMappings[tagName];
    bool success = false;

    if (mapping.isHoldingRegister) {
        // Write to holding register
        quint16 registerValue = value.toInt();
        success = m_hyModbusDriver->writeHoldingRegister(mapping.address, registerValue);
    } else {
        // Write to coil
        bool coilValue = value.toBool();
        success = m_hyModbusDriver->writeCoil(mapping.address, coilValue);
    }

    if (success) {
        m_hyTagManager->setTagValue(tagName, value);
    }

    emit commandSent(tagName, value, success);
    return success;
}

bool HYDataProcessor::mapTagToDeviceRegister(const QString &tagName, int registerAddress, bool isHoldingRegister)
{
    QMutexLocker locker(&m_hyMutex);

    if (!m_hyTagManager || !m_hyTagManager->getTag(tagName)) {
        return false;
    }

    RegisterMapping mapping;
    mapping.address = registerAddress;
    mapping.isHoldingRegister = isHoldingRegister;
    mapping.lastUpdateTime = QDateTime::currentDateTime().addDays(-1); // 初始化为一天前，确保首次采集

    m_hyTagRegisterMappings[tagName] = mapping;
    return true;
}

bool HYDataProcessor::unmapTagFromDeviceRegister(const QString &tagName)
{
    QMutexLocker locker(&m_hyMutex);

    if (!m_hyTagRegisterMappings.contains(tagName)) {
        return false;
    }

    m_hyTagRegisterMappings.remove(tagName);
    m_hyVisibleTags.remove(tagName);
    return true;
}

void HYDataProcessor::setTimeSeriesDatabase(HYTimeSeriesDatabase *db)
{
    m_hyTimeSeriesDatabase = db;
}

bool HYDataProcessor::storeHistoricalData(const QString &tagName, const QVariant &value, const QDateTime &timestamp)
{
    if (!m_hyTimeSeriesDatabase) {
        return false;
    }

    return m_hyTimeSeriesDatabase->storeTagValue(tagName, value, timestamp);
}

QMap<QDateTime, QVariant> HYDataProcessor::queryHistoricalData(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime, int limit)
{
    if (!m_hyTimeSeriesDatabase) {
        return QMap<QDateTime, QVariant>();
    }

    return m_hyTimeSeriesDatabase->queryTagHistory(tagName, startTime, endTime, limit);
}

void HYDataProcessor::collectData()
{
    // 保持向后兼容，调用智能采集方法
    collectDataIntelligently();
}

void HYDataProcessor::collectDataIntelligently()
{
    QMutexLocker locker(&m_hyMutex);

    if (!m_hyModbusDriver || !m_hyTagManager || m_hyTagRegisterMappings.isEmpty()) {
        return;
    }

    const QDateTime timestamp = QDateTime::currentDateTime();

    // Read data from mapped registers based on visibility and update interval
    for (auto it = m_hyTagRegisterMappings.begin(); it != m_hyTagRegisterMappings.end(); ++it) {
        const QString &tagName = it.key();
        RegisterMapping &mapping = it.value();

        // Check if tag needs update based on visibility
        if (shouldUpdateTag(tagName, mapping)) {
            if (mapping.isHoldingRegister) {
                // Read holding register
                quint16 value;
                if (m_hyModbusDriver->readHoldingRegister(mapping.address, value)) {
                    m_hyTagManager->setTagValue(tagName, value);
                    // Store historical data
                    storeHistoricalData(tagName, value, timestamp);
                    // Update last update time
                    mapping.lastUpdateTime = timestamp;
                }
            } else {
                // Read coil
                bool value;
                if (m_hyModbusDriver->readCoil(mapping.address, value)) {
                    m_hyTagManager->setTagValue(tagName, value);
                    // Store historical data
                    storeHistoricalData(tagName, value, timestamp);
                    // Update last update time
                    mapping.lastUpdateTime = timestamp;
                }
            }
        }
    }
}

bool HYDataProcessor::shouldUpdateTag(const QString &tagName, const RegisterMapping &mapping)
{
    // Calculate time since last update
    qint64 msSinceLastUpdate = mapping.lastUpdateTime.msecsTo(QDateTime::currentDateTime());
    
    // Determine update interval based on visibility
    int updateInterval = m_hyVisibleTags.contains(tagName) ? m_hyVisibleUpdateInterval : m_hyHiddenUpdateInterval;
    
    // Check if it's time to update
    return msSinceLastUpdate >= updateInterval;
}

void HYDataProcessor::addVisibleTag(const QString &tagName)
{
    QMutexLocker locker(&m_hyMutex);
    m_hyVisibleTags.insert(tagName);
}

void HYDataProcessor::removeVisibleTag(const QString &tagName)
{
    QMutexLocker locker(&m_hyMutex);
    m_hyVisibleTags.remove(tagName);
}

void HYDataProcessor::setVisibleTags(const QSet<QString> &tagNames)
{
    QMutexLocker locker(&m_hyMutex);
    m_hyVisibleTags = tagNames;
}

void HYDataProcessor::setVisibleUpdateInterval(int interval)
{
    m_hyVisibleUpdateInterval = interval;
}

void HYDataProcessor::setHiddenUpdateInterval(int interval)
{
    m_hyHiddenUpdateInterval = interval;
}