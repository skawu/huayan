#include "hysteelplantmanager.h"
#include "hysimulateddatasource.h"
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QRandomGenerator>

HYSteelPlantManager::HYSteelPlantManager(QObject *parent) : QObject(parent)
{
    // 初始化成员变量
    m_tagManager = new HYTagManager(this);
    m_chartDataModel = new HYChartDataModel(this);
    m_simulatedDataSource = new HYSimulatedDataSource(this);
    m_updateTimer = new QTimer(this);
    m_alarmCheckTimer = new QTimer(this);
    
    m_emergencyAlarmCount = 0;
    m_normalAlarmCount = 0;
    
    // 连接信号和槽
    connect(m_updateTimer, &QTimer::timeout, this, &HYSteelPlantManager::updatePlantStatus);
    connect(m_alarmCheckTimer, &QTimer::timeout, this, &HYSteelPlantManager::checkAlarms);
}

HYSteelPlantManager::~HYSteelPlantManager()
{
    // 清理资源
    delete m_tagManager;
    delete m_chartDataModel;
    delete m_simulatedDataSource;
    delete m_updateTimer;
    delete m_alarmCheckTimer;
}

void HYSteelPlantManager::initialize()
{
    qDebug() << "初始化华颜钢铁厂监控平台...";
    
    // 初始化标签
    initializeTags();
    
    // 初始化模拟数据源
    m_simulatedDataSource->initialize();
    
    // 初始化设备状态
    m_blastFurnaceStatus["temperature"] = 1500.0;
    m_blastFurnaceStatus["pressure"] = 2.5;
    m_blastFurnaceStatus["level"] = 75.0;
    m_blastFurnaceStatus["status"] = true;
    
    m_converterStatus["temperature"] = 1600.0;
    m_converterStatus["oxygenFlow"] = 85.0;
    m_converterStatus["steelLevel"] = 65.0;
    m_converterStatus["status"] = true;
    
    m_rollingMillStatus["speed"] = 1.2;
    m_rollingMillStatus["temperature"] = 1450.0;
    m_rollingMillStatus["coolingWaterFlow"] = 90.0;
    m_rollingMillStatus["status"] = true;
    
    qDebug() << "华颜钢铁厂监控平台初始化完成";
}

void HYSteelPlantManager::startSimulation()
{
    qDebug() << "开始模拟...";
    
    // 启动定时器
    m_updateTimer->start(1000); // 1秒更新一次
    m_alarmCheckTimer->start(2000); // 2秒检查一次告警
    
    qDebug() << "模拟已开始";
}

void HYSteelPlantManager::stopSimulation()
{
    qDebug() << "停止模拟...";
    
    // 停止定时器
    m_updateTimer->stop();
    m_alarmCheckTimer->stop();
    
    qDebug() << "模拟已停止";
}

void HYSteelPlantManager::toggleDevice(const QString &deviceId, bool status)
{
    qDebug() << "切换设备状态:" << deviceId << "->" << status;
    
    // 切换设备状态
    if (deviceId.startsWith("blastFurnace")) {
        m_blastFurnaceStatus["status"] = status;
        emit blastFurnaceStatusChanged();
    } else if (deviceId.startsWith("converter")) {
        m_converterStatus["status"] = status;
        emit converterStatusChanged();
    } else if (deviceId.startsWith("rollingMill")) {
        m_rollingMillStatus["status"] = status;
        emit rollingMillStatusChanged();
    }
    
    // 更新标签值
    m_tagManager->updateTagValue(deviceId + ".status", status);
    
    qDebug() << "设备状态已切换";
}

void HYSteelPlantManager::exportData(const QString &startTime, const QString &endTime, const QString &filePath)
{
    qDebug() << "导出数据:" << startTime << "->" << endTime << "到" << filePath;
    
    // 创建文件
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qDebug() << "无法打开文件:" << filePath;
        return;
    }
    
    // 写入数据
    QTextStream out(&file);
    out << "时间,温度,压力,流量\n";
    
    // 这里应该从HYChartDataModel中获取数据
    // 为了示例，我们生成一些模拟数据
    for (int i = 0; i < 24; ++i) {
        QDateTime time = QDateTime::currentDateTime().addSecs(-24 * 3600 + i * 3600);
        double temperature = 1500.0 + QRandomGenerator::global()->bounded(100.0);
        double pressure = 2.0 + QRandomGenerator::global()->bounded(1.0);
        double flow = 80.0 + QRandomGenerator::global()->bounded(40.0);
        
        out << time.toString("yyyy-MM-dd HH:mm:ss") << "," 
            << QString::number(temperature, 'f', 2) << "," 
            << QString::number(pressure, 'f', 2) << "," 
            << QString::number(flow, 'f', 2) << "\n";
    }
    
    // 关闭文件
    file.close();
    
    qDebug() << "数据导出完成";
}

void HYSteelPlantManager::acknowledgeAlarm(const QString &alarmId)
{
    qDebug() << "确认告警:" << alarmId;
    
    // 从告警历史中移除
    if (m_alarmHistory.contains(alarmId)) {
        m_alarmHistory.remove(alarmId);
        
        // 减少告警计数
        if (alarmId.startsWith("emergency")) {
            m_emergencyAlarmCount--;
            emit emergencyAlarmCountChanged();
        } else {
            m_normalAlarmCount--;
            emit normalAlarmCountChanged();
        }
    }
    
    qDebug() << "告警已确认";
}

QMap<QString, QVariant> HYSteelPlantManager::blastFurnaceStatus() const
{
    return m_blastFurnaceStatus;
}

QMap<QString, QVariant> HYSteelPlantManager::converterStatus() const
{
    return m_converterStatus;
}

QMap<QString, QVariant> HYSteelPlantManager::rollingMillStatus() const
{
    return m_rollingMillStatus;
}

QVector<QPointF> HYSteelPlantManager::temperatureData() const
{
    return m_temperatureData;
}

QVector<QPointF> HYSteelPlantManager::pressureData() const
{
    return m_pressureData;
}

QVector<QPointF> HYSteelPlantManager::flowData() const
{
    return m_flowData;
}

int HYSteelPlantManager::emergencyAlarmCount() const
{
    return m_emergencyAlarmCount;
}

int HYSteelPlantManager::normalAlarmCount() const
{
    return m_normalAlarmCount;
}

void HYSteelPlantManager::updatePlantStatus()
{
    // 生成随机数据波动
    double tempVariation = QRandomGenerator::global()->bounded(2.0) - 1.0;
    double pressureVariation = QRandomGenerator::global()->bounded(0.1) - 0.05;
    double flowVariation = QRandomGenerator::global()->bounded(2.0) - 1.0;
    
    // 更新高炉状态
    if (m_blastFurnaceStatus["status"].toBool()) {
        m_blastFurnaceStatus["temperature"] = m_blastFurnaceStatus["temperature"].toDouble() + tempVariation;
        m_blastFurnaceStatus["pressure"] = m_blastFurnaceStatus["pressure"].toDouble() + pressureVariation;
        m_blastFurnaceStatus["level"] = m_blastFurnaceStatus["level"].toDouble() + (QRandomGenerator::global()->bounded(1.0) - 0.5);
    }
    
    // 更新转炉状态
    if (m_converterStatus["status"].toBool()) {
        m_converterStatus["temperature"] = m_converterStatus["temperature"].toDouble() + tempVariation;
        m_converterStatus["oxygenFlow"] = m_converterStatus["oxygenFlow"].toDouble() + flowVariation;
        m_converterStatus["steelLevel"] = m_converterStatus["steelLevel"].toDouble() + (QRandomGenerator::global()->bounded(1.0) - 0.5);
    }
    
    // 更新轧钢状态
    if (m_rollingMillStatus["status"].toBool()) {
        m_rollingMillStatus["speed"] = m_rollingMillStatus["speed"].toDouble() + (QRandomGenerator::global()->bounded(0.1) - 0.05);
        m_rollingMillStatus["temperature"] = m_rollingMillStatus["temperature"].toDouble() + tempVariation;
        m_rollingMillStatus["coolingWaterFlow"] = m_rollingMillStatus["coolingWaterFlow"].toDouble() + flowVariation;
    }
    
    // 更新标签值
    m_tagManager->updateTagValue("blastFurnace.temperature", m_blastFurnaceStatus["temperature"]);
    m_tagManager->updateTagValue("blastFurnace.pressure", m_blastFurnaceStatus["pressure"]);
    m_tagManager->updateTagValue("blastFurnace.level", m_blastFurnaceStatus["level"]);
    
    m_tagManager->updateTagValue("converter.temperature", m_converterStatus["temperature"]);
    m_tagManager->updateTagValue("converter.oxygenFlow", m_converterStatus["oxygenFlow"]);
    m_tagManager->updateTagValue("converter.steelLevel", m_converterStatus["steelLevel"]);
    
    m_tagManager->updateTagValue("rollingMill.speed", m_rollingMillStatus["speed"]);
    m_tagManager->updateTagValue("rollingMill.temperature", m_rollingMillStatus["temperature"]);
    m_tagManager->updateTagValue("rollingMill.coolingWaterFlow", m_rollingMillStatus["coolingWaterFlow"]);
    
    // 添加图表数据
    QDateTime now = QDateTime::currentDateTime();
    m_chartDataModel->addDataPoint("temperature", now, m_blastFurnaceStatus["temperature"]);
    m_chartDataModel->addDataPoint("pressure", now, m_blastFurnaceStatus["pressure"]);
    m_chartDataModel->addDataPoint("flow", now, m_converterStatus["oxygenFlow"]);
    
    // 更新图表数据
    m_temperatureData = m_chartDataModel->getChartData("temperature");
    m_pressureData = m_chartDataModel->getChartData("pressure");
    m_flowData = m_chartDataModel->getChartData("flow");
    
    // 发出信号
    emit blastFurnaceStatusChanged();
    emit converterStatusChanged();
    emit rollingMillStatusChanged();
    emit temperatureDataChanged();
    emit pressureDataChanged();
    emit flowDataChanged();
}

void HYSteelPlantManager::checkAlarms()
{
    // 检查高炉告警
    if (m_blastFurnaceStatus["status"].toBool()) {
        if (m_blastFurnaceStatus["temperature"].toDouble() > 1600.0) {
            triggerAlarm("emergency.blastFurnace.temperature", "高炉温度过高！", true);
        } else if (m_blastFurnaceStatus["pressure"].toDouble() > 3.0) {
            triggerAlarm("emergency.blastFurnace.pressure", "高炉压力过高！", true);
        } else if (m_blastFurnaceStatus["level"].toDouble() < 30.0) {
            triggerAlarm("normal.blastFurnace.level", "高炉料位过低", false);
        }
    }
    
    // 检查转炉告警
    if (m_converterStatus["status"].toBool()) {
        if (m_converterStatus["temperature"].toDouble() > 1700.0) {
            triggerAlarm("emergency.converter.temperature", "转炉温度过高！", true);
        } else if (m_converterStatus["oxygenFlow"].toDouble() < 50.0) {
            triggerAlarm("normal.converter.oxygenFlow", "转炉氧气流量过低", false);
        }
    }
    
    // 检查轧钢告警
    if (m_rollingMillStatus["status"].toBool()) {
        if (m_rollingMillStatus["temperature"].toDouble() > 1500.0) {
            triggerAlarm("emergency.rollingMill.temperature", "轧钢温度过高！", true);
        } else if (m_rollingMillStatus["coolingWaterFlow"].toDouble() < 60.0) {
            triggerAlarm("normal.rollingMill.coolingWaterFlow", "轧钢冷却水流量过低", false);
        }
    }
}

void HYSteelPlantManager::initializeTags()
{
    qDebug() << "初始化标签...";
    
    // 添加高炉标签
    m_tagManager->addTag("blastFurnace.temperature", "AI", "高炉温度");
    m_tagManager->addTag("blastFurnace.pressure", "AI", "高炉压力");
    m_tagManager->addTag("blastFurnace.level", "AI", "高炉料位");
    m_tagManager->addTag("blastFurnace.status", "DO", "高炉状态");
    
    // 添加转炉标签
    m_tagManager->addTag("converter.temperature", "AI", "转炉温度");
    m_tagManager->addTag("converter.oxygenFlow", "AI", "转炉氧气流量");
    m_tagManager->addTag("converter.steelLevel", "AI", "转炉钢水液位");
    m_tagManager->addTag("converter.status", "DO", "转炉状态");
    
    // 添加轧钢标签
    m_tagManager->addTag("rollingMill.speed", "AI", "轧钢速度");
    m_tagManager->addTag("rollingMill.temperature", "AI", "轧钢温度");
    m_tagManager->addTag("rollingMill.coolingWaterFlow", "AI", "轧钢冷却水流量");
    m_tagManager->addTag("rollingMill.status", "DO", "轧钢状态");
    
    qDebug() << "标签初始化完成";
}

void HYSteelPlantManager::updateChartData()
{
    // 更新图表数据
    m_temperatureData = m_chartDataModel->getChartData("temperature");
    m_pressureData = m_chartDataModel->getChartData("pressure");
    m_flowData = m_chartDataModel->getChartData("flow");
    
    // 发出信号
    emit temperatureDataChanged();
    emit pressureDataChanged();
    emit flowDataChanged();
}

void HYSteelPlantManager::triggerAlarm(const QString &alarmId, const QString &message, bool isEmergency)
{
    // 检查告警是否已经存在
    if (m_alarmHistory.contains(alarmId)) {
        return;
    }
    
    // 记录告警
    m_alarmHistory[alarmId] = QDateTime::currentDateTime();
    
    // 增加告警计数
    if (isEmergency) {
        m_emergencyAlarmCount++;
        emit emergencyAlarmCountChanged();
    } else {
        m_normalAlarmCount++;
        emit normalAlarmCountChanged();
    }
    
    // 发出告警信号
    emit alarmTriggered(alarmId, message, isEmergency);
    
    qDebug() << "告警触发:" << alarmId << "-" << message << "(紧急:" << isEmergency << ")";
}
