#ifndef STEELPLANTMANAGER_H
#define STEELPLANTMANAGER_H

#include <QObject>
#include <QTimer>
#include <QDateTime>
#include <QMap>
#include <QVector>

// 包含Huayan核心头文件
#include "core/tagmanager.h"
#include "core/chartdatamodel.h"

// 前置声明
class SimulatedDataSource;

/**
 * @brief 钢铁厂监控平台管理器
 * 
 * 负责管理钢铁厂的各个设备和数据，包括高炉、转炉、轧钢等核心产线
 * 复用Huayan的TagManager和ChartDataModel来管理标签和图表数据
 */
class SteelPlantManager : public QObject
{
    Q_OBJECT

    // 属性
    Q_PROPERTY(QMap<QString, QVariant> blastFurnaceStatus READ blastFurnaceStatus NOTIFY blastFurnaceStatusChanged)
    Q_PROPERTY(QMap<QString, QVariant> converterStatus READ converterStatus NOTIFY converterStatusChanged)
    Q_PROPERTY(QMap<QString, QVariant> rollingMillStatus READ rollingMillStatus NOTIFY rollingMillStatusChanged)
    Q_PROPERTY(QVector<QPointF> temperatureData READ temperatureData NOTIFY temperatureDataChanged)
    Q_PROPERTY(QVector<QPointF> pressureData READ pressureData NOTIFY pressureDataChanged)
    Q_PROPERTY(QVector<QPointF> flowData READ flowData NOTIFY flowDataChanged)
    Q_PROPERTY(int emergencyAlarmCount READ emergencyAlarmCount NOTIFY emergencyAlarmCountChanged)
    Q_PROPERTY(int normalAlarmCount READ normalAlarmCount NOTIFY normalAlarmCountChanged)

public:
    explicit SteelPlantManager(QObject *parent = nullptr);
    ~SteelPlantManager();

    // 方法
    Q_INVOKABLE void initialize();
    Q_INVOKABLE void startSimulation();
    Q_INVOKABLE void stopSimulation();
    Q_INVOKABLE void toggleDevice(const QString &deviceId, bool status);
    Q_INVOKABLE void exportData(const QString &startTime, const QString &endTime, const QString &filePath);
    Q_INVOKABLE void acknowledgeAlarm(const QString &alarmId);

    // 属性读取方法
    QMap<QString, QVariant> blastFurnaceStatus() const;
    QMap<QString, QVariant> converterStatus() const;
    QMap<QString, QVariant> rollingMillStatus() const;
    QVector<QPointF> temperatureData() const;
    QVector<QPointF> pressureData() const;
    QVector<QPointF> flowData() const;
    int emergencyAlarmCount() const;
    int normalAlarmCount() const;

signals:
    // 信号
    void blastFurnaceStatusChanged();
    void converterStatusChanged();
    void rollingMillStatusChanged();
    void temperatureDataChanged();
    void pressureDataChanged();
    void flowDataChanged();
    void emergencyAlarmCountChanged();
    void normalAlarmCountChanged();
    void alarmTriggered(const QString &alarmId, const QString &message, bool isEmergency);

private slots:
    // 槽函数
    void updatePlantStatus();
    void checkAlarms();

private:
    // 私有成员
    TagManager *m_tagManager;
    ChartDataModel *m_chartDataModel;
    SimulatedDataSource *m_simulatedDataSource;
    QTimer *m_updateTimer;
    QTimer *m_alarmCheckTimer;
    
    // 设备状态
    QMap<QString, QVariant> m_blastFurnaceStatus;
    QMap<QString, QVariant> m_converterStatus;
    QMap<QString, QVariant> m_rollingMillStatus;
    
    // 图表数据
    QVector<QPointF> m_temperatureData;
    QVector<QPointF> m_pressureData;
    QVector<QPointF> m_flowData;
    
    // 告警计数
    int m_emergencyAlarmCount;
    int m_normalAlarmCount;
    
    // 告警历史
    QMap<QString, QDateTime> m_alarmHistory;
    
    // 方法
    void initializeTags();
    void updateChartData();
    void triggerAlarm(const QString &alarmId, const QString &message, bool isEmergency);
};

#endif // STEELPLANTMANAGER_H
