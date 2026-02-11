#include "extensionmanager.h"
#include <QStandardPaths>
#include <QCoreApplication>
#include <QDirIterator>
#include <QFile>
#include <QJsonDocument>
#include <QDebug>

// 静态成员初始化
ExtensionManager* ExtensionManager::m_instance = nullptr;

/**
 * @brief 获取扩展管理器单例实例
 * @return 扩展管理器实例
 */
ExtensionManager* ExtensionManager::instance()
{
    if (!m_instance) {
        m_instance = new ExtensionManager();
    }
    return m_instance;
}

/**
 * @brief 构造函数
 * @param parent 父对象
 */
ExtensionManager::ExtensionManager(QObject* parent)
    : QObject(parent),
      m_initialized(false)
{
}

/**
 * @brief 析构函数
 */
ExtensionManager::~ExtensionManager()
{
    // 清理插件加载器
    for (auto loader : m_pluginLoaders.values()) {
        if (loader) {
            delete loader;
        }
    }
    m_pluginLoaders.clear();
}

/**
 * @brief 初始化扩展管理器
 * @param parent 父对象
 */
void ExtensionManager::initialize(QObject* parent)
{
    if (m_initialized) {
        return;
    }

    if (parent) {
        setParent(parent);
    }

    // 设置扩展目录
    QString appDataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    
    // 定义扩展类型和对应的目录
    m_extensionDirs["components"] = appDataDir + QDir::separator() + "extensions" + QDir::separator() + "components";
    m_extensionDirs["templates"] = appDataDir + QDir::separator() + "extensions" + QDir::separator() + "templates";
    m_extensionDirs["drivers"] = appDataDir + QDir::separator() + "extensions" + QDir::separator() + "drivers";
    m_extensionDirs["interfaces"] = appDataDir + QDir::separator() + "extensions" + QDir::separator() + "interfaces";
    
    // 确保所有扩展目录存在
    for (const QString& extensionType : m_extensionDirs.keys()) {
        ensureExtensionDirExists(extensionType);
    }

    m_initialized = true;
}

/**
 * @brief 确保扩展目录存在
 * @param extensionType 扩展类型
 */
void ExtensionManager::ensureExtensionDirExists(const QString& extensionType)
{
    if (!m_extensionDirs.contains(extensionType)) {
        return;
    }

    QString dirPath = m_extensionDirs[extensionType];
    QDir dir(dirPath);

    if (!dir.exists()) {
        if (!dir.mkpath(".")) {
            qWarning() << "无法创建扩展目录:" << dirPath;
        }
    }
}

/**
 * @brief 加载所有扩展
 */
void ExtensionManager::loadExtensions()
{
    qDebug() << "Starting to load all extensions...";
    qDebug() << "Found" << m_extensionDirs.size() << "extension types to load";
    
    for (const QString& extensionType : m_extensionDirs.keys()) {
        qDebug() << "Loading extensions of type:" << extensionType;
        loadExtensionsByType(extensionType);
    }

    qDebug() << "All extensions loaded successfully";
    emit extensionsLoaded();
}

/**
 * @brief 加载指定类型的扩展
 * @param extensionType 扩展类型
 */
void ExtensionManager::loadExtensionsByType(const QString& extensionType)
{
    if (!m_extensionDirs.contains(extensionType)) {
        return;
    }

    // 扫描扩展目录
    scanExtensionDir(extensionType);
}

/**
 * @brief 扫描扩展目录
 * @param extensionType 扩展类型
 */
void ExtensionManager::scanExtensionDir(const QString& extensionType)
{
    if (!m_extensionDirs.contains(extensionType)) {
        return;
    }

    QString dirPath = m_extensionDirs[extensionType];
    QDirIterator it(dirPath, QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot, QDirIterator::Subdirectories);

    while (it.hasNext()) {
        QString filePath = it.next();
        QFileInfo fileInfo(filePath);

        if (fileInfo.isFile()) {
            if (fileInfo.suffix() == "so" || fileInfo.suffix() == "dll" || fileInfo.suffix() == "dylib") {
                // 加载插件
                loadExtensionPlugin(filePath, extensionType);
            } else if (fileInfo.suffix() == "json" || fileInfo.suffix() == "yaml") {
                // 加载配置文件
                loadExtensionConfig(filePath, extensionType);
            }
        }
    }
}

/**
 * @brief 加载扩展插件
 * @param pluginPath 插件路径
 * @param extensionType 扩展类型
 */
void ExtensionManager::loadExtensionPlugin(const QString& pluginPath, const QString& extensionType)
{
    QPluginLoader* loader = new QPluginLoader(pluginPath);
    QObject* plugin = loader->instance();

    if (plugin) {
        qDebug() << "成功加载插件:" << pluginPath;
        m_pluginLoaders[pluginPath] = loader;
        
        // 这里可以根据插件类型进行不同的处理
        // 例如，获取插件信息并注册
        QJsonObject extensionInfo;
        extensionInfo["name"] = QFileInfo(pluginPath).baseName();
        extensionInfo["path"] = pluginPath;
        extensionInfo["type"] = extensionType;
        extensionInfo["isPlugin"] = true;
        
        registerExtension(extensionType, extensionInfo);
    } else {
        qWarning() << "加载插件失败:" << pluginPath << "错误:" << loader->errorString();
        delete loader;
    }
}

/**
 * @brief 加载扩展配置文件
 * @param configPath 配置文件路径
 * @param extensionType 扩展类型
 */
void ExtensionManager::loadExtensionConfig(const QString& configPath, const QString& extensionType)
{
    QFile file(configPath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "无法打开扩展配置文件:" << configPath;
        return;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "扩展配置文件解析错误:" << error.errorString();
        return;
    }

    if (!doc.isObject()) {
        qWarning() << "扩展配置文件格式错误，不是有效的JSON对象";
        return;
    }

    QJsonObject extensionInfo = doc.object();
    extensionInfo["path"] = configPath;
    extensionInfo["type"] = extensionType;
    extensionInfo["isPlugin"] = false;

    registerExtension(extensionType, extensionInfo);
}

/**
 * @brief 注册新扩展
 * @param extensionType 扩展类型
 * @param extensionInfo 扩展信息
 */
void ExtensionManager::registerExtension(const QString& extensionType, const QJsonObject& extensionInfo)
{
    if (!m_extensions.contains(extensionType)) {
        m_extensions[extensionType] = QJsonArray();
    }

    m_extensions[extensionType].append(extensionInfo);

    // 发送扩展注册完成信号
    QString extensionName = extensionInfo["name"].toString();
    emit extensionRegistered(extensionType, extensionName);

    qDebug() << "注册扩展:" << extensionName << "类型:" << extensionType;
}

/**
 * @brief 获取指定类型的所有扩展
 * @param extensionType 扩展类型
 * @return 扩展列表
 */
QJsonArray ExtensionManager::getExtensionsByType(const QString& extensionType) const
{
    return m_extensions.value(extensionType, QJsonArray());
}

/**
 * @brief 获取所有扩展
 * @return 扩展映射表
 */
QMap<QString, QJsonArray> ExtensionManager::getAllExtensions() const
{
    return m_extensions;
}

/**
 * @brief 获取扩展目录
 * @param extensionType 扩展类型
 * @return 扩展目录路径
 */
QString ExtensionManager::getExtensionDir(const QString& extensionType) const
{
    return m_extensionDirs.value(extensionType, "");
}

/**
 * @brief 导出扩展配置
 * @param extensionType 扩展类型
 * @param filePath 导出文件路径
 * @return 是否导出成功
 */
bool ExtensionManager::exportExtensionConfig(const QString& extensionType, const QString& filePath)
{
    QJsonArray extensions = getExtensionsByType(extensionType);
    if (extensions.isEmpty()) {
        qWarning() << "没有找到指定类型的扩展:" << extensionType;
        return false;
    }

    QJsonObject exportObj;
    exportObj["type"] = extensionType;
    exportObj["extensions"] = extensions;
    exportObj["exportTime"] = QDateTime::currentDateTime().toString(Qt::ISODate);

    QJsonDocument doc(exportObj);
    QFile file(filePath);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "无法打开导出文件:" << filePath;
        return false;
    }

    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();

    qDebug() << "成功导出扩展配置:" << extensionType << "到:" << filePath;
    return true;
}

/**
 * @brief 导入扩展配置
 * @param filePath 导入文件路径
 * @return 是否导入成功
 */
bool ExtensionManager::importExtensionConfig(const QString& filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "无法打开导入文件:" << filePath;
        return false;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "导入文件解析错误:" << error.errorString();
        return false;
    }

    if (!doc.isObject()) {
        qWarning() << "导入文件格式错误，不是有效的JSON对象";
        return false;
    }

    QJsonObject importObj = doc.object();
    QString extensionType = importObj["type"].toString();
    QJsonArray extensions = importObj["extensions"].toArray();

    if (extensionType.isEmpty() || extensions.isEmpty()) {
        qWarning() << "导入文件格式错误，缺少必要字段";
        return false;
    }

    // 注册导入的扩展
    for (const QJsonValue& value : extensions) {
        if (value.isObject()) {
            QJsonObject extensionInfo = value.toObject();
            registerExtension(extensionType, extensionInfo);
        }
    }

    qDebug() << "成功导入扩展配置:" << extensionType << "从:" << filePath;
    return true;
}
