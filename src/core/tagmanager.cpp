#include "tagmanager.h"

/**
 * @file tagmanager.cpp
 * @brief Huayan点位管理系统核心实现
 * 
 * 实现了HYTag和HYTagManager类的核心功能，包括点位的添加、删除、查询和值的更新等
 * 支持多线程并发访问，确保数据安全性
 */

// HYTag class implementation

HYTag::HYTag(QObject *parent) : QObject(parent)
{
}

HYTag::HYTag(const QString &name, const QString &group, const QVariant &value, 
             const QString &description, const QString &source, QObject *parent) 
    : QObject(parent),
      m_hyName(name),
      m_hyGroup(group),
      m_hyValue(value),
      m_hyDescription(description),
      m_hySource(source)
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
        emit valueChanged(m_hyValue);
    }
}

void HYTag::setDescription(const QString &description)
{
    m_hyDescription = description;
}

// HYTagManager class implementation

HYTagManager::HYTagManager(QObject *parent) : QObject(parent)
{
}

HYTagManager::~HYTagManager()
{
    // Clean up all tags
    for (auto tag : m_hyTags.values()) {
        delete tag;
    }
    m_hyTags.clear();
    m_hyTagsByGroup.clear();
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

void HYTagManager::onTagValueChanged(const QVariant &newValue)
{
    // Get the sender tag
    HYTag *tag = qobject_cast<HYTag *>(sender());
    if (!tag) {
        return;
    }

    QString tagName = tag->name();
    emit tagValueChanged(tagName, newValue);

    // Update all bound properties
    QMutexLocker locker(&m_hyMutex);
    if (m_hyBindings.contains(tagName)) {
        const QVector<Binding> &bindings = m_hyBindings[tagName];
        for (const Binding &binding : bindings) {
            binding.object->setProperty(binding.propertyName, newValue);
        }
    }
}
