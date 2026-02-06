#include "dataprocessor.h"
#include "../communication/modbustcpdriver.h"
#include "tagmanager.h"

DataProcessor::DataProcessor(QObject *parent) : QObject(parent)
{
    m_modbusDriver = nullptr;
    m_tagManager = nullptr;
    m_collectionTimer = new QTimer(this);
    m_collectionInterval = 1000; // 1 second default

    connect(m_collectionTimer, &QTimer::timeout, this, &DataProcessor::collectData);
}

DataProcessor::~DataProcessor()
{
    stopDataCollection();
    delete m_collectionTimer;
}

void DataProcessor::initialize(ModbusTcpDriver *driver, TagManager *tagManager)
{
    m_modbusDriver = driver;
    m_tagManager = tagManager;
}

void DataProcessor::startDataCollection(int interval)
{
    m_collectionInterval = interval;
    m_collectionTimer->start(m_collectionInterval);
    emit dataCollectionStarted();
}

void DataProcessor::stopDataCollection()
{
    m_collectionTimer->stop();
    emit dataCollectionStopped();
}

void DataProcessor::setCollectionInterval(int interval)
{
    m_collectionInterval = interval;
    if (m_collectionTimer->isActive()) {
        m_collectionTimer->setInterval(m_collectionInterval);
    }
}

bool DataProcessor::sendCommand(const QString &tagName, const QVariant &value)
{
    if (!m_modbusDriver || !m_tagManager || !m_modbusDriver->isConnected()) {
        emit commandSent(tagName, value, false);
        return false;
    }

    QMutexLocker locker(&m_mutex);

    // Check if tag is mapped to a device register
    if (!m_tagRegisterMappings.contains(tagName)) {
        emit commandSent(tagName, value, false);
        return false;
    }

    const RegisterMapping &mapping = m_tagRegisterMappings[tagName];
    bool success = false;

    // Write value to device register
    if (mapping.isHoldingRegister) {
        quint16 registerValue = value.toUInt();
        success = m_modbusDriver->writeHoldingRegister(mapping.address, registerValue);
    } else {
        bool coilValue = value.toBool();
        success = m_modbusDriver->writeCoil(mapping.address, coilValue);
    }

    // Update tag value if successful
    if (success) {
        m_tagManager->setTagValue(tagName, value);
    }

    emit commandSent(tagName, value, success);
    return success;
}

bool DataProcessor::mapTagToDeviceRegister(const QString &tagName, int registerAddress, bool isHoldingRegister)
{
    if (!m_tagManager || !m_tagManager->getTag(tagName)) {
        return false;
    }

    QMutexLocker locker(&m_mutex);

    RegisterMapping mapping;
    mapping.address = registerAddress;
    mapping.isHoldingRegister = isHoldingRegister;
    m_tagRegisterMappings[tagName] = mapping;

    return true;
}

bool DataProcessor::unmapTagFromDeviceRegister(const QString &tagName)
{
    QMutexLocker locker(&m_mutex);

    if (!m_tagRegisterMappings.contains(tagName)) {
        return false;
    }

    m_tagRegisterMappings.remove(tagName);
    return true;
}

void DataProcessor::collectData()
{
    if (!m_modbusDriver || !m_tagManager || !m_modbusDriver->isConnected()) {
        return;
    }

    QMutexLocker locker(&m_mutex);

    // Iterate through all mapped tags and collect data
    for (const QString &tagName : m_tagRegisterMappings.keys()) {
        const RegisterMapping &mapping = m_tagRegisterMappings[tagName];
        QVariant value;
        bool success = false;

        // Read value from device register
        if (mapping.isHoldingRegister) {
            quint16 registerValue;
            success = m_modbusDriver->readHoldingRegister(mapping.address, registerValue);
            if (success) {
                value = registerValue;
            }
        } else {
            bool coilValue;
            success = m_modbusDriver->readCoil(mapping.address, coilValue);
            if (success) {
                value = coilValue;
            }
        }

        // Update tag value if successful
        if (success) {
            m_tagManager->setTagValue(tagName, value);
        }
    }
}
