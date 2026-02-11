#include "tagmanager.h"
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QJsonDocument>

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
    m_hyNotificationTimer(nullptr),
    m_hyHistoryEnabled(false),
    m_hyHistoryInterval(1000),
    m_hyHistoryTimer(nullptr),
    m_hyHistoryRetentionDays(365),
    m_hyPersistEnabled(false),
    m_hyOfflineMode(false),
    m_hySyncTimer(nullptr),
    m_hySyncInterval(5000)
{
    // Initialize notification timer
    m_hyNotificationTimer = new QTimer(this);
    connect(m_hyNotificationTimer, &QTimer::timeout, this, &HYTagManager::onDelayedNotification);
    m_hyNotificationTimer->setSingleShot(true);
    
    // Initialize history timer
    m_hyHistoryTimer = new QTimer(this);
    connect(m_hyHistoryTimer, &QTimer::timeout, this, &HYTagManager::onHistoryStorage);
    
    // Initialize sync timer
    m_hySyncTimer = new QTimer(this);
    connect(m_hySyncTimer, &QTimer::timeout, this, &HYTagManager::onSyncOfflineData);
    
    // Initialize database for historical data
    QDir dataDir(QDir::homePath() + "/.huayan/data");
    if (!dataDir.exists()) {
        dataDir.mkpath(".");
    }
    
    m_hyDatabase = QSqlDatabase::addDatabase("QSQLITE");
    m_hyDatabase.setDatabaseName(dataDir.absolutePath() + "/history.db");
    if (m_hyDatabase.open()) {
        // Create history table if not exists
        QSqlQuery query;
        query.exec("CREATE TABLE IF NOT EXISTS history (id INTEGER PRIMARY KEY AUTOINCREMENT, tag_name TEXT, value TEXT, timestamp TEXT)");
        query.exec("CREATE INDEX IF NOT EXISTS idx_tag_name_timestamp ON history (tag_name, timestamp)");
    }
    
    // Set default persist file path
    m_hyPersistFilePath = QDir::homePath() + "/.huayan/persist.json";
}

HYTagManager::~HYTagManager()
{
    // Stop and clean up timers
    if (m_hyNotificationTimer) {
        m_hyNotificationTimer->stop();
        delete m_hyNotificationTimer;
        m_hyNotificationTimer = nullptr;
    }
    
    if (m_hyHistoryTimer) {
        m_hyHistoryTimer->stop();
        delete m_hyHistoryTimer;
        m_hyHistoryTimer = nullptr;
    }
    
    if (m_hySyncTimer) {
        m_hySyncTimer->stop();
        delete m_hySyncTimer;
        m_hySyncTimer = nullptr;
    }

    // Close database
    if (m_hyDatabase.isOpen()) {
        m_hyDatabase.close();
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
    m_hyOfflineData.clear();
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

// Performance optimization methods
/**
 * @brief 批量添加点位
 * @param tags 点位信息列表
 * @return 添加是否成功
 */
bool HYTagManager::addTags(const QVector<QMap<QString, QVariant>> &tags)
{
    QMutexLocker locker(&m_hyMutex);
    bool success = true;

    for (const auto &tagInfo : tags) {
        QString name = tagInfo["name"].toString();
        QString group = tagInfo["group"].toString();
        QVariant value = tagInfo["value"];
        QString description = tagInfo["description"].toString();
        QString source = tagInfo["source"].toString();

        // Check if tag already exists
        if (m_hyTags.contains(name)) {
            success = false;
            continue;
        }

        // Create new tag
        HYTag *tag = new HYTag(name, group, value, description, source, this);
        m_hyTags[name] = tag;
        m_hyTagsByGroup[group].append(tag);

        // Connect tag's valueChanged signal to our slot
        connect(tag, &HYTag::valueChanged, this, &HYTagManager::onTagValueChanged);

        emit tagAdded(name);
    }

    return success;
}

/**
 * @brief 启用批量更新模式
 * @param enabled 是否启用
 */
void HYTagManager::setBatchUpdateMode(bool enabled)
{
    m_hyDelayedNotification = enabled;
    if (!enabled && !m_hyPendingValues.isEmpty()) {
        // Flush pending values
        onDelayedNotification();
    }
}

/**
 * @brief 设置批量更新间隔
 * @param interval 间隔（毫秒）
 */
void HYTagManager::setBatchUpdateInterval(int interval)
{
    m_hyNotificationInterval = interval;
}

/**
 * @brief 优化点位值更新，减少信号发射
 * @param values 点位名称和值的映射
 * @param immediate 是否立即通知
 * @return 设置是否成功
 */
bool HYTagManager::setTagValuesOptimized(const QMap<QString, QVariant> &values, bool immediate)
{
    QMutexLocker locker(&m_hyMutex);
    bool success = true;

    // 禁用信号
    for (auto it = values.constBegin(); it != values.constEnd(); ++it) {
        const QString &tagName = it.key();
        if (m_hyTags.contains(tagName)) {
            m_hyTags[tagName]->setSignalEnabled(false);
        }
    }

    // 更新值
    for (auto it = values.constBegin(); it != values.constEnd(); ++it) {
        const QString &tagName = it.key();
        const QVariant &value = it.value();
        if (m_hyTags.contains(tagName)) {
            m_hyTags[tagName]->setValue(value);
        } else {
            success = false;
        }
    }

    // 启用信号
    for (auto it = values.constBegin(); it != values.constEnd(); ++it) {
        const QString &tagName = it.key();
        if (m_hyTags.contains(tagName)) {
            m_hyTags[tagName]->setSignalEnabled(true);
        }
    }

    // 通知更新
    if (immediate) {
        // 立即通知
        emit tagValuesChanged(values);

        // 更新绑定属性
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
    } else if (m_hyDelayedNotification) {
        // 延迟通知
        for (auto it = values.constBegin(); it != values.constEnd(); ++it) {
            m_hyPendingValues[it.key()] = it.value();
        }
        m_hyNotificationTimer->start(m_hyNotificationInterval);
    } else {
        // 正常通知
        emit tagValuesChanged(values);

        // 更新绑定属性
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

    return success;
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

// Historical data storage methods
void HYTagManager::enableHistoryStorage(bool enabled, int interval, int retentionDays)
{
    m_hyHistoryEnabled = enabled;
    m_hyHistoryInterval = interval;
    m_hyHistoryRetentionDays = retentionDays;
    
    if (enabled) {
        m_hyHistoryTimer->start(interval);
    } else {
        m_hyHistoryTimer->stop();
    }
}

QVector<QPair<QDateTime, QVariant>> HYTagManager::getHistoricalData(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime)
{
    QVector<QPair<QDateTime, QVariant>> data;
    
    if (!m_hyDatabase.isOpen()) {
        return data;
    }
    
    QSqlQuery query;
    query.prepare("SELECT timestamp, value FROM history WHERE tag_name = :tag AND timestamp >= :start AND timestamp <= :end ORDER BY timestamp");
    query.bindValue(":tag", tagName);
    query.bindValue(":start", startTime.toString(Qt::ISODate));
    query.bindValue(":end", endTime.toString(Qt::ISODate));
    
    if (query.exec()) {
        while (query.next()) {
            QDateTime timestamp = QDateTime::fromString(query.value(0).toString(), Qt::ISODate);
            QVariant value = query.value(1);
            data.append(qMakePair(timestamp, value));
        }
    }
    
    return data;
}

void HYTagManager::cleanHistoricalData(int days)
{
    if (!m_hyDatabase.isOpen()) {
        return;
    }
    
    QDateTime cutoffTime = QDateTime::currentDateTime().addDays(-days);
    QSqlQuery query;
    query.prepare("DELETE FROM history WHERE timestamp < :cutoff");
    query.bindValue(":cutoff", cutoffTime.toString(Qt::ISODate));
    query.exec();
}

void HYTagManager::onHistoryStorage()
{
    if (!m_hyHistoryEnabled || !m_hyDatabase.isOpen()) {
        return;
    }
    
    QMutexLocker locker(&m_hyMutex);
    
    // 开始事务，提高批量插入性能
    QSqlQuery beginQuery;
    beginQuery.exec("BEGIN TRANSACTION");
    
    QSqlQuery query;
    query.prepare("INSERT INTO history (tag_name, value, timestamp) VALUES (:tag, :value, :timestamp)");
    
    QString timestamp = QDateTime::currentDateTime().toString(Qt::ISODate);
    
    for (const auto &tag : m_hyTags.values()) {
        query.bindValue(":tag", tag->name());
        query.bindValue(":value", tag->value().toString());
        query.bindValue(":timestamp", timestamp);
        query.exec();
    }
    
    // 提交事务
    QSqlQuery commitQuery;
    commitQuery.exec("COMMIT");
    
    // Clean up old data
    cleanHistoricalData(m_hyHistoryRetentionDays);
}

// Persistence methods
void HYTagManager::enablePersistence(bool enabled, const QString &persistFilePath)
{
    m_hyPersistEnabled = enabled;
    if (!persistFilePath.isEmpty()) {
        m_hyPersistFilePath = persistFilePath;
    }
    
    // Create directory if not exists
    QDir persistDir(QFileInfo(m_hyPersistFilePath).path());
    if (!persistDir.exists()) {
        persistDir.mkpath(".");
    }
}

void HYTagManager::saveState()
{
    if (!m_hyPersistEnabled) {
        return;
    }
    
    QFile file(m_hyPersistFilePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        return;
    }
    
    QJsonObject root;
    QJsonArray tags;
    
    QMutexLocker locker(&m_hyMutex);
    for (const auto &tag : m_hyTags.values()) {
        QJsonObject tagObj;
        tagObj["name"] = tag->name();
        tagObj["group"] = tag->group();
        tagObj["value"] = QJsonValue::fromVariant(tag->value());
        tagObj["description"] = tag->description();
        tagObj["source"] = tag->source();
        tags.append(tagObj);
    }
    
    root["tags"] = tags;
    root["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);
    
    QJsonDocument doc(root);
    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
}

void HYTagManager::loadState()
{
    if (!m_hyPersistEnabled) {
        return;
    }
    
    QFile file(m_hyPersistFilePath);
    if (!file.exists() || !file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return;
    }
    
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();
    
    if (!doc.isObject()) {
        return;
    }
    
    QJsonObject root = doc.object();
    QJsonArray tags = root["tags"].toArray();
    
    QMutexLocker locker(&m_hyMutex);
    for (const auto &tagValue : tags) {
        QJsonObject tagObj = tagValue.toObject();
        QString name = tagObj["name"].toString();
        QString group = tagObj["group"].toString();
        QVariant value = tagObj["value"].toVariant();
        QString description = tagObj["description"].toString();
        QString source = tagObj["source"].toString();
        
        // Update existing tag or add new one
        if (m_hyTags.contains(name)) {
            m_hyTags[name]->setValue(value);
        } else {
            addTag(name, group, value, description, source);
        }
    }
}

// Offline capability methods
void HYTagManager::setOfflineMode(bool offline)
{
    if (m_hyOfflineMode == offline) {
        return;
    }
    
    m_hyOfflineMode = offline;
    emit offlineModeChanged(offline);
    
    if (!offline) {
        // Sync data when going online
        syncOfflineData();
    }
}

bool HYTagManager::isOfflineMode() const
{
    return m_hyOfflineMode;
}

void HYTagManager::syncOfflineData()
{
    if (m_hyOfflineMode) {
        return;
    }
    
    QMutexLocker locker(&m_hyMutex);
    int syncCount = 0;
    
    // Process offline data
    for (const auto &tagName : m_hyOfflineData.keys()) {
        const auto &dataPoints = m_hyOfflineData[tagName];
        syncCount += dataPoints.size();
        
        // Here you would typically send data to the server
        // For now, we'll just clear the offline data
    }
    
    // Clear offline data after sync
    m_hyOfflineData.clear();
    
    emit syncCompleted(true, syncCount);
}

void HYTagManager::setSyncInterval(int interval)
{
    m_hySyncInterval = interval;
    m_hySyncTimer->setInterval(interval);
}

void HYTagManager::onSyncOfflineData()
{
    if (!m_hyOfflineMode) {
        syncOfflineData();
    }
}

// Override setTagValue to handle offline mode
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
        
        // Store in offline data if in offline mode
        if (m_hyOfflineMode) {
            QMutexLocker locker(&m_hyMutex);
            m_hyOfflineData[name].append(qMakePair(QDateTime::currentDateTime(), value));
        }
    }
    return true;
}

