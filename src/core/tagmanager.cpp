#include "tagmanager.h"

// Tag class implementation

Tag::Tag(QObject *parent) : QObject(parent)
{
}

Tag::Tag(const QString &name, const QString &group, const QVariant &value, const QString &description, QObject *parent) 
    : QObject(parent),
      m_name(name),
      m_group(group),
      m_value(value),
      m_description(description)
{
}

QString Tag::name() const
{
    return m_name;
}

QString Tag::group() const
{
    return m_group;
}

QVariant Tag::value() const
{
    return m_value;
}

QString Tag::description() const
{
    return m_description;
}

void Tag::setValue(const QVariant &value)
{
    if (m_value != value) {
        m_value = value;
        emit valueChanged(m_value);
    }
}

void Tag::setDescription(const QString &description)
{
    m_description = description;
}

// TagManager class implementation

TagManager::TagManager(QObject *parent) : QObject(parent)
{
}

TagManager::~TagManager()
{
    // Clean up all tags
    for (auto tag : m_tags.values()) {
        delete tag;
    }
    m_tags.clear();
    m_tagsByGroup.clear();
}

bool TagManager::addTag(const QString &name, const QString &group, const QVariant &value, const QString &description)
{
    QMutexLocker locker(&m_mutex);

    // Check if tag already exists
    if (m_tags.contains(name)) {
        return false;
    }

    // Create new tag
    Tag *tag = new Tag(name, group, value, description, this);
    m_tags[name] = tag;
    m_tagsByGroup[group].append(tag);

    // Connect tag's valueChanged signal to our slot
    connect(tag, &Tag::valueChanged, this, &TagManager::onTagValueChanged);

    emit tagAdded(name);
    return true;
}

bool TagManager::removeTag(const QString &name)
{
    QMutexLocker locker(&m_mutex);

    // Check if tag exists
    if (!m_tags.contains(name)) {
        return false;
    }

    Tag *tag = m_tags[name];
    QString group = tag->group();

    // Remove from group map
    m_tagsByGroup[group].removeAll(tag);
    if (m_tagsByGroup[group].isEmpty()) {
        m_tagsByGroup.remove(group);
    }

    // Remove bindings
    if (m_bindings.contains(name)) {
        m_bindings.remove(name);
    }

    // Disconnect signal
    disconnect(tag, &Tag::valueChanged, this, &TagManager::onTagValueChanged);

    // Delete tag
    delete tag;
    m_tags.remove(name);

    emit tagRemoved(name);
    return true;
}

Tag *TagManager::getTag(const QString &name) const
{
    QMutexLocker locker(const_cast<QMutex *>(&m_mutex));
    return m_tags.value(name, nullptr);
}

QVector<Tag *> TagManager::getTagsByGroup(const QString &group) const
{
    QMutexLocker locker(const_cast<QMutex *>(&m_mutex));
    return m_tagsByGroup.value(group, QVector<Tag *>());
}

QVector<Tag *> TagManager::getAllTags() const
{
    QMutexLocker locker(const_cast<QMutex *>(&m_mutex));
    return m_tags.values().toVector();
}

QVector<QString> TagManager::getGroups() const
{
    QMutexLocker locker(const_cast<QMutex *>(&m_mutex));
    return m_tagsByGroup.keys().toVector();
}

bool TagManager::setTagValue(const QString &name, const QVariant &value)
{
    QMutexLocker locker(&m_mutex);

    if (!m_tags.contains(name)) {
        return false;
    }

    Tag *tag = m_tags[name];
    tag->setValue(value);
    return true;
}

QVariant TagManager::getTagValue(const QString &name) const
{
    QMutexLocker locker(const_cast<QMutex *>(&m_mutex));

    if (!m_tags.contains(name)) {
        return QVariant();
    }

    return m_tags[name]->value();
}

void TagManager::bindTagToProperty(const QString &tagName, QObject *object, const char *propertyName)
{
    QMutexLocker locker(&m_mutex);

    if (!m_tags.contains(tagName)) {
        return;
    }

    // Add binding
    Binding binding;
    binding.object = object;
    binding.propertyName = propertyName;
    m_bindings[tagName].append(binding);

    // Set initial value
    Tag *tag = m_tags[tagName];
    object->setProperty(propertyName, tag->value());
}

void TagManager::unbindTagFromProperty(const QString &tagName, QObject *object, const char *propertyName)
{
    QMutexLocker locker(&m_mutex);

    if (!m_bindings.contains(tagName)) {
        return;
    }

    QVector<Binding> &bindings = m_bindings[tagName];
    for (int i = bindings.size() - 1; i >= 0; --i) {
        const Binding &binding = bindings[i];
        if (binding.object == object && strcmp(binding.propertyName, propertyName) == 0) {
            bindings.removeAt(i);
            break;
        }
    }

    if (bindings.isEmpty()) {
        m_bindings.remove(tagName);
    }
}

void TagManager::onTagValueChanged(const QVariant &newValue)
{
    // Get the sender tag
    Tag *tag = qobject_cast<Tag *>(sender());
    if (!tag) {
        return;
    }

    QString tagName = tag->name();
    emit tagValueChanged(tagName, newValue);

    // Update all bound properties
    QMutexLocker locker(&m_mutex);
    if (m_bindings.contains(tagName)) {
        const QVector<Binding> &bindings = m_bindings[tagName];
        for (const Binding &binding : bindings) {
            binding.object->setProperty(binding.propertyName, newValue);
        }
    }
}
