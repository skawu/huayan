#include "configmanager.h"
#include <QStandardPaths>
#include <QCoreApplication>
#include <QDebug>

// 静态成员初始化
ConfigManager* ConfigManager::m_instance = nullptr;

/**
 * @brief 获取配置管理器单例实例
 * @return 配置管理器实例
 */
ConfigManager* ConfigManager::instance()
{
    if (!m_instance) {
        m_instance = new ConfigManager();
    }
    return m_instance;
}

/**
 * @brief 构造函数
 * @param parent 父对象
 */
ConfigManager::ConfigManager(QObject* parent)
    : QObject(parent),
      m_initialized(false)
{
}

/**
 * @brief 析构函数
 */
ConfigManager::~ConfigManager()
{
}

/**
 * @brief 初始化配置管理器
 * @param parent 父对象
 */
void ConfigManager::initialize(QObject* parent)
{
    if (m_initialized) {
        return;
    }

    if (parent) {
        setParent(parent);
    }

    // 设置配置文件路径
    QString appDataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    m_configFilePath = appDataDir + QDir::separator() + "config.json";

    // 设置默认配置文件路径
    QString defaultConfigPath = QCoreApplication::applicationDirPath() + QDir::separator() + "resources" + QDir::separator() + "config" + QDir::separator() + "default_config.json";
    if (!QFile::exists(defaultConfigPath)) {
        // 尝试从其他位置查找默认配置文件
        defaultConfigPath = QDir::currentPath() + QDir::separator() + "src" + QDir::separator() + "resources" + QDir::separator() + "config" + QDir::separator() + "default_config.json";
        if (!QFile::exists(defaultConfigPath)) {
            defaultConfigPath = QDir::currentPath() + QDir::separator() + "resources" + QDir::separator() + "config" + QDir::separator() + "default_config.json";
        }
    }
    m_defaultConfigFilePath = defaultConfigPath;

    qDebug() << "配置文件路径:" << m_configFilePath;
    qDebug() << "默认配置文件路径:" << m_defaultConfigFilePath;

    // 确保配置目录存在
    ensureConfigDirExists();

    // 加载配置
    loadConfig();

    m_initialized = true;
}

/**
 * @brief 确保配置目录存在
 */
void ConfigManager::ensureConfigDirExists()
{
    QFileInfo configFileInfo(m_configFilePath);
    QDir configDir = configFileInfo.dir();

    if (!configDir.exists()) {
        if (!configDir.mkpath(".")) {
            qWarning() << "无法创建配置目录:" << configDir.path();
        }
    }
}

/**
 * @brief 加载配置
 * @return 是否加载成功
 */
bool ConfigManager::loadConfig()
{
    qDebug() << "Starting to load configuration...";
    
    // 加载默认配置
    qDebug() << "Loading default config file from:" << m_defaultConfigFilePath;
    m_defaultConfig = loadDefaultConfigFile();
    qDebug() << "Default config loaded successfully, size:" << m_defaultConfig.size();

    // 加载用户配置
    qDebug() << "Loading user config file from:" << m_configFilePath;
    QJsonObject userConfig = loadUserConfigFile();
    qDebug() << "User config loaded, size:" << userConfig.size();

    if (!userConfig.isEmpty()) {
        // 使用用户配置，如果用户配置不存在或损坏，则使用默认配置
        m_config = userConfig;
        qDebug() << "Using user configuration";
    } else {
        // 使用默认配置
        m_config = m_defaultConfig;
        qDebug() << "Using default configuration";
    }

    qDebug() << "Configuration loaded successfully, total keys:" << m_config.size();
    emit configLoaded();
    return true;
}

/**
 * @brief 保存配置
 * @return 是否保存成功
 */
bool ConfigManager::saveConfig()
{
    QFile file(m_configFilePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "无法打开配置文件进行写入:" << m_configFilePath;
        return false;
    }

    QJsonDocument doc(m_config);
    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();

    emit configSaved();
    return true;
}

/**
 * @brief 恢复默认配置
 * @return 是否恢复成功
 */
bool ConfigManager::restoreDefaultConfig()
{
    m_config = m_defaultConfig;
    bool result = saveConfig();
    emit configRestored();
    return result;
}

/**
 * @brief 获取当前配置
 * @return 当前配置对象
 */
QJsonObject ConfigManager::getConfig() const
{
    return m_config;
}

/**
 * @brief 获取默认配置
 * @return 默认配置对象
 */
QJsonObject ConfigManager::getDefaultConfig() const
{
    return m_defaultConfig;
}

/**
 * @brief 获取配置值
 * @param key 配置键
 * @param defaultValue 默认值
 * @return 配置值
 */
QVariant ConfigManager::getValue(const QString& key, const QVariant& defaultValue)
{
    QStringList keyParts = key.split(".");
    QJsonObject current = m_config;

    for (int i = 0; i < keyParts.size() - 1; ++i) {
        if (!current.contains(keyParts[i])) {
            return defaultValue;
        }
        current = current[keyParts[i]].toObject();
    }

    QString finalKey = keyParts.last();
    if (!current.contains(finalKey)) {
        return defaultValue;
    }

    return current[finalKey].toVariant();
}

/**
 * @brief 设置配置值
 * @param key 配置键
 * @param value 配置值
 */
void ConfigManager::setValue(const QString& key, const QVariant& value)
{
    QStringList keyParts = key.split(".");
    QJsonObject* current = &m_config;

    for (int i = 0; i < keyParts.size() - 1; ++i) {
        QString part = keyParts[i];
        if (!current->contains(part)) {
            (*current)[part] = QJsonObject();
        }
        *current = current->operator[](part).toObject();
    }

    QString finalKey = keyParts.last();
    (*current)[finalKey] = QJsonValue::fromVariant(value);
}

/**
 * @brief 获取配置文件路径
 * @return 配置文件路径
 */
QString ConfigManager::getConfigFilePath() const
{
    return m_configFilePath;
}

/**
 * @brief 获取默认配置文件路径
 * @return 默认配置文件路径
 */
QString ConfigManager::getDefaultConfigFilePath() const
{
    return m_defaultConfigFilePath;
}

/**
 * @brief 加载默认配置文件
 * @return 默认配置对象
 */
QJsonObject ConfigManager::loadDefaultConfigFile()
{
    QFile file(m_defaultConfigFilePath);
    if (!file.exists()) {
        qWarning() << "默认配置文件不存在:" << m_defaultConfigFilePath;
        return QJsonObject();
    }

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "无法打开默认配置文件:" << m_defaultConfigFilePath;
        return QJsonObject();
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "默认配置文件解析错误:" << error.errorString();
        return QJsonObject();
    }

    if (!doc.isObject()) {
        qWarning() << "默认配置文件格式错误，不是有效的JSON对象";
        return QJsonObject();
    }

    return doc.object();
}

/**
 * @brief 加载用户配置文件
 * @return 用户配置对象
 */
QJsonObject ConfigManager::loadUserConfigFile()
{
    QFile file(m_configFilePath);
    if (!file.exists()) {
        qDebug() << "用户配置文件不存在，将使用默认配置";
        return QJsonObject();
    }

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "无法打开用户配置文件:" << m_configFilePath;
        return QJsonObject();
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "用户配置文件解析错误:" << error.errorString();
        return QJsonObject();
    }

    if (!doc.isObject()) {
        qWarning() << "用户配置文件格式错误，不是有效的JSON对象";
        return QJsonObject();
    }

    return doc.object();
}
