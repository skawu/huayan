#include "simulateddatasource.h"
#include <QDebug>
#include <QRandomGenerator>
#include <QFile>
#include <QTextStream>
#include <cmath>

SimulatedDataSource::SimulatedDataSource(QObject *parent) : QObject(parent)
{
    // 初始化成员变量
    m_updateTimer = new QTimer(this);
    m_updateInterval = 1000; // 默认1秒更新一次
    m_startTime = QDateTime::currentDateTime();
    
    // 连接信号和槽
    connect(m_updateTimer, &QTimer::timeout, this, &SimulatedDataSource::updateData);
}

SimulatedDataSource::~SimulatedDataSource()
{
    // 清理资源
    delete m_updateTimer;
}

void SimulatedDataSource::initialize()
{
    qDebug() << "初始化仿真数据源...";
    
    // 初始化默认配置
    initializeDefaultConfig();
    
    // 初始化默认仿真数据
    initializeDefaultSimulationData();
    
    qDebug() << "仿真数据源初始化完成";
}

void SimulatedDataSource::initialize(const QString &configFile)
{
    qDebug() << "从配置文件初始化仿真数据源:" << configFile;
    
    // 读取配置文件
    QFile file(configFile);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "无法打开配置文件:" << configFile;
        // 使用默认配置
        initializeDefaultConfig();
        return;
    }
    
    // 解析配置文件
    QTextStream in(&file);
    QString jsonString = in.readAll();
    file.close();
    
    QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonString.toUtf8());
    if (!jsonDoc.isObject()) {
        qDebug() << "配置文件格式错误:" << configFile;
        // 使用默认配置
        initializeDefaultConfig();
        return;
    }
    
    QJsonObject jsonObj = jsonDoc.object();
    
    // 解析更新间隔
    if (jsonObj.contains("updateInterval")) {
        m_updateInterval = jsonObj["updateInterval"].toInt(1000);
    }
    
    // 解析仿真参数
    if (jsonObj.contains("simulationParams")) {
        QJsonObject paramsObj = jsonObj["simulationParams"].toObject();
        for (auto it = paramsObj.constBegin(); it != paramsObj.constEnd(); ++it) {
            m_simulationParams[it.key()] = it.value().toVariant();
        }
    }
    
    // 解析初始数据
    if (jsonObj.contains("initialData")) {
        QJsonObject dataObj = jsonObj["initialData"].toObject();
        for (auto it = dataObj.constBegin(); it != dataObj.constEnd(); ++it) {
            m_data[it.key()] = it.value().toVariant();
        }
    } else {
        // 使用默认初始数据
        initializeDefaultSimulationData();
    }
    
    qDebug() << "仿真数据源从配置文件初始化完成";
}

void SimulatedDataSource::start()
{
    qDebug() << "启动仿真数据源...";
    
    // 启动定时器
    m_updateTimer->start(m_updateInterval);
    
    // 发出信号
    emit simulationStarted();
    
    qDebug() << "仿真数据源已启动";
}

void SimulatedDataSource::stop()
{
    qDebug() << "停止仿真数据源...";
    
    // 停止定时器
    m_updateTimer->stop();
    
    // 发出信号
    emit simulationStopped();
    
    qDebug() << "仿真数据源已停止";
}

QVariant SimulatedDataSource::readValue(const QString &address)
{
    // 读取值
    if (m_data.contains(address)) {
        return m_data[address];
    }
    
    // 如果地址不存在，返回默认值
    return QVariant();
}

bool SimulatedDataSource::writeValue(const QString &address, const QVariant &value)
{
    qDebug() << "写入值:" << address << "->" << value;
    
    // 写入值
    m_data[address] = value;
    
    // 发出信号
    emit dataUpdated(address, value);
    
    qDebug() << "值已写入";
    return true;
}

void SimulatedDataSource::loadSimulationData(const QString &dataFile)
{
    qDebug() << "加载仿真数据:" << dataFile;
    
    // 读取数据文件
    QFile file(dataFile);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "无法打开数据文件:" << dataFile;
        return;
    }
    
    // 解析数据文件
    QTextStream in(&file);
    QString jsonString = in.readAll();
    file.close();
    
    m_simulationData = QJsonDocument::fromJson(jsonString.toUtf8());
    if (!m_simulationData.isObject()) {
        qDebug() << "数据文件格式错误:" << dataFile;
        return;
    }
    
    qDebug() << "仿真数据加载完成";
}

void SimulatedDataSource::setUpdateInterval(int interval)
{
    m_updateInterval = interval;
    
    // 如果定时器正在运行，更新间隔
    if (m_updateTimer->isActive()) {
        m_updateTimer->setInterval(m_updateInterval);
    }
    
    qDebug() << "更新间隔已设置为:" << m_updateInterval << "ms";
}

QMap<QString, QVariant> SimulatedDataSource::getAllValues() const
{
    return m_data;
}

void SimulatedDataSource::updateData()
{
    // 生成钢铁厂数据
    generateSteelPlantData();
    
    // 发出信号
    emit dataUpdated(m_data);
}

void SimulatedDataSource::initializeDefaultConfig()
{
    qDebug() << "初始化默认配置...";
    
    // 设置默认更新间隔
    m_updateInterval = 1000;
    
    // 设置默认仿真参数
    m_simulationParams["blastFurnace.temperature.base"] = 1500.0;
    m_simulationParams["blastFurnace.temperature.range"] = 50.0;
    m_simulationParams["blastFurnace.pressure.base"] = 2.5;
    m_simulationParams["blastFurnace.pressure.range"] = 0.5;
    m_simulationParams["blastFurnace.level.base"] = 75.0;
    m_simulationParams["blastFurnace.level.range"] = 10.0;
    
    m_simulationParams["converter.temperature.base"] = 1600.0;
    m_simulationParams["converter.temperature.range"] = 80.0;
    m_simulationParams["converter.oxygenFlow.base"] = 85.0;
    m_simulationParams["converter.oxygenFlow.range"] = 15.0;
    m_simulationParams["converter.steelLevel.base"] = 65.0;
    m_simulationParams["converter.steelLevel.range"] = 15.0;
    
    m_simulationParams["rollingMill.speed.base"] = 1.2;
    m_simulationParams["rollingMill.speed.range"] = 0.3;
    m_simulationParams["rollingMill.temperature.base"] = 1450.0;
    m_simulationParams["rollingMill.temperature.range"] = 50.0;
    m_simulationParams["rollingMill.coolingWaterFlow.base"] = 90.0;
    m_simulationParams["rollingMill.coolingWaterFlow.range"] = 10.0;
    
    m_simulationParams["anomalyProbability"] = 0.01; // 1%的概率出现异常
    
    qDebug() << "默认配置初始化完成";
}

void SimulatedDataSource::initializeDefaultSimulationData()
{
    qDebug() << "初始化默认仿真数据...";
    
    // 初始化高炉数据
    m_data["blastFurnace.temperature"] = 1500.0;
    m_data["blastFurnace.pressure"] = 2.5;
    m_data["blastFurnace.level"] = 75.0;
    m_data["blastFurnace.status"] = true;
    
    // 初始化转炉数据
    m_data["converter.temperature"] = 1600.0;
    m_data["converter.oxygenFlow"] = 85.0;
    m_data["converter.steelLevel"] = 65.0;
    m_data["converter.status"] = true;
    
    // 初始化轧钢数据
    m_data["rollingMill.speed"] = 1.2;
    m_data["rollingMill.temperature"] = 1450.0;
    m_data["rollingMill.coolingWaterFlow"] = 90.0;
    m_data["rollingMill.status"] = true;
    
    qDebug() << "默认仿真数据初始化完成";
}

void SimulatedDataSource::generateSteelPlantData()
{
    // 生成高炉数据
    generateBlastFurnaceData();
    
    // 生成转炉数据
    generateConverterData();
    
    // 生成轧钢数据
    generateRollingMillData();
    
    // 生成异常数据
    generateAnomalyData();
}

void SimulatedDataSource::generateBlastFurnaceData()
{
    if (!m_data.contains("blastFurnace.status") || !m_data["blastFurnace.status"].toBool()) {
        return;
    }
    
    // 获取基础值和范围
    double tempBase = m_simulationParams.value("blastFurnace.temperature.base", 1500.0).toDouble();
    double tempRange = m_simulationParams.value("blastFurnace.temperature.range", 50.0).toDouble();
    double pressureBase = m_simulationParams.value("blastFurnace.pressure.base", 2.5).toDouble();
    double pressureRange = m_simulationParams.value("blastFurnace.pressure.range", 0.5).toDouble();
    double levelBase = m_simulationParams.value("blastFurnace.level.base", 75.0).toDouble();
    double levelRange = m_simulationParams.value("blastFurnace.level.range", 10.0).toDouble();
    
    // 计算时间因子
    qint64 elapsed = m_startTime.msecsTo(QDateTime::currentDateTime());
    double timeFactor = elapsed / 1000.0;
    
    // 生成温度数据（包含缓慢上升趋势和小波动）
    double tempTrend = 0.01 * timeFactor; // 每秒钟上升0.01度
    double tempNoise = tempRange * 0.5 * sin(timeFactor * 0.1) + tempRange * 0.1 * QRandomGenerator::global()->bounded(2.0) - tempRange * 0.05;
    double newTemp = tempBase + tempTrend + tempNoise;
    m_data["blastFurnace.temperature"] = newTemp;
    
    // 生成压力数据（与温度相关，包含波动）
    double pressureTrend = 0.001 * tempTrend;
    double pressureNoise = pressureRange * 0.5 * sin(timeFactor * 0.2) + pressureRange * 0.1 * QRandomGenerator::global()->bounded(2.0) - pressureRange * 0.05;
    double newPressure = pressureBase + pressureTrend + pressureNoise;
    m_data["blastFurnace.pressure"] = newPressure;
    
    // 生成料位数据（周期性变化）
    double levelTrend = levelRange * 0.5 * (1 - cos(timeFactor * 0.05));
    double levelNoise = levelRange * 0.1 * QRandomGenerator::global()->bounded(2.0) - levelRange * 0.05;
    double newLevel = levelBase - levelTrend + levelNoise;
    newLevel = qMax(0.0, qMin(100.0, newLevel));
    m_data["blastFurnace.level"] = newLevel;
}

void SimulatedDataSource::generateConverterData()
{
    if (!m_data.contains("converter.status") || !m_data["converter.status"].toBool()) {
        return;
    }
    
    // 获取基础值和范围
    double tempBase = m_simulationParams.value("converter.temperature.base", 1600.0).toDouble();
    double tempRange = m_simulationParams.value("converter.temperature.range", 80.0).toDouble();
    double oxygenFlowBase = m_simulationParams.value("converter.oxygenFlow.base", 85.0).toDouble();
    double oxygenFlowRange = m_simulationParams.value("converter.oxygenFlow.range", 15.0).toDouble();
    double steelLevelBase = m_simulationParams.value("converter.steelLevel.base", 65.0).toDouble();
    double steelLevelRange = m_simulationParams.value("converter.steelLevel.range", 15.0).toDouble();
    
    // 计算时间因子
    qint64 elapsed = m_startTime.msecsTo(QDateTime::currentDateTime());
    double timeFactor = elapsed / 1000.0;
    
    // 生成温度数据（包含较大波动）
    double tempNoise = tempRange * 0.5 * sin(timeFactor * 0.3) + tempRange * 0.2 * QRandomGenerator::global()->bounded(2.0) - tempRange * 0.1;
    double newTemp = tempBase + tempNoise;
    m_data["converter.temperature"] = newTemp;
    
    // 生成氧气流量数据（周期性变化）
    double oxygenFlowTrend = oxygenFlowRange * 0.5 * (1 - cos(timeFactor * 0.1));
    double oxygenFlowNoise = oxygenFlowRange * 0.1 * QRandomGenerator::global()->bounded(2.0) - oxygenFlowRange * 0.05;
    double newOxygenFlow = oxygenFlowBase - oxygenFlowTrend + oxygenFlowNoise;
    newOxygenFlow = qMax(50.0, qMin(100.0, newOxygenFlow));
    m_data["converter.oxygenFlow"] = newOxygenFlow;
    
    // 生成钢水液位数据（缓慢下降）
    double steelLevelTrend = 0.02 * timeFactor; // 每秒钟下降0.02%
    double steelLevelNoise = steelLevelRange * 0.1 * QRandomGenerator::global()->bounded(2.0) - steelLevelRange * 0.05;
    double newSteelLevel = steelLevelBase - steelLevelTrend + steelLevelNoise;
    newSteelLevel = qMax(0.0, qMin(100.0, newSteelLevel));
    
    // 当液位过低时重置
    if (newSteelLevel < 20.0) {
        newSteelLevel = steelLevelBase;
        m_startTime = QDateTime::currentDateTime();
    }
    
    m_data["converter.steelLevel"] = newSteelLevel;
}

void SimulatedDataSource::generateRollingMillData()
{
    if (!m_data.contains("rollingMill.status") || !m_data["rollingMill.status"].toBool()) {
        return;
    }
    
    // 获取基础值和范围
    double speedBase = m_simulationParams.value("rollingMill.speed.base", 1.2).toDouble();
    double speedRange = m_simulationParams.value("rollingMill.speed.range", 0.3).toDouble();
    double tempBase = m_simulationParams.value("rollingMill.temperature.base", 1450.0).toDouble();
    double tempRange = m_simulationParams.value("rollingMill.temperature.range", 50.0).toDouble();
    double coolingFlowBase = m_simulationParams.value("rollingMill.coolingWaterFlow.base", 90.0).toDouble();
    double coolingFlowRange = m_simulationParams.value("rollingMill.coolingWaterFlow.range", 10.0).toDouble();
    
    // 计算时间因子
    qint64 elapsed = m_startTime.msecsTo(QDateTime::currentDateTime());
    double timeFactor = elapsed / 1000.0;
    
    // 生成速度数据（包含小波动）
    double speedNoise = speedRange * 0.5 * sin(timeFactor * 0.5) + speedRange * 0.1 * QRandomGenerator::global()->bounded(2.0) - speedRange * 0.05;
    double newSpeed = speedBase + speedNoise;
    newSpeed = qMax(0.5, qMin(2.0, newSpeed));
    m_data["rollingMill.speed"] = newSpeed;
    
    // 生成温度数据（与速度相关）
    double tempNoise = tempRange * 0.5 * sin(timeFactor * 0.2) + tempRange * 0.1 * QRandomGenerator::global()->bounded(2.0) - tempRange * 0.05;
    double speedEffect = 50.0 * (newSpeed - speedBase);
    double newTemp = tempBase + tempNoise + speedEffect;
    m_data["rollingMill.temperature"] = newTemp;
    
    // 生成冷却水流量数据（与温度相关）
    double coolingFlowTrend = coolingFlowRange * 0.3 * (newTemp - tempBase) / tempRange;
    double coolingFlowNoise = coolingFlowRange * 0.1 * QRandomGenerator::global()->bounded(2.0) - coolingFlowRange * 0.05;
    double newCoolingFlow = coolingFlowBase + coolingFlowTrend + coolingFlowNoise;
    newCoolingFlow = qMax(60.0, qMin(100.0, newCoolingFlow));
    m_data["rollingMill.coolingWaterFlow"] = newCoolingFlow;
}

void SimulatedDataSource::generateAnomalyData()
{
    double anomalyProbability = m_simulationParams.value("anomalyProbability", 0.01).toDouble();
    
    // 随机生成异常
    if (QRandomGenerator::global()->bounded(1.0) < anomalyProbability) {
        int anomalyType = QRandomGenerator::global()->bounded(3);
        
        switch (anomalyType) {
        case 0:
            // 高炉超温
            if (m_data.contains("blastFurnace.status") && m_data["blastFurnace.status"].toBool()) {
                double currentTemp = m_data["blastFurnace.temperature"].toDouble();
                m_data["blastFurnace.temperature"] = currentTemp + 100.0; // 突然升高100度
                qDebug() << "生成高炉超温异常";
            }
            break;
        case 1:
            // 转炉低压
            if (m_data.contains("converter.status") && m_data["converter.status"].toBool()) {
                double currentPressure = m_data["converter.pressure"].toDouble();
                m_data["converter.pressure"] = currentPressure * 0.5; // 突然降低到一半
                qDebug() << "生成转炉低压异常";
            }
            break;
        case 2:
            // 轧钢转速异常
            if (m_data.contains("rollingMill.status") && m_data["rollingMill.status"].toBool()) {
                double currentSpeed = m_data["rollingMill.speed"].toDouble();
                m_data["rollingMill.speed"] = currentSpeed * 2.0; // 突然升高到两倍
                qDebug() << "生成轧钢转速异常";
            }
            break;
        default:
            break;
        }
    }
}
