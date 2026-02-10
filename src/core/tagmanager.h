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
};

#endif // HYTAGMANAGER_H
