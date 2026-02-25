#include "tagmanager.h"
#include <QDebug>
#include <QDateTime>

TagManager::TagManager(QObject *parent)
    : QObject(parent)
    , m_updateTimer(new QTimer(this))
    , m_updateInterval(500)
{
    // 设置更新定时器
    m_updateTimer->setInterval(m_updateInterval);
    connect(m_updateTimer, &QTimer::timeout, this, [this]() {
        // 这里可以添加定期更新逻辑
        // 例如：检查连接状态、更新统计数据等
    });
    m_updateTimer->start();
}

TagManager::~TagManager()
{
    m_updateTimer->stop();
}

bool TagManager::addTag(const QString& name, const QVariant& initialValue, const QString& description)
{
    if (name.isEmpty()) {
        qWarning() << "Cannot add tag: empty name";
        return false;
    }

    if (m_tags.contains(name)) {
        qWarning() << "Tag already exists:" << name;
        return false;
    }

    TagData tagData;
    tagData.name = name;
    tagData.value = initialValue;
    tagData.description = description;
    tagData.address = QString();
    tagData.isConnected = false;
    tagData.lastUpdate = QDateTime::currentDateTime();
    tagData.minValue = QVariant();
    tagData.maxValue = QVariant();

    m_tags[name] = tagData;
    
    emit tagAdded(name);
    qDebug() << "Tag added:" << name << "with initial value:" << initialValue;
    return true;
}

bool TagManager::removeTag(const QString& name)
{
    if (!m_tags.contains(name)) {
        qWarning() << "Cannot remove tag: tag not found:" << name;
        return false;
    }

    m_tags.remove(name);
    emit tagRemoved(name);
    qDebug() << "Tag removed:" << name;
    return true;
}

QVariant TagManager::getTagValue(const QString& name) const
{
    auto it = m_tags.constFind(name);
    if (it != m_tags.constEnd()) {
        return it.value().value;
    }
    return QVariant(); // 返回无效值
}

bool TagManager::setTagValue(const QString& name, const QVariant& value)
{
    auto it = m_tags.find(name);
    if (it == m_tags.end()) {
        qWarning() << "Cannot set tag value: tag not found:" << name;
        return false;
    }

    if (!validateTagValue(it.value(), value)) {
        qWarning() << "Invalid tag value for:" << name << "value:" << value;
        return false;
    }

    QVariant oldValue = it.value().value;
    it.value().value = value;
    it.value().lastUpdate = QDateTime::currentDateTime();
    
    notifyTagChange(name, value, oldValue);
    return true;
}

bool TagManager::hasTag(const QString& name) const
{
    return m_tags.contains(name);
}

QStringList TagManager::getAllTagNames() const
{
    return QStringList(m_tags.keys());
}

void TagManager::bindTagToDevice(const QString& tagName, const QString& deviceAddress)
{
    auto it = m_tags.find(tagName);
    if (it != m_tags.end()) {
        it.value().address = deviceAddress;
        qDebug() << "Tag" << tagName << "bound to device:" << deviceAddress;
    } else {
        qWarning() << "Cannot bind tag to device: tag not found:" << tagName;
    }
}

QVariantMap TagManager::getTagInfo(const QString& name) const
{
    QVariantMap info;
    auto it = m_tags.constFind(name);
    
    if (it != m_tags.constEnd()) {
        const TagData& tagData = it.value();
        info["name"] = tagData.name;
        info["value"] = tagData.value;
        info["description"] = tagData.description;
        info["address"] = tagData.address;
        info["isConnected"] = tagData.isConnected;
        info["lastUpdate"] = tagData.lastUpdate.toString(Qt::ISODate);
        info["minValue"] = tagData.minValue;
        info["maxValue"] = tagData.maxValue;
    }
    
    return info;
}

void TagManager::updateTagValueInternal(const QString& tagName, const QVariant& value)
{
    setTagValue(tagName, value);
}

void TagManager::setConnectionStatus(const QString& tagName, bool connected)
{
    auto it = m_tags.find(tagName);
    if (it != m_tags.end()) {
        bool oldStatus = it.value().isConnected;
        it.value().isConnected = connected;
        it.value().lastUpdate = QDateTime::currentDateTime();
        
        if (oldStatus != connected) {
            emit connectionStatusChanged(tagName, connected);
            qDebug() << "Connection status changed for" << tagName << ":" << connected;
        }
    }
}

bool TagManager::validateTagValue(const TagData& tagData, const QVariant& value) const
{
    // 检查数据类型匹配
    if (tagData.value.isValid() && value.typeId() != tagData.value.typeId()) {
        // 允许数值类型之间的转换
        if ((tagData.value.typeId() == QMetaType::Double || tagData.value.typeId() == QMetaType::Float ||
             tagData.value.typeId() == QMetaType::Int || tagData.value.typeId() == QMetaType::LongLong) &&
            (value.typeId() == QMetaType::Double || value.typeId() == QMetaType::Float ||
             value.typeId() == QMetaType::Int || value.typeId() == QMetaType::LongLong)) {
            // 数值类型转换是允许的
        } else {
            return false;
        }
    }

    // 检查数值范围
    if (tagData.minValue.isValid() && tagData.maxValue.isValid()) {
        bool ok1, ok2, ok3;
        double minVal = tagData.minValue.toDouble(&ok1);
        double maxVal = tagData.maxValue.toDouble(&ok2);
        double testVal = value.toDouble(&ok3);
        
        if (ok1 && ok2 && ok3) {
            if (testVal < minVal || testVal > maxVal) {
                return false;
            }
        }
    }

    return true;
}

void TagManager::notifyTagChange(const QString& tagName, const QVariant& newValue, const QVariant& oldValue)
{
    emit tagValueChanged(tagName, newValue, oldValue);
}