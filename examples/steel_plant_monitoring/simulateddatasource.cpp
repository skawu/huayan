#include "hysimulateddatasource.h"
#include <QDebug>
#include <QRandomGenerator>

HYSimulatedDataSource::HYSimulatedDataSource(QObject *parent) : QObject(parent)
{
    // 初始化成员变量
    m_updateTimer = new QTimer(this);
    
    // 连接信号和槽
    connect(m_updateTimer, &QTimer::timeout, this, &HYSimulatedDataSource::updateData);
}

HYSimulatedDataSource::~HYSimulatedDataSource()
{
    // 清理资源
    delete m_updateTimer;
}

void HYSimulatedDataSource::initialize()
{
    qDebug() << "初始化华颜模拟数据源...";
    
    // 初始化模拟数据
    m_data["blastFurnace.temperature"] = 1500.0;
    m_data["blastFurnace.pressure"] = 2.5;
    m_data["blastFurnace.level"] = 75.0;
    m_data["blastFurnace.status"] = true;
    
    m_data["converter.temperature"] = 1600.0;
    m_data["converter.oxygenFlow"] = 85.0;
    m_data["converter.steelLevel"] = 65.0;
    m_data["converter.status"] = true;
    
    m_data["rollingMill.speed"] = 1.2;
    m_data["rollingMill.temperature"] = 1450.0;
    m_data["rollingMill.coolingWaterFlow"] = 90.0;
    m_data["rollingMill.status"] = true;
    
    qDebug() << "华颜模拟数据源初始化完成";
}

void HYSimulatedDataSource::start()
{
    qDebug() << "启动华颜模拟数据源...";
    
    // 启动定时器
    m_updateTimer->start(500); // 500ms更新一次
    
    qDebug() << "华颜模拟数据源已启动";
}

void HYSimulatedDataSource::stop()
{
    qDebug() << "停止华颜模拟数据源...";
    
    // 停止定时器
    m_updateTimer->stop();
    
    qDebug() << "华颜模拟数据源已停止";
}

QVariant HYSimulatedDataSource::readValue(const QString &address)
{
    // 读取值
    if (m_data.contains(address)) {
        return m_data[address];
    }
    
    // 如果地址不存在，返回默认值
    return QVariant();
}

bool HYSimulatedDataSource::writeValue(const QString &address, const QVariant &value)
{
    qDebug() << "写入值:" << address << "->" << value;
    
    // 写入值
    m_data[address] = value;
    
    // 发出信号
    emit dataUpdated(address, value);
    
    qDebug() << "值已写入";
    return true;
}

QMap<QString, QVariant> HYSimulatedDataSource::getAllValues() const
{
    return m_data;
}

void HYSimulatedDataSource::updateData()
{
    // 生成随机数据波动
    double tempVariation = QRandomGenerator::global()->bounded(2.0) - 1.0;
    double pressureVariation = QRandomGenerator::global()->bounded(0.1) - 0.05;
    double flowVariation = QRandomGenerator::global()->bounded(2.0) - 1.0;
    double levelVariation = QRandomGenerator::global()->bounded(1.0) - 0.5;
    double speedVariation = QRandomGenerator::global()->bounded(0.1) - 0.05;
    
    // 更新高炉数据
    if (m_data["blastFurnace.status"].toBool()) {
        double newTemp = m_data["blastFurnace.temperature"].toDouble() + tempVariation;
        double newPressure = m_data["blastFurnace.pressure"].toDouble() + pressureVariation;
        double newLevel = m_data["blastFurnace.level"].toDouble() + levelVariation;
        
        // 确保值在合理范围内
        newTemp = qMax(1400.0, qMin(1600.0, newTemp));
        newPressure = qMax(1.0, qMin(3.0, newPressure));
        newLevel = qMax(0.0, qMin(100.0, newLevel));
        
        m_data["blastFurnace.temperature"] = newTemp;
        m_data["blastFurnace.pressure"] = newPressure;
        m_data["blastFurnace.level"] = newLevel;
        
        // 发出信号
        emit dataUpdated("blastFurnace.temperature", newTemp);
        emit dataUpdated("blastFurnace.pressure", newPressure);
        emit dataUpdated("blastFurnace.level", newLevel);
    }
    
    // 更新转炉数据
    if (m_data["converter.status"].toBool()) {
        double newTemp = m_data["converter.temperature"].toDouble() + tempVariation;
        double newOxygenFlow = m_data["converter.oxygenFlow"].toDouble() + flowVariation;
        double newSteelLevel = m_data["converter.steelLevel"].toDouble() + levelVariation;
        
        // 确保值在合理范围内
        newTemp = qMax(1500.0, qMin(1700.0, newTemp));
        newOxygenFlow = qMax(50.0, qMin(100.0, newOxygenFlow));
        newSteelLevel = qMax(0.0, qMin(100.0, newSteelLevel));
        
        m_data["converter.temperature"] = newTemp;
        m_data["converter.oxygenFlow"] = newOxygenFlow;
        m_data["converter.steelLevel"] = newSteelLevel;
        
        // 发出信号
        emit dataUpdated("converter.temperature", newTemp);
        emit dataUpdated("converter.oxygenFlow", newOxygenFlow);
        emit dataUpdated("converter.steelLevel", newSteelLevel);
    }
    
    // 更新轧钢数据
    if (m_data["rollingMill.status"].toBool()) {
        double newSpeed = m_data["rollingMill.speed"].toDouble() + speedVariation;
        double newTemp = m_data["rollingMill.temperature"].toDouble() + tempVariation;
        double newCoolingWaterFlow = m_data["rollingMill.coolingWaterFlow"].toDouble() + flowVariation;
        
        // 确保值在合理范围内
        newSpeed = qMax(0.5, qMin(2.0, newSpeed));
        newTemp = qMax(1300.0, qMin(1500.0, newTemp));
        newCoolingWaterFlow = qMax(60.0, qMin(100.0, newCoolingWaterFlow));
        
        m_data["rollingMill.speed"] = newSpeed;
        m_data["rollingMill.temperature"] = newTemp;
        m_data["rollingMill.coolingWaterFlow"] = newCoolingWaterFlow;
        
        // 发出信号
        emit dataUpdated("rollingMill.speed", newSpeed);
        emit dataUpdated("rollingMill.temperature", newTemp);
        emit dataUpdated("rollingMill.coolingWaterFlow", newCoolingWaterFlow);
    }
}
