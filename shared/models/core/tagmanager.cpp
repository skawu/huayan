#include "tagmanager.h"
#include <QDebug>
#include <QRandomGenerator>

TagManager::TagManager(QObject *parent)
    : QObject(parent)
    , m_simulationTimer(new QTimer(this))
{
    // 设置模拟数据更新定时器
    m_simulationTimer->setInterval(1000); // 1秒更新一次
    connect(m_simulationTimer, &QTimer::timeout, this, &TagManager::simulateDataUpdate);
    m_simulationTimer->start();
    
    // 注册一些示例标签
    registerTag("temperature", "double");
    registerTag("pressure", "double");
    registerTag("flow_rate", "double");
    registerTag("motor_status", "string");
    registerTag("valve_position", "int");
    
    qDebug() << "TagManager initialized with" << m_tags.size() << "tags";
}

TagManager::~TagManager()
{
    m_simulationTimer->stop();
}

bool TagManager::registerTag(const QString &name, const QString &dataType)
{
    if (m_tags.contains(name)) {
        qDebug() << "Tag already exists:" << name;
        return false;
    }
    
    TagInfo info;
    info.name = name;
    info.dataType = dataType;
    info.isValid = true;
    info.lastUpdate = QDateTime::currentDateTime();
    info.description = QString("Auto-generated tag: %1").arg(name);
    
    // 设置初始值
    if (dataType == "double") {
        info.value = 0.0;
    } else if (dataType == "int") {
        info.value = 0;
    } else if (dataType == "string") {
        info.value = "";
    } else if (dataType == "bool") {
        info.value = false;
    }
    
    m_tags[name] = info;
    emit tagAdded(name);
    qDebug() << "Registered tag:" << name << "type:" << dataType;
    return true;
}

bool TagManager::updateTagValue(const QString &name, const QVariant &value)
{
    if (!m_tags.contains(name)) {
        qDebug() << "Tag not found:" << name;
        return false;
    }
    
    QVariant oldValue = m_tags[name].value;
    m_tags[name].value = value;
    m_tags[name].lastUpdate = QDateTime::currentDateTime();
    
    emit tagValueChanged(name, value);
    qDebug() << "Updated tag:" << name << "value:" << value;
    return true;
}

QVariant TagManager::getTagValue(const QString &name) const
{
    if (!m_tags.contains(name)) {
        return QVariant();
    }
    return m_tags[name].value;
}

QVariantMap TagManager::getTagInfo(const QString &name) const
{
    QVariantMap info;
    auto it = m_tags.find(name);
    if (it != m_tags.end()) {
        const TagInfo& tagInfo = it.value();
        info["name"] = tagInfo.name;
        info["value"] = tagInfo.value;
        info["dataType"] = tagInfo.dataType;
        info["lastUpdate"] = tagInfo.lastUpdate;
        info["isValid"] = tagInfo.isValid;
        info["description"] = tagInfo.description;
    }
    return info;
}

bool TagManager::hasTag(const QString &name) const
{
    return m_tags.contains(name);
}

QStringList TagManager::getAllTags() const
{
    return QStringList(m_tags.keys());
}

void TagManager::simulateDataUpdate()
{
    // 模拟温度数据 (50-200°C)
    double temp = 50.0 + QRandomGenerator::global()->bounded(150.0);
    updateTagValue("temperature", temp);
    
    // 模拟压力数据 (5-15 MPa)
    double pressure = 5.0 + QRandomGenerator::global()->bounded(10.0);
    updateTagValue("pressure", pressure);
    
    // 模拟流量数据 (0-1000 m³/h)
    double flow = QRandomGenerator::global()->bounded(1000.0);
    updateTagValue("flow_rate", flow);
    
    // 模拟电机状态
    QStringList statuses = {"运行", "停止", "故障"};
    QString status = statuses.at(QRandomGenerator::global()->bounded(statuses.size()));
    updateTagValue("motor_status", status);
    
    // 模拟阀门位置 (0-100%)
    int position = QRandomGenerator::global()->bounded(101);
    updateTagValue("valve_position", position);
}
