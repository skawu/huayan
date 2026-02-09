#include "touchmanager.h"
#include <QDateTime>

TouchManager::TouchManager(QObject *parent) : QObject(parent)
{
    m_touchEnabled = true;
    m_longPressThreshold = 500; // 默认500ms长按阈值
    m_dragThreshold = 10; // 默认10像素拖拽阈值
    m_doubleTapThreshold = 300; // 默认300ms双击阈值
}

TouchManager::~TouchManager()
{
    // 清理所有触摸点
    for (auto it = m_touchPoints.begin(); it != m_touchPoints.end(); ++it) {
        if (it.value().longPressTimer) {
            delete it.value().longPressTimer;
        }
    }
    m_touchPoints.clear();
}

void TouchManager::touchStarted(int touchId, const QPointF &position)
{
    if (!m_touchEnabled) {
        return;
    }

    // 创建新的触摸点
    TouchPoint touchPoint;
    touchPoint.startPosition = position;
    touchPoint.currentPosition = position;
    touchPoint.isLongPress = false;
    touchPoint.isDragging = false;
    touchPoint.startTime = QDateTime::currentMSecsSinceEpoch();
    touchPoint.lastTapTime = 0;

    // 创建长按定时器
    touchPoint.longPressTimer = new QTimer(this);
    touchPoint.longPressTimer->setSingleShot(true);
    touchPoint.longPressTimer->setInterval(m_longPressThreshold);

    // 连接定时器信号
    connect(touchPoint.longPressTimer, &QTimer::timeout, this, [=]() {
        checkLongPress(touchId);
    });

    // 启动定时器
    touchPoint.longPressTimer->start();

    // 保存触摸点
    m_touchPoints[touchId] = touchPoint;
}

void TouchManager::touchMoved(int touchId, const QPointF &position)
{
    if (!m_touchEnabled || !m_touchPoints.contains(touchId)) {
        return;
    }

    TouchPoint &touchPoint = m_touchPoints[touchId];
    QPointF delta = position - touchPoint.currentPosition;

    // 更新当前位置
    touchPoint.currentPosition = position;

    // 检查是否已经是长按
    if (touchPoint.isLongPress) {
        // 长按状态下的移动
        return;
    }

    // 检查是否已经是拖拽
    if (touchPoint.isDragging) {
        // 发送拖拽移动信号
        emit dragMoved(touchId, position, delta);
        return;
    }

    // 检查是否达到拖拽阈值
    QPointF distance = position - touchPoint.startPosition;
    if (distance.manhattanLength() > m_dragThreshold) {
        // 取消长按定时器
        if (touchPoint.longPressTimer && touchPoint.longPressTimer->isActive()) {
            touchPoint.longPressTimer->stop();
        }

        // 标记为拖拽状态
        touchPoint.isDragging = true;

        // 发送拖拽开始信号
        emit dragStarted(touchId, touchPoint.startPosition);
        emit dragMoved(touchId, position, delta);
    }
}

void TouchManager::touchEnded(int touchId, const QPointF &position)
{
    if (!m_touchEnabled || !m_touchPoints.contains(touchId)) {
        return;
    }

    TouchPoint &touchPoint = m_touchPoints[touchId];

    // 取消长按定时器
    if (touchPoint.longPressTimer) {
        touchPoint.longPressTimer->stop();
        delete touchPoint.longPressTimer;
        touchPoint.longPressTimer = nullptr;
    }

    // 检查是否是拖拽结束
    if (touchPoint.isDragging) {
        emit dragEnded(touchId, position);
    }
    // 检查是否是单击
    else if (!touchPoint.isLongPress) {
        qint64 currentTime = QDateTime::currentMSecsSinceEpoch();
        qint64 timeSinceLastTap = currentTime - touchPoint.lastTapTime;

        // 检查是否是双击
        if (timeSinceLastTap < m_doubleTapThreshold) {
            emit doubleTapDetected(touchId, position);
            touchPoint.lastTapTime = 0;
        } else {
            emit tapDetected(touchId, position);
            touchPoint.lastTapTime = currentTime;
        }
    }

    // 移除触摸点
    m_touchPoints.remove(touchId);
}

void TouchManager::touchCanceled(int touchId)
{
    if (!m_touchPoints.contains(touchId)) {
        return;
    }

    TouchPoint &touchPoint = m_touchPoints[touchId];

    // 取消长按定时器
    if (touchPoint.longPressTimer) {
        touchPoint.longPressTimer->stop();
        delete touchPoint.longPressTimer;
        touchPoint.longPressTimer = nullptr;
    }

    // 移除触摸点
    m_touchPoints.remove(touchId);
}

void TouchManager::checkLongPress(int touchId)
{
    if (!m_touchPoints.contains(touchId)) {
        return;
    }

    TouchPoint &touchPoint = m_touchPoints[touchId];

    // 检查是否已经是拖拽
    if (touchPoint.isDragging) {
        return;
    }

    // 标记为长按
    touchPoint.isLongPress = true;

    // 发送长按信号
    emit longPressDetected(touchId, touchPoint.startPosition);
}

bool TouchManager::touchEnabled() const
{
    return m_touchEnabled;
}

void TouchManager::setTouchEnabled(bool enabled)
{
    if (m_touchEnabled != enabled) {
        m_touchEnabled = enabled;
        emit touchEnabledChanged();
    }
}

int TouchManager::longPressThreshold() const
{
    return m_longPressThreshold;
}

void TouchManager::setLongPressThreshold(int threshold)
{
    if (m_longPressThreshold != threshold) {
        m_longPressThreshold = threshold;
        emit longPressThresholdChanged();
    }
}

void TouchManager::setDragThreshold(int threshold)
{
    m_dragThreshold = threshold;
}

int TouchManager::dragThreshold() const
{
    return m_dragThreshold;
}

void TouchManager::setDoubleTapThreshold(int threshold)
{
    m_doubleTapThreshold = threshold;
}

int TouchManager::doubleTapThreshold() const
{
    return m_doubleTapThreshold;
}
