#include "scaffoldmanager.h"
#include <QDebug>
#include <QFile>
#include <QTextStream>

ScaffoldManager::ScaffoldManager(QObject *parent) : QObject(parent)
{
    // 初始化成员变量
    m_tagManager = new TagManager(this);
    m_dataProcessor = new DataProcessor(this);
    m_chartDataModel = new ChartDataModel(this);
}

ScaffoldManager::~ScaffoldManager()
{
    // 清理资源
    delete m_tagManager;
    delete m_dataProcessor;
    delete m_chartDataModel;
}

void ScaffoldManager::initialize()
{
    qDebug() << "初始化脚手架管理器...";
    
    // 初始化模板列表
    initializeTemplates();
    
    // 初始化API列表
    initializeApiList();
    
    qDebug() << "脚手架管理器初始化完成";
}

void ScaffoldManager::createTemplate(const QString &templateName, const QString &templateType)
{
    qDebug() << "创建模板:" << templateName << "(" << templateType << ")";
    
    // 创建模板
    QMap<QString, QVariant> templateData;
    templateData["type"] = templateType;
    templateData["created"] = QDateTime::currentDateTime().toString();
    
    // 添加到模板列表
    m_templateList[templateName] = templateData;
    
    // 发出信号
    emit templateListChanged();
    emit templateCreated(templateName);
    
    qDebug() << "模板创建完成";
}

void ScaffoldManager::loadTemplate(const QString &templateName)
{
    qDebug() << "加载模板:" << templateName;
    
    // 检查模板是否存在
    if (!m_templateList.contains(templateName)) {
        qDebug() << "模板不存在:" << templateName;
        return;
    }
    
    // 加载模板数据
    QMap<QString, QVariant> templateData = m_templateList[templateName];
    QString templateType = templateData["type"].toString();
    
    // 根据模板类型执行不同的加载逻辑
    if (templateType == "dataAcquisition") {
        // 数据采集模板
        qDebug() << "加载数据采集模板";
        // 这里可以添加数据采集模板的加载逻辑
    } else if (templateType == "visualization") {
        // 可视化面板模板
        qDebug() << "加载可视化面板模板";
        // 这里可以添加可视化面板模板的加载逻辑
    } else if (templateType == "alarm") {
        // 告警处理模板
        qDebug() << "加载告警处理模板";
        // 这里可以添加告警处理模板的加载逻辑
    }
    
    // 发出信号
    emit templateLoaded(templateName);
    
    qDebug() << "模板加载完成";
}

void ScaffoldManager::exportTemplate(const QString &templateName, const QString &filePath)
{
    qDebug() << "导出模板:" << templateName << "到" << filePath;
    
    // 检查模板是否存在
    if (!m_templateList.contains(templateName)) {
        qDebug() << "模板不存在:" << templateName;
        return;
    }
    
    // 创建文件
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qDebug() << "无法打开文件:" << filePath;
        return;
    }
    
    // 写入模板数据
    QTextStream out(&file);
    QMap<QString, QVariant> templateData = m_templateList[templateName];
    out << "TemplateName: " << templateName << "\n";
    out << "Type: " << templateData["type"].toString() << "\n";
    out << "Created: " << templateData["created"].toString() << "\n";
    
    // 关闭文件
    file.close();
    
    qDebug() << "模板导出完成";
}

void ScaffoldManager::importTemplate(const QString &filePath)
{
    qDebug() << "导入模板:" << filePath;
    
    // 打开文件
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "无法打开文件:" << filePath;
        return;
    }
    
    // 读取文件内容
    QTextStream in(&file);
    QString templateName;
    QString templateType;
    QString created;
    
    while (!in.atEnd()) {
        QString line = in.readLine();
        if (line.startsWith("TemplateName: ")) {
            templateName = line.mid(13);
        } else if (line.startsWith("Type: ")) {
            templateType = line.mid(6);
        } else if (line.startsWith("Created: ")) {
            created = line.mid(8);
        }
    }
    
    // 关闭文件
    file.close();
    
    // 创建模板
    if (!templateName.isEmpty() && !templateType.isEmpty()) {
        QMap<QString, QVariant> templateData;
        templateData["type"] = templateType;
        templateData["created"] = created;
        m_templateList[templateName] = templateData;
        
        // 发出信号
        emit templateListChanged();
        emit templateCreated(templateName);
        
        qDebug() << "模板导入完成";
    } else {
        qDebug() << "模板文件格式错误";
    }
}

void ScaffoldManager::runApiDemo(const QString &apiName)
{
    qDebug() << "运行API示例:" << apiName;
    
    // 检查API是否存在
    if (!m_apiList.contains(apiName)) {
        qDebug() << "API不存在:" << apiName;
        return;
    }
    
    // 执行API示例
    QString result;
    
    if (apiName == "tagManager.addTag") {
        // TagManager添加标签示例
        m_tagManager->addTag("DemoTag", "AI", "演示标签");
        result = "标签添加成功";
    } else if (apiName == "tagManager.updateTagValue") {
        // TagManager更新标签值示例
        m_tagManager->updateTagValue("DemoTag", 100.0);
        result = "标签值更新成功";
    } else if (apiName == "dataProcessor.processData") {
        // DataProcessor处理数据示例
        QVariant processedValue = m_dataProcessor->processData("DemoTag", 100.0);
        result = "数据处理结果: " + processedValue.toString();
    } else if (apiName == "chartDataModel.addDataPoint") {
        // ChartDataModel添加数据点示例
        m_chartDataModel->addDataPoint("DemoChart", QDateTime::currentDateTime(), 100.0);
        result = "数据点添加成功";
    } else {
        result = "API示例执行完成";
    }
    
    // 发出信号
    emit apiDemoFinished(apiName, result);
    
    qDebug() << "API示例执行完成";
}

QMap<QString, QVariant> ScaffoldManager::templateList() const
{
    return m_templateList;
}

QMap<QString, QVariant> ScaffoldManager::apiList() const
{
    return m_apiList;
}

void ScaffoldManager::initializeTemplates()
{
    qDebug() << "初始化模板列表...";
    
    // 添加预设模板
    QMap<QString, QVariant> dataAcquisitionTemplate;
    dataAcquisitionTemplate["type"] = "dataAcquisition";
    dataAcquisitionTemplate["created"] = QDateTime::currentDateTime().toString();
    m_templateList["数据采集模板"] = dataAcquisitionTemplate;
    
    QMap<QString, QVariant> visualizationTemplate;
    visualizationTemplate["type"] = "visualization";
    visualizationTemplate["created"] = QDateTime::currentDateTime().toString();
    m_templateList["可视化面板模板"] = visualizationTemplate;
    
    QMap<QString, QVariant> alarmTemplate;
    alarmTemplate["type"] = "alarm";
    alarmTemplate["created"] = QDateTime::currentDateTime().toString();
    m_templateList["告警处理模板"] = alarmTemplate;
    
    qDebug() << "模板列表初始化完成";
}

void ScaffoldManager::initializeApiList()
{
    qDebug() << "初始化API列表...";
    
    // 添加API示例
    QMap<QString, QVariant> tagManagerApi;
    tagManagerApi["category"] = "TagManager";
    tagManagerApi["description"] = "标签管理API";
    m_apiList["tagManager.addTag"] = tagManagerApi;
    m_apiList["tagManager.updateTagValue"] = tagManagerApi;
    
    QMap<QString, QVariant> dataProcessorApi;
    dataProcessorApi["category"] = "DataProcessor";
    dataProcessorApi["description"] = "数据处理API";
    m_apiList["dataProcessor.processData"] = dataProcessorApi;
    
    QMap<QString, QVariant> chartDataModelApi;
    chartDataModelApi["category"] = "ChartDataModel";
    chartDataModelApi["description"] = "图表数据API";
    m_apiList["chartDataModel.addDataPoint"] = chartDataModelApi;
    
    qDebug() << "API列表初始化完成";
}
