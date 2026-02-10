#include "editorcore.h"
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QUuid>

EditorCore::EditorCore(QObject *parent) : QObject(parent)
{
    m_gridSize = QPointF(10, 10);
    m_snapThreshold = 5;
}

EditorCore::~EditorCore()
{
}

void EditorCore::initialize()
{
    qDebug() << "初始化编辑器核心...";
    m_components.clear();
    m_currentTemplate = QJsonDocument();
    qDebug() << "编辑器核心初始化完成";
}

QVariantMap EditorCore::createComponent(const QString &type, const QPointF &position)
{
    QString id = generateComponentId();
    QPointF snappedPosition = calculateSnapPosition(position);
    
    QVariantMap component;
    component["id"] = id;
    component["type"] = type;
    component["x"] = snappedPosition.x();
    component["y"] = snappedPosition.y();
    component["width"] = 200;
    component["height"] = 150;
    component["properties"] = QVariantMap();
    
    m_components[id] = component;
    
    emit componentCreated(component);
    return component;
}

void EditorCore::updateComponentPosition(const QString &id, const QPointF &position)
{
    if (m_components.contains(id)) {
        QPointF snappedPosition = calculateSnapPosition(position);
        QVariantMap &component = m_components[id];
        component["x"] = snappedPosition.x();
        component["y"] = snappedPosition.y();
        
        emit componentUpdated(id, component);
    }
}

void EditorCore::updateComponentProperty(const QString &id, const QString &property, const QVariant &value)
{
    if (m_components.contains(id)) {
        QVariantMap &component = m_components[id];
        QVariantMap properties = component["properties"].toMap();
        properties[property] = value;
        component["properties"] = properties;
        
        emit componentUpdated(id, component);
    }
}

void EditorCore::deleteComponent(const QString &id)
{
    if (m_components.contains(id)) {
        m_components.remove(id);
        emit componentDeleted(id);
    }
}

QPointF EditorCore::snapToGrid(const QPointF &position)
{
    qreal x = qRound(position.x() / m_gridSize.x()) * m_gridSize.x();
    qreal y = qRound(position.y() / m_gridSize.y()) * m_gridSize.y();
    return QPointF(x, y);
}

QPointF EditorCore::snapToComponent(const QPointF &position, const QString &excludeId)
{
    QPointF snappedPosition = position;
    
    foreach (const QString &id, m_components.keys()) {
        if (id == excludeId) continue;
        
        const QVariantMap &component = m_components[id];
        qreal compX = component["x"].toReal();
        qreal compY = component["y"].toReal();
        qreal compWidth = component["width"].toReal();
        qreal compHeight = component["height"].toReal();
        
        // 检查水平对齐
        if (qAbs(position.x() - compX) < m_snapThreshold) {
            snappedPosition.setX(compX);
        } else if (qAbs(position.x() - (compX + compWidth)) < m_snapThreshold) {
            snappedPosition.setX(compX + compWidth);
        }
        
        // 检查垂直对齐
        if (qAbs(position.y() - compY) < m_snapThreshold) {
            snappedPosition.setY(compY);
        } else if (qAbs(position.y() - (compY + compHeight)) < m_snapThreshold) {
            snappedPosition.setY(compY + compHeight);
        }
    }
    
    return snappedPosition;
}

QPointF EditorCore::calculateSnapPosition(const QPointF &position)
{
    QPointF gridSnapped = snapToGrid(position);
    QPointF componentSnapped = snapToComponent(gridSnapped);
    return componentSnapped;
}

QVariantMap EditorCore::getComponentById(const QString &id) const
{
    if (m_components.contains(id)) {
        return m_components[id];
    }
    return QVariantMap();
}

QVariantList EditorCore::getAllComponents() const
{
    QVariantList components;
    foreach (const QVariantMap &component, m_components.values()) {
        components.append(component);
    }
    return components;
}

bool EditorCore::importTemplate(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "无法打开模板文件:" << filePath;
        return false;
    }
    
    QTextStream in(&file);
    QString jsonString = in.readAll();
    file.close();
    
    QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonString.toUtf8());
    if (!jsonDoc.isObject()) {
        qDebug() << "模板文件格式错误:" << filePath;
        return false;
    }
    
    QJsonObject jsonObj = jsonDoc.object();
    if (jsonObj.contains("components")) {
        QJsonArray componentsArray = jsonObj["components"].toArray();
        m_components.clear();
        
        foreach (const QJsonValue &value, componentsArray) {
            if (value.isObject()) {
                QJsonObject componentObj = value.toObject();
                QString id = componentObj["id"].toString();
                QVariantMap component = componentObj.toVariantMap();
                m_components[id] = component;
            }
        }
    }
    
    m_currentTemplate = jsonDoc;
    return true;
}

bool EditorCore::exportTemplate(const QString &filePath)
{
    QJsonObject jsonObj;
    QJsonArray componentsArray;
    
    foreach (const QVariantMap &component, m_components.values()) {
        QJsonObject componentObj = QJsonObject::fromVariantMap(component);
        componentsArray.append(componentObj);
    }
    
    jsonObj["components"] = componentsArray;
    jsonObj["version"] = "1.0";
    jsonObj["exportTime"] = QDateTime::currentDateTime().toString(Qt::ISODate);
    
    QJsonDocument jsonDoc(jsonObj);
    
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qDebug() << "无法写入模板文件:" << filePath;
        return false;
    }
    
    QTextStream out(&file);
    out << jsonDoc.toJson(QJsonDocument::Indented);
    file.close();
    
    return true;
}

void EditorCore::loadIndustryTemplate(const QString &industry)
{
    if (industry == "steel") {
        loadSteelIndustryTemplate();
    } else if (industry == "chemical") {
        loadChemicalIndustryTemplate();
    } else if (industry == "power") {
        loadPowerIndustryTemplate();
    }
    
    emit templateLoaded(industry);
}

QString EditorCore::generateComponentId()
{
    return QUuid::createUuid().toString(QUuid::WithoutBraces);
}

void EditorCore::loadSteelIndustryTemplate()
{
    initialize();
    
    // 创建高炉组件
    QVariantMap blastFurnace = createComponent("dashboard", QPointF(100, 100));
    updateComponentProperty(blastFurnace["id"].toString(), "title", "高炉监控");
    updateComponentProperty(blastFurnace["id"].toString(), "points", QVariantList() << "blastFurnace.temperature" << "blastFurnace.pressure" << "blastFurnace.level");
    
    // 创建转炉组件
    QVariantMap converter = createComponent("dashboard", QPointF(350, 100));
    updateComponentProperty(converter["id"].toString(), "title", "转炉监控");
    updateComponentProperty(converter["id"].toString(), "points", QVariantList() << "converter.temperature" << "converter.oxygenFlow" << "converter.steelLevel");
    
    // 创建轧钢组件
    QVariantMap rollingMill = createComponent("dashboard", QPointF(600, 100));
    updateComponentProperty(rollingMill["id"].toString(), "title", "轧钢监控");
    updateComponentProperty(rollingMill["id"].toString(), "points", QVariantList() << "rollingMill.speed" << "rollingMill.temperature" << "rollingMill.coolingWaterFlow");
    
    // 创建趋势图组件
    QVariantMap trendChart = createComponent("chart", QPointF(100, 300));
    updateComponentProperty(trendChart["id"].toString(), "title", "温度趋势");
    updateComponentProperty(trendChart["id"].toString(), "points", QVariantList() << "blastFurnace.temperature" << "converter.temperature" << "rollingMill.temperature");
    
    // 创建3D视图组件
    QVariantMap view3D = createComponent("3dview", QPointF(400, 300));
    updateComponentProperty(view3D["id"].toString(), "title", "3D工厂视图");
}

void EditorCore::loadChemicalIndustryTemplate()
{
    initialize();
    
    // 创建反应釜组件
    QVariantMap reactor = createComponent("dashboard", QPointF(100, 100));
    updateComponentProperty(reactor["id"].toString(), "title", "反应釜监控");
    updateComponentProperty(reactor["id"].toString(), "points", QVariantList() << "reactor.temperature" << "reactor.pressure" << "reactor.level");
    
    // 创建精馏塔组件
    QVariantMap distillation = createComponent("dashboard", QPointF(350, 100));
    updateComponentProperty(distillation["id"].toString(), "title", "精馏塔监控");
    updateComponentProperty(distillation["id"].toString(), "points", QVariantList() << "distillation.temperature" << "distillation.pressure" << "distillation.flow");
    
    // 创建储罐组件
    QVariantMap tank = createComponent("dashboard", QPointF(600, 100));
    updateComponentProperty(tank["id"].toString(), "title", "储罐监控");
    updateComponentProperty(tank["id"].toString(), "points", QVariantList() << "tank.level" << "tank.temperature" << "tank.pressure");
    
    // 创建趋势图组件
    QVariantMap trendChart = createComponent("chart", QPointF(100, 300));
    updateComponentProperty(trendChart["id"].toString(), "title", "压力趋势");
    updateComponentProperty(trendChart["id"].toString(), "points", QVariantList() << "reactor.pressure" << "distillation.pressure" << "tank.pressure");
}

void EditorCore::loadPowerIndustryTemplate()
{
    initialize();
    
    // 创建发电机组件
    QVariantMap generator = createComponent("dashboard", QPointF(100, 100));
    updateComponentProperty(generator["id"].toString(), "title", "发电机监控");
    updateComponentProperty(generator["id"].toString(), "points", QVariantList() << "generator.speed" << "generator.voltage" << "generator.current");
    
    // 创建变压器组件
    QVariantMap transformer = createComponent("dashboard", QPointF(350, 100));
    updateComponentProperty(transformer["id"].toString(), "title", "变压器监控");
    updateComponentProperty(transformer["id"].toString(), "points", QVariantList() << "transformer.inputVoltage" << "transformer.outputVoltage" << "transformer.temperature");
    
    // 创建配电组件
    QVariantMap powerDistribution = createComponent("dashboard", QPointF(600, 100));
    updateComponentProperty(powerDistribution["id"].toString(), "title", "配电监控");
    updateComponentProperty(powerDistribution["id"].toString(), "points", QVariantList() << "powerDistribution.voltage" << "powerDistribution.current" << "powerDistribution.powerFactor");
    
    // 创建趋势图组件
    QVariantMap trendChart = createComponent("chart", QPointF(100, 300));
    updateComponentProperty(trendChart["id"].toString(), "title", "电流趋势");
    updateComponentProperty(trendChart["id"].toString(), "points", QVariantList() << "generator.current" << "transformer.outputCurrent" << "powerDistribution.current");
}
