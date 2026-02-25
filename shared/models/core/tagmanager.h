#ifndef TAGMANAGER_H
#define TAGMANAGER_H

#include <QObject>
#include <QVariant>
#include <QHash>
#include <QString>
#include <QTimer>

/**
 * @brief 标签管理器 - SCADA系统的核心数据管理组件
 * 
 * 负责管理所有的数据标签，提供统一的数据访问接口，
 * 支持实时数据更新和订阅机制。
 */
class TagManager : public QObject
{
    Q_OBJECT

public:
    /**
     * @brief 标签数据结构
     */
    struct TagData {
        QString name;           ///< 标签名称
        QVariant value;         ///< 当前值
        QString description;    ///< 描述信息
        QString address;        ///< 设备地址
        bool isConnected;       ///< 连接状态
        QDateTime lastUpdate;   ///< 最后更新时间
        QVariant minValue;      ///< 最小值限制
        QVariant maxValue;      ///< 最大值限制
    };

    explicit TagManager(QObject *parent = nullptr);
    ~TagManager();

    /**
     * @brief 添加标签
     * @param name 标签名称
     * @param initialValue 初始值
     * @param description 描述信息
     */
    Q_INVOKABLE bool addTag(const QString& name, const QVariant& initialValue = QVariant(), 
                           const QString& description = QString());

    /**
     * @brief 删除标签
     * @param name 标签名称
     */
    Q_INVOKABLE bool removeTag(const QString& name);

    /**
     * @brief 获取标签值
     * @param name 标签名称
     * @return 标签值，如果标签不存在则返回无效值
     */
    Q_INVOKABLE QVariant getTagValue(const QString& name) const;

    /**
     * @brief 设置标签值
     * @param name 标签名称
     * @param value 新值
     * @return 是否设置成功
     */
    Q_INVOKABLE bool setTagValue(const QString& name, const QVariant& value);

    /**
     * @brief 检查标签是否存在
     * @param name 标签名称
     * @return 是否存在
     */
    Q_INVOKABLE bool hasTag(const QString& name) const;

    /**
     * @brief 获取所有标签名称
     * @return 标签名称列表
     */
    Q_INVOKABLE QStringList getAllTagNames() const;

    /**
     * @brief 绑定标签到设备地址
     * @param tagName 标签名称
     * @param deviceAddress 设备地址
     */
    Q_INVOKABLE void bindTagToDevice(const QString& tagName, const QString& deviceAddress);

    /**
     * @brief 获取标签完整信息
     * @param name 标签名称
     * @return 标签数据结构
     */
    Q_INVOKABLE QVariantMap getTagInfo(const QString& name) const;

signals:
    /**
     * @brief 标签值变化信号
     * @param tagName 标签名称
     * @param newValue 新值
     * @param oldValue 旧值
     */
    void tagValueChanged(const QString& tagName, const QVariant& newValue, const QVariant& oldValue);

    /**
     * @brief 标签添加信号
     * @param tagName 标签名称
     */
    void tagAdded(const QString& tagName);

    /**
     * @brief 标签删除信号
     * @param tagName 标签名称
     */
    void tagRemoved(const QString& tagName);

    /**
     * @brief 连接状态变化信号
     * @param tagName 标签名称
     * @param isConnected 是否连接
     */
    void connectionStatusChanged(const QString& tagName, bool isConnected);

public slots:
    /**
     * @brief 更新标签值（内部使用）
     * @param tagName 标签名称
     * @param value 新值
     */
    void updateTagValueInternal(const QString& tagName, const QVariant& value);

    /**
     * @brief 设置连接状态
     * @param tagName 标签名称
     * @param connected 是否连接
     */
    void setConnectionStatus(const QString& tagName, bool connected);

private:
    QHash<QString, TagData> m_tags;     ///< 标签存储
    QTimer* m_updateTimer;              ///< 更新定时器
    int m_updateInterval;               ///< 更新间隔（毫秒）

    /**
     * @brief 验证标签值是否在有效范围内
     * @param tagData 标签数据
     * @param value 待验证的值
     * @return 是否有效
     */
    bool validateTagValue(const TagData& tagData, const QVariant& value) const;

    /**
     * @brief 发送标签变化通知
     * @param tagName 标签名称
     * @param newValue 新值
     * @param oldValue 旧值
     */
    void notifyTagChange(const QString& tagName, const QVariant& newValue, const QVariant& oldValue);
};

#endif // TAGMANAGER_H