#ifndef TAGMANAGER_H
#define TAGMANAGER_H

#include <QObject>
#include <QTimer>
#include <QMap>
#include <QVariant>
#include <QString>
#include <QDateTime>

/**
 * @brief 标签管理器
 * 
 * 负责管理SCADA系统中的所有数据标签点
 * 提供标签注册、更新、查询等功能
 */
class TagManager : public QObject
{
    Q_OBJECT

public:
    explicit TagManager(QObject *parent = nullptr);
    ~TagManager();

    /**
     * @brief 标签信息结构体
     */
    struct TagInfo {
        QString name;           ///< 标签名
        QVariant value;         ///< 当前值
        QString dataType;       ///< 数据类型
        QDateTime lastUpdate;   ///< 最后更新时间
        bool isValid;           ///< 是否有效
        QString description;    ///< 描述信息
    };

    // ==================== 标签管理 ====================
    
    /**
     * @brief 注册新标签
     */
    Q_INVOKABLE bool registerTag(const QString &name, const QString &dataType = "double");
    
    /**
     * @brief 更新标签值
     */
    Q_INVOKABLE bool updateTagValue(const QString &name, const QVariant &value);
    
    /**
     * @brief 获取标签值
     */
    Q_INVOKABLE QVariant getTagValue(const QString &name) const;
    
    /**
     * @brief 获取标签信息
     */
    Q_INVOKABLE QVariantMap getTagInfo(const QString &name) const;
    
    /**
     * @brief 检查标签是否存在
     */
    Q_INVOKABLE bool hasTag(const QString &name) const;
    
    /**
     * @brief 获取所有标签名
     */
    Q_INVOKABLE QStringList getAllTags() const;

    // ==================== 信号 ====================
signals:
    /**
     * @brief 标签值改变信号
     */
    void tagValueChanged(const QString &name, const QVariant &newValue);
    
    /**
     * @brief 标签添加信号
     */
    void tagAdded(const QString &name);
    
    /**
     * @brief 标签移除信号
     */
    void tagRemoved(const QString &name);

private slots:
    /**
     * @brief 模拟数据更新定时器槽函数
     */
    void simulateDataUpdate();

private:
    QMap<QString, TagInfo> m_tags;      ///< 标签映射表
    QTimer *m_simulationTimer;          ///< 模拟数据定时器
};

#endif // TAGMANAGER_H