#ifndef CHARTDATAMODEL_H
#define CHARTDATAMODEL_H

#include <QObject>
#include <QAbstractTableModel>
#include <QVector>
#include <QDateTime>
#include <QMap>
#include <QMutex>
#include "tagmanager.h"

/**
 * @file chartdatamodel.h
 * @brief 图表数据模型类
 * 
 * 此类实现了图表数据模型，支持8个指标同屏展示
 * 提供数据缓存、历史数据加载和实时数据更新功能
 * 支持时间轴筛选和数据导出
 */

class ChartDataModel : public QAbstractTableModel
{
    Q_OBJECT

public:
    /**
     * @brief 构造函数
     * @param tagManager 点位管理器指针
     * @param parent 父对象
     */
    explicit ChartDataModel(HYTagManager *tagManager, QObject *parent = nullptr);
    
    /**
     * @brief 析构函数
     */
    ~ChartDataModel();

    // 数据模型接口
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;

    // 指标管理
    /**
     * @brief 添加图表指标
     * @param tagName 点位名称
     * @param color 曲线颜色
     * @param lineStyle 线型
     * @param visible 是否可见
     * @return 添加是否成功
     */
    bool addSeries(const QString &tagName, const QString &color = "#0000FF", 
                  const QString &lineStyle = "solid", bool visible = true);
    
    /**
     * @brief 移除图表指标
     * @param tagName 点位名称
     * @return 移除是否成功
     */
    bool removeSeries(const QString &tagName);
    
    /**
     * @brief 清空所有指标
     */
    void clearSeries();
    
    /**
     * @brief 获取所有指标
     * @return 指标名称列表
     */
    QStringList getSeries() const;

    // 数据管理
    /**
     * @brief 设置时间范围
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 设置是否成功
     */
    bool setTimeRange(const QDateTime &startTime, const QDateTime &endTime);
    
    /**
     * @brief 设置预定义时间范围
     * @param preset 预定义范围（1h, 1d, 7d）
     * @return 设置是否成功
     */
    bool setPresetTimeRange(const QString &preset);
    
    /**
     * @brief 加载历史数据
     * @param tagName 点位名称
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 加载是否成功
     */
    bool loadHistoricalData(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime);
    
    /**
     * @brief 实时数据更新
     * @param tagName 点位名称
     * @param value 新值
     */
    void updateRealTimeData(const QString &tagName, const QVariant &value);

    // 阈值管理
    /**
     * @brief 设置指标阈值
     * @param tagName 点位名称
     * @param min 最小值
     * @param max 最大值
     * @param warning 警告值
     * @param error 错误值
     */
    void setThresholds(const QString &tagName, double min, double max, double warning, double error);
    
    /**
     * @brief 获取指标阈值
     * @param tagName 点位名称
     * @return 阈值列表 [min, max, warning, error]
     */
    QVector<double> getThresholds(const QString &tagName) const;

    // 数据导出
    /**
     * @brief 导出数据为CSV格式
     * @param filePath 文件路径
     * @return 导出是否成功
     */
    bool exportToCsv(const QString &filePath) const;

    // 性能优化
    /**
     * @brief 设置数据点限制
     * @param limit 最大数据点数量
     */
    void setDataPointLimit(int limit);

signals:
    /**
     * @brief 数据更新信号
     */
    void dataUpdated();
    
    /**
     * @brief 时间范围变化信号
     * @param startTime 开始时间
     * @param endTime 结束时间
     */
    void timeRangeChanged(const QDateTime &startTime, const QDateTime &endTime);

private:
    // 数据结构
    struct DataPoint {
        QDateTime timestamp; ///< 时间戳
        QMap<QString, QVariant> values; ///< 各指标值
    };
    
    struct SeriesInfo {
        QString color; ///< 曲线颜色
        QString lineStyle; ///< 线型
        bool visible; ///< 是否可见
        double min; ///< 最小值
        double max; ///< 最大值
        double warning; ///< 警告值
        double error; ///< 错误值
    };

    HYTagManager *m_tagManager; ///< 点位管理器指针
    QVector<DataPoint> m_dataPoints; ///< 数据点列表
    QMap<QString, SeriesInfo> m_seriesInfo; ///< 指标信息
    QDateTime m_startTime; ///< 开始时间
    QDateTime m_endTime; ///< 结束时间
    int m_dataPointLimit; ///< 数据点限制
    QMutex m_mutex; ///< 互斥锁

    // 私有方法
    /**
     * @brief 清理超出限制的数据点
     */
    void cleanupDataPoints();
    
    /**
     * @brief 获取当前时间
     * @return 当前时间
     */
    QDateTime currentTime() const;
};

#endif // CHARTDATAMODEL_H
