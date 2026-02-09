#include "chartdatamodel.h"
#include <QFile>
#include <QTextStream>
#include <QDateTime>

/**
 * @file chartdatamodel.cpp
 * @brief 图表数据模型实现
 * 
 * 实现了ChartDataModel类的核心功能，支持8个指标同屏展示
 * 提供数据缓存、历史数据加载和实时数据更新功能
 * 支持时间轴筛选和数据导出
 */

ChartDataModel::ChartDataModel(HYTagManager *tagManager, QObject *parent) 
    : QAbstractTableModel(parent),
      m_tagManager(tagManager),
      m_dataPoints(),
      m_seriesInfo(),
      m_startTime(QDateTime::currentDateTime().addDays(-1)),
      m_endTime(QDateTime::currentDateTime()),
      m_dataPointLimit(10000), // 默认限制10000个数据点
      m_mutex()
{
}

ChartDataModel::~ChartDataModel()
{
}

int ChartDataModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    QMutexLocker locker(const_cast<QMutex *>(&m_mutex));
    return m_dataPoints.size();
}

int ChartDataModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    QMutexLocker locker(const_cast<QMutex *>(&m_mutex));
    return m_seriesInfo.size() + 1; // +1 for timestamp
}

QVariant ChartDataModel::data(const QModelIndex &index, int role) const
{
    QMutexLocker locker(const_cast<QMutex *>(&m_mutex));

    if (!index.isValid() || index.row() >= m_dataPoints.size() || index.column() < 0) {
        return QVariant();
    }

    if (role == Qt::DisplayRole) {
        const DataPoint &point = m_dataPoints[index.row()];
        
        if (index.column() == 0) {
            // Timestamp column
            return point.timestamp.toString("yyyy-MM-dd HH:mm:ss");
        } else {
            // Data columns
            QStringList seriesNames = m_seriesInfo.keys();
            int seriesIndex = index.column() - 1;
            
            if (seriesIndex >= 0 && seriesIndex < seriesNames.size()) {
                QString tagName = seriesNames[seriesIndex];
                if (point.values.contains(tagName)) {
                    return point.values[tagName];
                }
            }
        }
    }

    return QVariant();
}

QVariant ChartDataModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    QMutexLocker locker(const_cast<QMutex *>(&m_mutex));

    if (role == Qt::DisplayRole) {
        if (orientation == Qt::Horizontal) {
            if (section == 0) {
                return "时间";
            } else {
                QStringList seriesNames = m_seriesInfo.keys();
                int seriesIndex = section - 1;
                if (seriesIndex >= 0 && seriesIndex < seriesNames.size()) {
                    return seriesNames[seriesIndex];
                }
            }
        } else {
            // Vertical header
            return QString::number(section + 1);
        }
    }

    return QVariant();
}

bool ChartDataModel::addSeries(const QString &tagName, const QString &color, 
                              const QString &lineStyle, bool visible)
{
    QMutexLocker locker(&m_mutex);

    // 检查是否已经添加了该指标
    if (m_seriesInfo.contains(tagName)) {
        return false;
    }

    // 检查是否超过8个指标限制
    if (m_seriesInfo.size() >= 8) {
        return false;
    }

    // 检查点位是否存在
    if (!m_tagManager->getTag(tagName)) {
        return false;
    }

    // 添加指标信息
    SeriesInfo info;
    info.color = color;
    info.lineStyle = lineStyle;
    info.visible = visible;
    info.min = 0.0;
    info.max = 100.0;
    info.warning = 80.0;
    info.error = 90.0;
    
    m_seriesInfo[tagName] = info;

    // 触发模型重置
    beginResetModel();
    endResetModel();

    return true;
}

bool ChartDataModel::removeSeries(const QString &tagName)
{
    QMutexLocker locker(&m_mutex);

    if (!m_seriesInfo.contains(tagName)) {
        return false;
    }

    // 移除指标信息
    m_seriesInfo.remove(tagName);

    // 移除所有数据点中的该指标值
    for (DataPoint &point : m_dataPoints) {
        point.values.remove(tagName);
    }

    // 触发模型重置
    beginResetModel();
    endResetModel();

    return true;
}

void ChartDataModel::clearSeries()
{
    QMutexLocker locker(&m_mutex);

    // 清空指标信息
    m_seriesInfo.clear();

    // 清空数据点
    m_dataPoints.clear();

    // 触发模型重置
    beginResetModel();
    endResetModel();
}

QStringList ChartDataModel::getSeries() const
{
    QMutexLocker locker(const_cast<QMutex *>(&m_mutex));
    return m_seriesInfo.keys();
}

bool ChartDataModel::setTimeRange(const QDateTime &startTime, const QDateTime &endTime)
{
    if (startTime >= endTime) {
        return false;
    }

    QMutexLocker locker(&m_mutex);

    m_startTime = startTime;
    m_endTime = endTime;

    // 触发时间范围变化信号
    emit timeRangeChanged(m_startTime, m_endTime);

    return true;
}

bool ChartDataModel::setPresetTimeRange(const QString &preset)
{
    QDateTime endTime = QDateTime::currentDateTime();
    QDateTime startTime;

    if (preset == "1h") {
        startTime = endTime.addSecs(-3600); // 1 hour = 3600 seconds
    } else if (preset == "1d") {
        startTime = endTime.addDays(-1);
    } else if (preset == "7d") {
        startTime = endTime.addDays(-7);
    } else {
        return false;
    }

    return setTimeRange(startTime, endTime);
}

bool ChartDataModel::loadHistoricalData(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime)
{
    QMutexLocker locker(&m_mutex);

    // 检查指标是否存在
    if (!m_seriesInfo.contains(tagName)) {
        return false;
    }

    // 这里应该从数据库加载历史数据
    // 为了演示，我们生成一些模拟数据
    QVector<DataPoint> newDataPoints;
    
    QDateTime currentTime = startTime;
    while (currentTime <= endTime) {
        DataPoint point;
        point.timestamp = currentTime;
        
        // 生成模拟数据
        double value = 50.0 + 20.0 * sin(currentTime.toMSecsSinceEpoch() / 10000.0);
        point.values[tagName] = value;
        
        newDataPoints.append(point);
        
        // 每10秒一个数据点
        currentTime = currentTime.addSecs(10);
    }

    // 合并数据点
    m_dataPoints.append(newDataPoints);
    cleanupDataPoints();

    // 触发模型重置
    beginResetModel();
    endResetModel();

    emit dataUpdated();
    return true;
}

void ChartDataModel::updateRealTimeData(const QString &tagName, const QVariant &value)
{
    QMutexLocker locker(&m_mutex);

    // 检查指标是否存在
    if (!m_seriesInfo.contains(tagName)) {
        return;
    }

    QDateTime now = currentTime();

    // 检查是否需要创建新的数据点
    if (m_dataPoints.isEmpty() || m_dataPoints.last().timestamp < now.addSecs(-1)) {
        // 创建新的数据点
        DataPoint newPoint;
        newPoint.timestamp = now;
        
        // 复制之前的数据点的值
        if (!m_dataPoints.isEmpty()) {
            const DataPoint &lastPoint = m_dataPoints.last();
            for (const QString &seriesName : m_seriesInfo.keys()) {
                if (lastPoint.values.contains(seriesName)) {
                    newPoint.values[seriesName] = lastPoint.values[seriesName];
                }
            }
        }
        
        // 更新当前指标的值
        newPoint.values[tagName] = value;
        
        // 添加到数据点列表
        beginInsertRows(QModelIndex(), m_dataPoints.size(), m_dataPoints.size());
        m_dataPoints.append(newPoint);
        endInsertRows();
    } else {
        // 更新最后一个数据点
        DataPoint &lastPoint = m_dataPoints.last();
        lastPoint.values[tagName] = value;
        
        // 触发数据变更信号
        QModelIndex index = createIndex(m_dataPoints.size() - 1, 0);
        emit dataChanged(index, index);
    }

    // 清理超出限制的数据点
    cleanupDataPoints();

    emit dataUpdated();
}

void ChartDataModel::setThresholds(const QString &tagName, double min, double max, double warning, double error)
{
    QMutexLocker locker(&m_mutex);

    if (m_seriesInfo.contains(tagName)) {
        SeriesInfo &info = m_seriesInfo[tagName];
        info.min = min;
        info.max = max;
        info.warning = warning;
        info.error = error;
    }
}

QVector<double> ChartDataModel::getThresholds(const QString &tagName) const
{
    QMutexLocker locker(const_cast<QMutex *>(&m_mutex));

    QVector<double> thresholds;
    if (m_seriesInfo.contains(tagName)) {
        const SeriesInfo &info = m_seriesInfo[tagName];
        thresholds << info.min << info.max << info.warning << info.error;
    }
    return thresholds;
}

bool ChartDataModel::exportToCsv(const QString &filePath) const
{
    QMutexLocker locker(const_cast<QMutex *>(&m_mutex));

    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        return false;
    }

    QTextStream out(&file);

    // 写入表头
    out << "时间";
    for (const QString &tagName : m_seriesInfo.keys()) {
        out << "," << tagName;
    }
    out << "\n";

    // 写入数据
    for (const DataPoint &point : m_dataPoints) {
        out << point.timestamp.toString("yyyy-MM-dd HH:mm:ss");
        for (const QString &tagName : m_seriesInfo.keys()) {
            if (point.values.contains(tagName)) {
                out << "," << point.values[tagName].toString();
            } else {
                out << ",";
            }
        }
        out << "\n";
    }

    file.close();
    return true;
}

void ChartDataModel::setDataPointLimit(int limit)
{
    QMutexLocker locker(&m_mutex);
    m_dataPointLimit = limit;
    cleanupDataPoints();
}

void ChartDataModel::cleanupDataPoints()
{
    if (m_dataPoints.size() > m_dataPointLimit) {
        int removeCount = m_dataPoints.size() - m_dataPointLimit;
        beginRemoveRows(QModelIndex(), 0, removeCount - 1);
        m_dataPoints.remove(0, removeCount);
        endRemoveRows();
    }
}

QDateTime ChartDataModel::currentTime() const
{
    return QDateTime::currentDateTime();
}
