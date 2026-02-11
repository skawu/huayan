#ifndef EXTENSIONMANAGER_H
#define EXTENSIONMANAGER_H

#include <QObject>
#include <QMap>
#include <QString>
#include <QDir>
#include <QPluginLoader>
#include <QJsonObject>
#include <QJsonArray>

/**
 * @class ExtensionManager
 * @brief 扩展管理器类
 * 
 * 负责管理所有扩展模块，包括组态组件、行业模板、硬件驱动和集成接口
 * 支持"插拔式"扩展，新增模块无需修改核心代码，仅需按规范放入指定目录即可加载
 */
class ExtensionManager : public QObject
{
    Q_OBJECT

public:
    /**
     * @brief 获取扩展管理器单例实例
     * @return 扩展管理器实例
     */
    static ExtensionManager* instance();

    /**
     * @brief 初始化扩展管理器
     * @param parent 父对象
     */
    void initialize(QObject* parent = nullptr);

    /**
     * @brief 加载所有扩展
     */
    void loadExtensions();

    /**
     * @brief 加载指定类型的扩展
     * @param extensionType 扩展类型
     */
    void loadExtensionsByType(const QString& extensionType);

    /**
     * @brief 获取指定类型的所有扩展
     * @param extensionType 扩展类型
     * @return 扩展列表
     */
    QJsonArray getExtensionsByType(const QString& extensionType) const;

    /**
     * @brief 获取所有扩展
     * @return 扩展映射表
     */
    QMap<QString, QJsonArray> getAllExtensions() const;

    /**
     * @brief 获取扩展目录
     * @param extensionType 扩展类型
     * @return 扩展目录路径
     */
    QString getExtensionDir(const QString& extensionType) const;

    /**
     * @brief 注册新扩展
     * @param extensionType 扩展类型
     * @param extensionInfo 扩展信息
     */
    void registerExtension(const QString& extensionType, const QJsonObject& extensionInfo);

    /**
     * @brief 导出扩展配置
     * @param extensionType 扩展类型
     * @param filePath 导出文件路径
     * @return 是否导出成功
     */
    bool exportExtensionConfig(const QString& extensionType, const QString& filePath);

    /**
     * @brief 导入扩展配置
     * @param filePath 导入文件路径
     * @return 是否导入成功
     */
    bool importExtensionConfig(const QString& filePath);

signals:
    /**
     * @brief 扩展加载完成信号
     */
    void extensionsLoaded();

    /**
     * @brief 扩展注册完成信号
     * @param extensionType 扩展类型
     * @param extensionName 扩展名称
     */
    void extensionRegistered(const QString& extensionType, const QString& extensionName);

private:
    /**
     * @brief 构造函数
     * @param parent 父对象
     */
    explicit ExtensionManager(QObject* parent = nullptr);

    /**
     * @brief 析构函数
     */
    ~ExtensionManager();

    /**
     * @brief 确保扩展目录存在
     * @param extensionType 扩展类型
     */
    void ensureExtensionDirExists(const QString& extensionType);

    /**
     * @brief 扫描扩展目录
     * @param extensionType 扩展类型
     */
    void scanExtensionDir(const QString& extensionType);

    /**
     * @brief 加载扩展插件
     * @param pluginPath 插件路径
     * @param extensionType 扩展类型
     */
    void loadExtensionPlugin(const QString& pluginPath, const QString& extensionType);

    /**
     * @brief 加载扩展配置文件
     * @param configPath 配置文件路径
     * @param extensionType 扩展类型
     */
    void loadExtensionConfig(const QString& configPath, const QString& extensionType);

private:
    static ExtensionManager* m_instance; ///< 单例实例
    QMap<QString, QJsonArray> m_extensions; ///< 扩展映射表，键为扩展类型，值为扩展列表
    QMap<QString, QString> m_extensionDirs; ///< 扩展目录映射表
    QMap<QString, QPluginLoader*> m_pluginLoaders; ///< 插件加载器映射表
    bool m_initialized; ///< 是否初始化
};

#endif // EXTENSIONMANAGER_H
