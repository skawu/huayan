#ifndef DPOINTBINDER_H
#define DPOINTBINDER_H

#include <QObject>
#include <QMap>
#include <QString>
#include <QColor>
#include <Qt3DCore/QEntity>

class DPointBinder : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int boundPointCount READ boundPointCount NOTIFY boundPointCountChanged)

public:
    explicit DPointBinder(QObject *parent = nullptr);
    ~DPointBinder();

    // 设备状态枚举
    enum DeviceStatus {
        Normal,
        Warning,
        Error,
        Offline
    };
    Q_ENUM(DeviceStatus)

    // 绑定点位到节点
    Q_INVOKABLE void bindTagToNode(const QString &tagName, Qt3DCore::QEntity *node);
    
    // 解绑点位
    Q_INVOKABLE void unbindTagFromNode(const QString &tagName);
    
    // 更新点位值
    Q_INVOKABLE void updatePointValue(const QString &tagName, float value);
    
    // 批量更新点位值
    Q_INVOKABLE void updatePointValues(const QMap<QString, float> &pointValues);
    
    // 获取节点颜色
    Q_INVOKABLE QColor getNodeColor(const QString &tagName) const;
    
    // 获取节点状态
    Q_INVOKABLE DeviceStatus getNodeStatus(const QString &tagName) const;
    
    // 获取绑定的点位数量
    int boundPointCount() const;

    // 状态对应的颜色
    static QColor colorForStatus(DeviceStatus status);
    
    // 从值获取状态
    static DeviceStatus statusFromValue(float value);

signals:
    void boundPointCountChanged();
    void nodeStatusChanged(const QString &tagName, DeviceStatus status, QColor color);
    void nodeClicked(const QString &tagName, DeviceStatus status, float value);

private:
    // 节点绑定结构体
    struct NodeBinding {
        Qt3DCore::QEntity *node;
        float currentValue;
        DeviceStatus status;
        QColor color;
    };

    // 点位到节点的映射
    QMap<QString, NodeBinding> m_tagToNodeMap;
    
    // 更新节点状态
    void updateNodeStatus(const QString &tagName, float value);
};

#endif // DPOINTBINDER_H
