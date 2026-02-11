#ifndef HYTAGMANAGER_H
#define HYTAGMANAGER_H

#include <QObject>
#include <QMap>
#include <QString>
#include <QVariant>
#include <QVector>
#include <QMutex>
#include <QTimer>
#include <QSet>
#include <QDateTime>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDir>

/**
 * @file tagmanager.h
 * @brief Huayan点位管理系统核心类
 * 
 * 此类实现了Huayan点位管理系统的核心功能，包括点位的添加、删除、查询和值的更新等
 * 支持OPC UA/MQTT/Modbus等数据源的点位绑定
 * 优化了事件通知机制，减少不必要的信号发射
 */

/**
 * @class HYTag
 * @brief 点位类
 * 
 * 表示一个工业数据点位，包含名称、组、值和描述等属性
 */
class HYTag : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString group READ group CONSTANT)
    Q_PROPERTY(QVariant value READ value NOTIFY valueChanged)
    Q_PROPERTY(QString description READ description CONSTANT)
    Q_PROPERTY(QString source READ source CONSTANT)

public:
    /**
     * @brief 构造函数
     * @param parent 父对象
     */
    explicit HYTag(QObject *parent = nullptr);
    
    /**
     * @brief 构造函数
     * @param name 点位名称
     * @param group 点位组
     * @param value 点位值
     * @param description 点位描述
     * @param source 数据来源
     * @param parent 父对象
     */
    HYTag(const QString &name, const QString &group, const QVariant &value, 
          const QString &description = "", const QString &source = "", QObject *parent = nullptr);

    // Getters
    /**
     * @brief 获取点位名称
     * @return 点位名称
     */
    QString name() const;
    
    /**
     * @brief 获取点位组
     * @return 点位组
     */
    QString group() const;
    
    /**
     * @brief 获取点位值
     * @return 点位值
     */
    QVariant value() const;
    
    /**
     * @brief 获取点位描述
     * @return 点位描述
     */
    QString description() const;
    
    /**
     * @brief 获取数据来源
     * @return 数据来源
     */
    QString source() const;

    // Setter
    /**
     * @brief 设置点位值
     * @param value 新的点位值
     */
    void setValue(const QVariant &value);
    
    /**
     * @brief 设置点位描述
     * @param description 新的点位描述
     */
    void setDescription(const QString &description);
    
    /**
     * @brief 设置是否启用信号发射
     * @param enabled 是否启用
     */
    void setSignalEnabled(bool enabled);

signals:
    /**
     * @brief 点位值变化信号
     * @param newValue 新的点位值
     */
    void valueChanged(const QVariant &newValue);

private:
    QString m_hyName; ///< 点位名称
    QString m_hyGroup; ///< 点位组
    QVariant m_hyValue; ///< 点位值
    QString m_hyDescription; ///< 点位描述
    QString m_hySource; ///< 数据来源
    bool m_hySignalEnabled; ///< 是否启用信号发射
};

/**
 * @class HYTagManager
 * @brief 点位管理类
 * 
 * 负责管理所有点位，包括点位的添加、删除、查询和值的更新等功能
 * 是Huayan点位管理系统的核心类
 * 优化了事件通知机制，减少不必要的信号发射
 */
class HYTagManager : public QObject
{
    Q_OBJECT

public:
    /**
     * @brief 构造函数
     * @param parent 父对象
     */
    explicit HYTagManager(QObject *parent = nullptr);
    
    /**
     * @brief 析构函数
     */
    ~HYTagManager();

    // 点位管理
    /**
     * @brief 添加点位
     * @param name 点位名称
     * @param group 点位组
     * @param value 点位值
     * @param description 点位描述
     * @param source 数据来源
     * @return 添加是否成功
     */
    bool addTag(const QString &name, const QString &group, const QVariant &value, 
                const QString &description = "", const QString &source = "");
    
    /**
     * @brief 移除点位
     * @param name 点位名称
     * @return 移除是否成功
     */
    bool removeTag(const QString &name);
    
    /**
     * @brief 获取点位
     * @param name 点位名称
     * @return 点位指针
     */
    HYTag *getTag(const QString &name) const;
    
    /**
     * @brief 根据组获取点位
     * @param group 点位组
     * @return 点位列表
     */
    QVector<HYTag *> getTagsByGroup(const QString &group) const;
    
    /**
     * @brief 获取所有点位
     * @return 点位列表
     */
    QVector<HYTag *> getAllTags() const;
    
    /**
     * @brief 获取所有组
     * @return 组列表
     */
    QVector<QString> getGroups() const;

    // 点位值操作
    /**
     * @brief 设置点位值
     * @param name 点位名称
     * @param value 新的点位值
     * @return 设置是否成功
     */
    bool setTagValue(const QString &name, const QVariant &value);
    
    /**
     * @brief 批量设置点位值
     * @param values 点位名称和值的映射
     * @return 设置是否成功
     */
    bool setTagValues(const QMap<QString, QVariant> &values);
    
    /**
     * @brief 获取点位值
     * @param name 点位名称
     * @return 点位值
     */
    QVariant getTagValue(const QString &name) const;

    // 点位绑定
    /**
     * @brief 将点位绑定到对象属性
     * @param tagName 点位名称
     * @param object 对象指针
     * @param propertyName 属性名称
     */
    void bindTagToProperty(const QString &tagName, QObject *object, const char *propertyName);
    
    /**
     * @brief 解除点位与对象属性的绑定
     * @param tagName 点位名称
     * @param object 对象指针
     * @param propertyName 属性名称
     */
    void unbindTagFromProperty(const QString &tagName, QObject *object, const char *propertyName);
    
    /**
     * @brief 设置延迟通知
     * @param enabled 是否启用
     * @param interval 延迟间隔（毫秒）
     */
    void setDelayedNotification(bool enabled, int interval = 50);
    
    /**
     * @brief 设置标签的重要性
     * @param tagName 标签名称
     * @param important 是否重要
     */
    void setTagImportant(const QString &tagName, bool important);

    // 性能优化方法
    /**
     * @brief 批量添加点位
     * @param tags 点位信息列表
     * @return 添加是否成功
     */
    bool addTags(const QVector<QMap<QString, QVariant>> &tags);
    
    /**
     * @brief 启用批量更新模式
     * @param enabled 是否启用
     */
    void setBatchUpdateMode(bool enabled);
    
    /**
     * @brief 设置批量更新间隔
     * @param interval 间隔（毫秒）
     */
    void setBatchUpdateInterval(int interval);
    
    /**
     * @brief 优化点位值更新，减少信号发射
     * @param values 点位名称和值的映射
     * @param immediate 是否立即通知
     * @return 设置是否成功
     */
    bool setTagValuesOptimized(const QMap<QString, QVariant> &values, bool immediate = false);

    // 历史数据存储
    /**
     * @brief 启用历史数据存储
     * @param enabled 是否启用
     * @param interval 存储间隔（毫秒）
     * @param retentionDays 保留天数
     */
    void enableHistoryStorage(bool enabled, int interval = 1000, int retentionDays = 365);
    
    /**
     * @brief 获取历史数据
     * @param tagName 点位名称
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 历史数据列表
     */
    QVector<QPair<QDateTime, QVariant>> getHistoricalData(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime);
    
    /**
     * @brief 清理历史数据
     * @param days 保留天数
     */
    void cleanHistoricalData(int days = 365);

    // 断点续传
    /**
     * @brief 启用断点续传
     * @param enabled 是否启用
     * @param persistFilePath 续传文件路径
     */
    void enablePersistence(bool enabled, const QString &persistFilePath = "");
    
    /**
     * @brief 保存点位状态
     */
    void saveState();
    
    /**
     * @brief 加载点位状态
     */
    void loadState();

    // 离线能力
    /**
     * @brief 设置离线模式
     * @param offline 是否离线
     */
    void setOfflineMode(bool offline);
    
    /**
     * @brief 获取离线模式状态
     * @return 是否离线
     */
    bool isOfflineMode() const;
    
    /**
     * @brief 同步离线数据
     */
    void syncOfflineData();
    
    /**
     * @brief 设置同步间隔
     * @param interval 同步间隔（毫秒）
     */
    void setSyncInterval(int interval);

signals:
    /**
     * @brief 点位添加信号
     * @param name 点位名称
     */
    void tagAdded(const QString &name);
    
    /**
     * @brief 点位移除信号
     * @param name 点位名称
     */
    void tagRemoved(const QString &name);
    
    /**
     * @brief 点位值变化信号
     * @param name 点位名称
     * @param newValue 新的点位值
     */
    void tagValueChanged(const QString &name, const QVariant &newValue);
    
    /**
     * @brief 批量点位值变化信号
     * @param values 点位名称和值的映射
     */
    void tagValuesChanged(const QMap<QString, QVariant> &values);
    
    /**
     * @brief 离线模式切换信号
     * @param offline 是否离线
     */
    void offlineModeChanged(bool offline);
    
    /**
     * @brief 数据同步完成信号
     * @param success 是否成功
     * @param count 同步的数据条数
     */
    void syncCompleted(bool success, int count);

private slots:
    /**
     * @brief 点位值变化槽函数
     * @param newValue 新的点位值
     */
    void onTagValueChanged(const QVariant &newValue);
    
    /**
     * @brief 延迟通知槽函数
     */
    void onDelayedNotification();
    
    /**
     * @brief 历史数据存储槽函数
     */
    void onHistoryStorage();
    
    /**
     * @brief 同步离线数据槽函数
     */
    void onSyncOfflineData();

private:
    QMap<QString, HYTag *> m_hyTags; ///< 点位映射表
    QMap<QString, QVector<HYTag *>> m_hyTagsByGroup; ///< 按组分类的点位映射表
    QMutex m_hyMutex; ///< 互斥锁

    // 绑定管理
    struct Binding {
        QObject *object; ///< 对象指针
        const char *propertyName; ///< 属性名称
    };
    QMap<QString, QVector<Binding>> m_hyBindings; ///< 点位绑定映射表
    
    // 延迟通知管理
    bool m_hyDelayedNotification; ///< 是否启用延迟通知
    int m_hyNotificationInterval; ///< 延迟通知间隔
    QTimer *m_hyNotificationTimer; ///< 延迟通知定时器
    QMap<QString, QVariant> m_hyPendingValues; ///< 待通知的点位值
    QSet<QString> m_hyImportantTags; ///< 重要点位集合

    // 历史数据存储
    QSqlDatabase m_hyDatabase; ///< 数据库连接
    bool m_hyHistoryEnabled; ///< 是否启用历史数据存储
    int m_hyHistoryInterval; ///< 历史数据存储间隔（毫秒）
    QTimer *m_hyHistoryTimer; ///< 历史数据存储定时器
    int m_hyHistoryRetentionDays; ///< 历史数据保留天数

    // 断点续传
    bool m_hyPersistEnabled; ///< 是否启用断点续传
    QString m_hyPersistFilePath; ///< 断点续传文件路径

    // 离线能力
    bool m_hyOfflineMode; ///< 是否处于离线模式
    QMap<QString, QVector<QPair<QDateTime, QVariant>>> m_hyOfflineData; ///< 离线数据缓存
    QTimer *m_hySyncTimer; ///< 同步定时器
    int m_hySyncInterval; ///< 同步间隔（毫秒）
};

#endif // HYTAGMANAGER_H
