#include "3dpointbinder.h"
#include <Qt3DExtras/QPhongMaterial>
#include <Qt3DRender/QMaterial>

DPointBinder::DPointBinder(QObject *parent) : QObject(parent)
{}

DPointBinder::~DPointBinder()
{}

void DPointBinder::bindTagToNode(const QString &tagName, Qt3DCore::QEntity *node)
{
    if (!node) {
        qWarning() << "Cannot bind to null node";
        return;
    }

    // 创建新的绑定
    NodeBinding binding;
    binding.node = node;
    binding.currentValue = 0.0f;
    binding.status = Normal;
    binding.color = colorForStatus(Normal);

    // 保存绑定
    m_tagToNodeMap[tagName] = binding;

    // 更新节点颜色
    updateNodeStatus(tagName, 0.0f);

    emit boundPointCountChanged();
}

void DPointBinder::unbindTagFromNode(const QString &tagName)
{
    if (m_tagToNodeMap.contains(tagName)) {
        m_tagToNodeMap.remove(tagName);
        emit boundPointCountChanged();
    }
}

void DPointBinder::updatePointValue(const QString &tagName, float value)
{
    if (m_tagToNodeMap.contains(tagName)) {
        updateNodeStatus(tagName, value);
    }
}

void DPointBinder::updatePointValues(const QMap<QString, float> &pointValues)
{
    for (auto it = pointValues.constBegin(); it != pointValues.constEnd(); ++it) {
        const QString &tagName = it.key();
        float value = it.value();
        updatePointValue(tagName, value);
    }
}

QColor DPointBinder::getNodeColor(const QString &tagName) const
{
    if (m_tagToNodeMap.contains(tagName)) {
        return m_tagToNodeMap[tagName].color;
    }
    return Qt::gray;
}

DPointBinder::DeviceStatus DPointBinder::getNodeStatus(const QString &tagName) const
{
    if (m_tagToNodeMap.contains(tagName)) {
        return m_tagToNodeMap[tagName].status;
    }
    return Offline;
}

int DPointBinder::boundPointCount() const
{
    return m_tagToNodeMap.size();
}

QColor DPointBinder::colorForStatus(DeviceStatus status)
{
    switch (status) {
    case Normal:
        return Qt::green;
    case Warning:
        return Qt::yellow;
    case Error:
        return Qt::red;
    case Offline:
        return Qt::gray;
    default:
        return Qt::gray;
    }
}

DPointBinder::DeviceStatus DPointBinder::statusFromValue(float value)
{
    // 根据值判断状态
    // 这里使用简单的阈值判断，实际项目中应根据具体业务逻辑调整
    if (value < 0.1f) {
        return Offline;
    } else if (value < 0.5f) {
        return Normal;
    } else if (value < 0.8f) {
        return Warning;
    } else {
        return Error;
    }
}

void DPointBinder::updateNodeStatus(const QString &tagName, float value)
{
    if (!m_tagToNodeMap.contains(tagName)) {
        return;
    }

    NodeBinding &binding = m_tagToNodeMap[tagName];
    binding.currentValue = value;

    // 计算新状态
    DeviceStatus newStatus = statusFromValue(value);
    QColor newColor = colorForStatus(newStatus);

    // 如果状态或颜色发生变化，更新节点
    if (newStatus != binding.status || newColor != binding.color) {
        binding.status = newStatus;
        binding.color = newColor;

        // 更新节点材质颜色
        if (binding.node) {
            for (auto component : binding.node->components()) {
                if (auto material = qobject_cast<Qt3DExtras::QPhongMaterial *>(component)) {
                    material->setDiffuse(newColor);
                    break;
                }
            }
        }

        emit nodeStatusChanged(tagName, newStatus, newColor);
    }
}
