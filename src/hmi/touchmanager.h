#ifndef TOUCHMANAGER_H
#define TOUCHMANAGER_H

#include <QObject>
#include <QPointF>
#include <QTimer>
#include <QMap>

class TouchManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool touchEnabled READ touchEnabled WRITE setTouchEnabled NOTIFY touchEnabledChanged)
    Q_PROPERTY(int longPressThreshold READ longPressThreshold WRITE setLongPressThreshold NOTIFY longPressThresholdChanged)

public:
    explicit TouchManager(QObject *parent = nullptr);
    ~TouchManager();

    // 触摸管理
    Q_INVOKABLE void touchStarted(int touchId, const QPointF &position);
    Q_INVOKABLE void touchMoved(int touchId, const QPointF &position);
    Q_INVOKABLE void touchEnded(int touchId, const QPointF &position);
    Q_INVOKABLE void touchCanceled(int touchId);

    // 配置
    bool touchEnabled() const;
    void setTouchEnabled(bool enabled);

    int longPressThreshold() const;
    void setLongPressThreshold(int threshold);

    Q_INVOKABLE void setDragThreshold(int threshold);
    Q_INVOKABLE int dragThreshold() const;

    Q_INVOKABLE void setDoubleTapThreshold(int threshold);
    Q_INVOKABLE int doubleTapThreshold() const;

signals:
    void touchEnabledChanged();
    void longPressThresholdChanged();
    void longPressDetected(int touchId, const QPointF &position);
    void dragStarted(int touchId, const QPointF &startPosition);
    void dragMoved(int touchId, const QPointF &position, const QPointF &delta);
    void dragEnded(int touchId, const QPointF &endPosition);
    void tapDetected(int touchId, const QPointF &position);
    void doubleTapDetected(int touchId, const QPointF &position);

private slots:
    void checkLongPress(int touchId);

private:
    // 触摸点状态
    struct TouchPoint {
        QPointF startPosition;
        QPointF currentPosition;
        QTimer *longPressTimer;
        bool isLongPress;
        bool isDragging;
        qint64 startTime;
        qint64 lastTapTime;
    };

    QMap<int, TouchPoint> m_touchPoints;
    bool m_touchEnabled;
    int m_longPressThreshold; // 长按阈值（毫秒）
    int m_dragThreshold; // 拖拽阈值（像素）
    int m_doubleTapThreshold; // 双击阈值（毫秒）
};

#endif // TOUCHMANAGER_H
