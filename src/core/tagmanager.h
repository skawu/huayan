#ifndef HYTAGMANAGER_H
#define HYTAGMANAGER_H

#include <QObject>
#include <QMap>
#include <QString>
#include <QVariant>
#include <QVector>
#include <QMutex>

/**
 * @file tagmanager.h
 * @brief 标签管理类头文件
 * 
 * 此类实现了标签的管理功能，包括标签的添加、删除、查询和值的更新等
 */

/**
 * @class HYTag
 * @brief 标签类
 * 
 * 表示一个工业数据标签，包含名称、组、值和描述等属性
 */
class HYTag : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString group READ group CONSTANT)
    Q_PROPERTY(QVariant value READ value NOTIFY valueChanged)
    Q_PROPERTY(QString description READ description CONSTANT)

public:
    /**
     * @brief 构造函数
     * @param parent 父对象
     */
    explicit HYTag(QObject *parent = nullptr);
    
    /**
     * @brief 构造函数
     * @param name 标签名称
     * @param group 标签组
     * @param value 标签值
     * @param description 标签描述
     * @param parent 父对象
     */
    HYTag(const QString &name, const QString &group, const QVariant &value, const QString &description = "", QObject *parent = nullptr);

    // Getters
    /**
     * @brief 获取标签名称
     * @return 标签名称
     */
    QString name() const;
    
    /**
     * @brief 获取标签组
     * @return 标签组
     */
    QString group() const;
    
    /**
     * @brief 获取标签值
     * @return 标签值
     */
    QVariant value() const;
    
    /**
     * @brief 获取标签描述
     * @return 标签描述
     */
    QString description() const;

    // Setter
    /**
     * @brief 设置标签值
     * @param value 新的标签值
     */
    void setValue(const QVariant &value);
    
    /**
     * @brief 设置标签描述
     * @param description 新的标签描述
     */
    void setDescription(const QString &description);

signals:
    /**
     * @brief 标签值变化信号
     * @param newValue 新的标签值
     */
    void valueChanged(const QVariant &newValue);

private:
    QString m_hyName; ///< 标签名称
    QString m_hyGroup; ///< 标签组
    QVariant m_hyValue; ///< 标签值
    QString m_hyDescription; ///< 标签描述
};

/**
 * @class HYTagManager
 * @brief 标签管理类
 * 
 * 负责管理所有标签，包括标签的添加、删除、查询和值的更新等功能
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

    // 标签管理
    /**
     * @brief 添加标签
     * @param name 标签名称
     * @param group 标签组
     * @param value 标签值
     * @param description 标签描述
     * @return 添加是否成功
     */
    bool addTag(const QString &name, const QString &group, const QVariant &value, const QString &description = "");
    
    /**
     * @brief 移除标签
     * @param name 标签名称
     * @return 移除是否成功
     */
    bool removeTag(const QString &name);
    
    /**
     * @brief 获取标签
     * @param name 标签名称
     * @return 标签指针
     */
    HYTag *getTag(const QString &name) const;
    
    /**
     * @brief 根据组获取标签
     * @param group 标签组
     * @return 标签列表
     */
    QVector<HYTag *> getTagsByGroup(const QString &group) const;
    
    /**
     * @brief 获取所有标签
     * @return 标签列表
     */
    QVector<HYTag *> getAllTags() const;
    
    /**
     * @brief 获取所有组
     * @return 组列表
     */
    QVector<QString> getGroups() const;

    // 标签值操作
    /**
     * @brief 设置标签值
     * @param name 标签名称
     * @param value 新的标签值
     * @return 设置是否成功
     */
    bool setTagValue(const QString &name, const QVariant &value);
    
    /**
     * @brief 获取标签值
     * @param name 标签名称
     * @return 标签值
     */
    QVariant getTagValue(const QString &name) const;

    // 标签绑定
    /**
     * @brief 将标签绑定到对象属性
     * @param tagName 标签名称
     * @param object 对象指针
     * @param propertyName 属性名称
     */
    void bindTagToProperty(const QString &tagName, QObject *object, const char *propertyName);
    
    /**
     * @brief 解除标签与对象属性的绑定
     * @param tagName 标签名称
     * @param object 对象指针
     * @param propertyName 属性名称
     */
    void unbindTagFromProperty(const QString &tagName, QObject *object, const char *propertyName);

signals:
    /**
     * @brief 标签添加信号
     * @param name 标签名称
     */
    void tagAdded(const QString &name);
    
    /**
     * @brief 标签移除信号
     * @param name 标签名称
     */
    void tagRemoved(const QString &name);
    
    /**
     * @brief 标签值变化信号
     * @param name 标签名称
     * @param newValue 新的标签值
     */
    void tagValueChanged(const QString &name, const QVariant &newValue);

private slots:
    /**
     * @brief 标签值变化槽函数
     * @param newValue 新的标签值
     */
    void onTagValueChanged(const QVariant &newValue);

private:
    QMap<QString, HYTag *> m_hyTags; ///< 标签映射表
    QMap<QString, QVector<HYTag *>> m_hyTagsByGroup; ///< 按组分类的标签映射表
    QMutex m_hyMutex; ///< 互斥锁

    // 绑定管理
    struct Binding {
        QObject *object; ///< 对象指针
        const char *propertyName; ///< 属性名称
    };
    QMap<QString, QVector<Binding>> m_hyBindings; ///< 标签绑定映射表
};

#endif // HYTAGMANAGER_H
