#include "tagmanager.h"

/**
 * @file tagmanager.cpp
 * @brief Huayan点位管理系统核心实现
 * 
 * 实现了HYTag和HYTagManager类的核心功能，包括点位的添加、删除、查询和值的更新等
 * 支持多线程并发访问，确保数据安全性
 * 优化了事件通知机制，减少不必要的信号发射
 */

// HYTag class implementation

HYTag::HYTag(QObject *parent) : QObject(parent),
    m_hySignalEnabled(true)
{
}

HYTag::HYTag(const QString &name, const QString &group, const QVariant &value, 
             const QString &description, const QString &source, QObject *parent) 
    : QObject(parent),
      m_hyName(name),
      m_hyGroup(group),
      m_hyValue(value),
      m_hyDescription(description),
      m_hySource(source),
      m_hySignalEnabled(true)
{
}

QString HYTag::name() const
{
    return m_hyName;
}

QString HYTag::group() const
{
    return m_hyGroup;
}

QVariant HYTag::value() const
{
    return m_hyValue;
}

QString HYTag::description() const
{
    return m_hyDescription;
}

QString HYTag::source() const
{
    return m_hySource;
}

void HYTag::setValue(const QVariant &value)
{
    if (m_hyValue != value) {
        m_hyValue = value;
        if (m_hySignalEnabled) {
            emit valueChanged(m_hyValue);
        }
    }
}

void HYTag::setDescription(const QString &description)
{
    m_hyDescription = description;
}

void HYTag::setSignalEnabled(bool enabled)
{
    m_hySignalEnabled = enabled;
}

// HYTagManager class implementation

HYTagManager::HYTagManager(QObject *parent) : QObject(parent),
    m_hyDelayedNotification(false),
    m_hyNotificationInterval(50),
    m_hyNotificationTimer(nullptr)
{
    // Initialize notification timer
    m_hyNotificationTimer = new QTimer(this);
    connect(m_hyNotificationTimer, &QTimer::timeout, this, &HYTagManager::onDelayedNotification);
    m_hyNotificationTimer->setSingleShot(true);
}

HYTagManager::~HYTagManager()
{
    // Stop timer
    if (m_hyNotificationTimer) {
        m_hyNotificationTimer->stop();
        delete m_hyNotificationTimer;
        m_hyNotificationTimer = nullptr;
    }

    // Clean up all tags
    for (auto tag : m_hyTags.values()) {
        delete tag;
    }
    m_hyTags.clear();
    m_hyTagsByGroup.clear();
    m_hyBindings.clear();
    m_hyPendingValues.clear();
    m_hyImportantTags.clear();
}

bool HYTagManager::addTag(const QString &name, const QString &group, const QVariant &value, 
                         const QString &description, const QString &source)
{
    QMutexLocker locker(&m_hyMutex);

    // Check if tag already exists
    if (m_hyTags.contains(name)) {
        return false;
    }

    // Create new tag
    HYTag *tag = new HYTag(name, group, value, description, source, this);
    m_hyTags[name] = tag;
    m_hyTagsByGroup[group].append(tag);

    // Connect tag's valueChanged signal to our slot
    connect(tag, &HYTag::valueChanged, this, &HYTagManager::onTagValueChanged);

    emit tagAdded(name);
    return true;
}

bool HYTagManager::removeTag(const QString &name)
{
    QMutexLocker locker(&m_hyMutex);

    // Check if tag exists
    if (!m_hyTags.contains(name)) {
        return false;
    }

    HYTag *tag = m_hyTags[name];
    QString group = tag->group();

    // Remove from group map
    m_hyTagsByGroup[group].removeAll(tag);
    if (m_hyTagsByGroup[group].isEmpty()) {
        m_hyTagsByGroup.remove(group);
    }

    // Remove bindings
    if (m_hyBindings.contains(name)) {
        m_hyBindings.remove(name);
    }

    // Remove from pending values
    if (m_hyPendingValues.contains(name)) {
        m_hyPendingValues.remove(name);
    }

    // Remove from important tags
    if (m_hyImportantTags.contains(name)) {
        m_hyImportantTags.remove(name);
    }

    // Disconnect signal
    disconnect(tag, &HYTag::valueChanged, this, &HYTagManager::onTagValueChanged);

    // Delete tag
    delete tag;
    m_hyTags.remove(name);

    emit tagRemoved(name);
    return true;
}

HYTag *HYTagManager::getTag(const QString &name) const
{
    QMutexLocker locker(const_cast<QMutex *>(&m_hyMutex));
    return m_hyTags.value(name, nullptr);
}

QVector<HYTag *> HYTagManager::getTagsByGroup(const QString &group) const
{
    QMutexLocker locker(const_cast<QMutex *>(&m_hyMutex));
    return m_hyTagsByGroup.value(group, QVector<HYTag *>());
}

QVector<HYTag *> HYTagManager::getAllTags() const
{
    QMutexLocker locker(const_cast<QMutex *>(&m_hyMutex));
    return m_hyTags.values().toVector();
}

QVector<QString> HYTagManager::getGroups() const
{
    QMutexLocker locker(const_cast<QMutex *>(&m_hyMutex));
    return m_hyTagsByGroup.keys().toVector();
}

bool HYTagManager::setTagValue(const QString &name, const QVariant &value)
{
    HYTag *tag = nullptr;
    {
        QMutexLocker locker(&m_hyMutex);
        if (!m_hyTags.contains(name)) {
            return false;
        }
        tag = m_hyTags[name];
    }
    
    if (tag) {
        tag->setValue(value);
    }
    return true;
}

bool HYTagManager::setTagValues(const QMap<QString, QVariant> &values)
{
    QMutexLocker locker(&m_hyMutex);
    bool success = true;

    // Disable signals for batch update
    for (auto it = values.constBegin(); it != values.constEnd(); ++it) {
        const QString &tagName = it.key();
        if (m_hyTags.contains(tagName)) {
            m_hyTags[tagName]->setSignalEnabled(false);
        }
    }

    // Update values
    for (auto it = values.constBegin(); it != values.constEnd(); ++it) {
        const QString &tagName = it.key();
        const QVariant &value = it.value();
        if (m_hyTags.contains(tagName)) {
            m_hyTags[tagName]->setValue(value);
        } else {
            success = false;
        }
    }

    // Re-enable signals and notify
    for (auto it = values.constBegin(); it != values.constEnd(); ++it) {
        const QString &tagName = it.key();
        if (m_hyTags.contains(tagName)) {
            m_hyTags[tagName]->setSignalEnabled(true);
        }
    }

    // Emit batch signal
    emit tagValuesChanged(values);

    // Update bound properties
    for (auto it = values.constBegin(); it != values.constEnd(); ++it) {
        const QString &tagName = it.key();
        const QVariant &value = it.value();
        if (m_hyBindings.contains(tagName)) {
            const QVector<Binding> &bindings = m_hyBindings[tagName];
            for (const Binding &binding : bindings) {
                binding.object->setProperty(binding.propertyName, value);
            }
        }
    }

    return success;
}

QVariant HYTagManager::getTagValue(const QString &name) const
{
    QMutexLocker locker(const_cast<QMutex *>(&m_hyMutex));

    if (!m_hyTags.contains(name)) {
        return QVariant();
    }

    return m_hyTags[name]->value();
}

void HYTagManager::bindTagToProperty(const QString &tagName, QObject *object, const char *propertyName)
{
    QMutexLocker locker(&m_hyMutex);

    if (!m_hyTags.contains(tagName)) {
        return;
    }

    // Add binding
    Binding binding;
    binding.object = object;
    binding.propertyName = propertyName;
    m_hyBindings[tagName].append(binding);

    // Set initial value
    HYTag *tag = m_hyTags[tagName];
    object->setProperty(propertyName, tag->value());
}

void HYTagManager::unbindTagFromProperty(const QString &tagName, QObject *object, const char *propertyName)
{
    QMutexLocker locker(&m_hyMutex);

    if (!m_hyBindings.contains(tagName)) {
        return;
    }

    QVector<Binding> &bindings = m_hyBindings[tagName];
    for (int i = bindings.size() - 1; i >= 0; --i) {
        const Binding &binding = bindings[i];
        if (binding.object == object && strcmp(binding.propertyName, propertyName) == 0) {
            bindings.removeAt(i);
            break;
        }
    }

    if (bindings.isEmpty()) {
        m_hyBindings.remove(tagName);
    }
}

void HYTagManager::setDelayedNotification(bool enabled, int interval)
{
    m_hyDelayedNotification = enabled;
    m_hyNotificationInterval = interval;
}

void HYTagManager::setTagImportant(const QString &tagName, bool important)
{
    QMutexLocker locker(&m_hyMutex);
    if (important) {
        m_hyImportantTags.insert(tagName);
    } else {
        m_hyImportantTags.remove(tagName);
    }
}

void HYTagManager::onTagValueChanged(const QVariant &newValue)
{
    // Get the sender tag
    HYTag *tag = qobject_cast<HYTag *>(sender());
    if (!tag) {
        return;
    }

    QString tagName = tag->name();

    // Check if this is an important tag that should be notified immediately
    if (m_hyImportantTags.contains(tagName)) {
        // Immediate notification for important tags
        emit tagValueChanged(tagName, newValue);

        // Update bound properties
        QMutexLocker locker(&m_hyMutex);
        if (m_hyBindings.contains(tagName)) {
            const QVector<Binding> &bindings = m_hyBindings[tagName];
            for (const Binding &binding : bindings) {
                binding.object->setProperty(binding.propertyName, newValue);
            }
        }
    } else if (m_hyDelayedNotification) {
        // Add to pending values for delayed notification
        QMutexLocker locker(&m_hyMutex);
        m_hyPendingValues[tagName] = newValue;

        // Start or restart the notification timer
        m_hyNotificationTimer->start(m_hyNotificationInterval);
    } else {
        // Normal notification
        emit tagValueChanged(tagName, newValue);

        // Update bound properties
        QMutexLocker locker(&m_hyMutex);
        if (m_hyBindings.contains(tagName)) {
            const QVector<Binding> &bindings = m_hyBindings[tagName];
            for (const Binding &binding : bindings) {
                binding.object->setProperty(binding.propertyName, newValue);
            }
        }
    }
}

void HYTagManager::onDelayedNotification()
{
    QMutexLocker locker(&m_hyMutex);
    if (m_hyPendingValues.isEmpty()) {
        return;
    }

    // Copy pending values
    QMap<QString, QVariant> values = m_hyPendingValues;
    m_hyPendingValues.clear();

    // Release lock before emitting signals
    locker.unlock();

    // Emit batch signal
    emit tagValuesChanged(values);

    // Update bound properties
    locker.relock();
    for (auto it = values.constBegin(); it != values.constEnd(); ++it) {
        const QString &tagName = it.key();
        const QVariant &value = it.value();
        if (m_hyBindings.contains(tagName)) {
            const QVector<Binding> &bindings = m_hyBindings[tagName];
            for (const Binding &binding : bindings) {
                binding.object->setProperty(binding.propertyName, value);
            }
        }
    }
}

