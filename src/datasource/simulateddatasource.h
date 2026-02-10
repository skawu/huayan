#ifndef SIMULATEDDATASOURCE_H
#define SIMULATEDDATASOURCE_H

#include <QObject>
#include <QMap>
#include <QVariant>
#include <QTimer>
#include <QDateTime>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

/**
 * @brief 仿真数据源
 * 
 * 用于生成模拟的工业数据，支持离线运行
 * 可模拟正常生产数据和异常场景
 * 数据规律贴合真实工业生产逻辑
 */
class SimulatedDataSource : public QObject
{
    Q_OBJECT

public:
    explicit SimulatedDataSource(QObject *parent = nullptr);
    ~SimulatedDataSource();

    // 方法
    Q_INVOKABLE void initialize();
    Q_INVOKABLE void initialize(const QString &configFile);
    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE QVariant readValue(const QString &address);
    Q_INVOKABLE bool writeValue(const QString &address, const QVariant &value);
    Q_INVOKABLE void loadSimulationData(const QString &dataFile);
    Q_INVOKABLE void setUpdateInterval(int interval);

    // 获取所有值
    QMap<QString, QVariant> getAllValues() const;

signals:
    // 信号
    void dataUpdated(const QString &address, const QVariant &value);
    void dataUpdated(const QMap<QString, QVariant> &values);
    void simulationStarted();
    void simulationStopped();

private slots:
    // 槽函数
    void updateData();

private:
    // 私有成员
    QTimer *m_updateTimer;
    QMap<QString, QVariant> m_data;
    QMap<QString, QVariant> m_config;
    QMap<QString, QVariant> m_simulationParams;
    QJsonDocument m_simulationData;
    int m_updateInterval;
    QDateTime m_startTime;
    
    // 方法
    void initializeDefaultConfig();
    void initializeDefaultSimulationData();
    void generateSteelPlantData();
    void generateBlastFurnaceData();
    void generateConverterData();
    void generateRollingMillData();
    void generateAnomalyData();
};

#endif // SIMULATEDDATASOURCE_H
