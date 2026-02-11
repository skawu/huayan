#ifndef CONFIGMANAGER_H
#define CONFIGMANAGER_H

#include <QObject>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFile>
#include <QDir>

/**
 * @class ConfigManager
 * @brief 配置管理器类
 * 
 * 负责加载、管理和保存应用程序配置，包括默认配置和用户配置
 * 实现异常兜底机制，当配置文件不存在或损坏时，自动使用默认配置
 */
class ConfigManager : public QObject
{
    Q_OBJECT

public:
    /**
     * @brief 获取配置管理器单例实例
     * @return 配置管理器实例
     */
    static ConfigManager* instance();

    /**
     * @brief 初始化配置管理器
     * @param parent 父对象
     */
    void initialize(QObject* parent = nullptr);

    /**
     * @brief 加载配置
     * @return 是否加载成功
     */
    bool loadConfig();

    /**
     * @brief 保存配置
     * @return 是否保存成功
     */
    bool saveConfig();

    /**
     * @brief 恢复默认配置
     * @return 是否恢复成功
     */
    bool restoreDefaultConfig();

    /**
     * @brief 获取当前配置
     * @return 当前配置对象
     */
    QJsonObject getConfig() const;

    /**
     * @brief 获取默认配置
     * @return 默认配置对象
     */
    QJsonObject getDefaultConfig() const;

    /**
     * @brief 获取配置值
     * @param key 配置键
     * @param defaultValue 默认值
     * @return 配置值
     */
    QVariant getValue(const QString& key, const QVariant& defaultValue = QVariant());

    /**
     * @brief 设置配置值
     * @param key 配置键
     * @param value 配置值
     */
    void setValue(const QString& key, const QVariant& value);

    /**
     * @brief 获取配置文件路径
     * @return 配置文件路径
     */
    QString getConfigFilePath() const;

    /**
     * @brief 获取默认配置文件路径
     * @return 默认配置文件路径
     */
    QString getDefaultConfigFilePath() const;

signals:
    /**
     * @brief 配置加载完成信号
     */
    void configLoaded();

    /**
     * @brief 配置保存完成信号
     */
    void configSaved();

    /**
     * @brief 配置恢复完成信号
     */
    void configRestored();

private:
    /**
     * @brief 构造函数
     * @param parent 父对象
     */
    explicit ConfigManager(QObject* parent = nullptr);

    /**
     * @brief 析构函数
     */
    ~ConfigManager();

    /**
     * @brief 加载默认配置文件
     * @return 默认配置对象
     */
    QJsonObject loadDefaultConfigFile();

    /**
     * @brief 加载用户配置文件
     * @return 用户配置对象
     */
    QJsonObject loadUserConfigFile();

    /**
     * @brief 确保配置目录存在
     */
    void ensureConfigDirExists();

private:
    static ConfigManager* m_instance; ///< 单例实例
    QJsonObject m_config; ///< 当前配置
    QJsonObject m_defaultConfig; ///< 默认配置
    QString m_configFilePath; ///< 配置文件路径
    QString m_defaultConfigFilePath; ///< 默认配置文件路径
    bool m_initialized; ///< 是否初始化
};

#endif // CONFIGMANAGER_H
