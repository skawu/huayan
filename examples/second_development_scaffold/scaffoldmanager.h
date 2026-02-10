#ifndef SCAFFOLDMANAGER_H
#define SCAFFOLDMANAGER_H

#include <QObject>
#include <QMap>
#include <QVariant>

// 包含Huayan核心头文件
#include "core/tagmanager.h"
#include "core/dataprocessor.h"
#include "core/chartdatamodel.h"

/**
 * @brief 脚手架管理器
 * 
 * 负责管理二次开发脚手架的核心功能，包括模板管理、API调用示例等
 * 复用Huayan的核心模块，提供二次开发的基础框架
 */
class ScaffoldManager : public QObject
{
    Q_OBJECT

    // 属性
    Q_PROPERTY(QMap<QString, QVariant> templateList READ templateList NOTIFY templateListChanged)
    Q_PROPERTY(QMap<QString, QVariant> apiList READ apiList NOTIFY apiListChanged)

public:
    explicit ScaffoldManager(QObject *parent = nullptr);
    ~ScaffoldManager();

    // 方法
    Q_INVOKABLE void initialize();
    Q_INVOKABLE void createTemplate(const QString &templateName, const QString &templateType);
    Q_INVOKABLE void loadTemplate(const QString &templateName);
    Q_INVOKABLE void exportTemplate(const QString &templateName, const QString &filePath);
    Q_INVOKABLE void importTemplate(const QString &filePath);
    Q_INVOKABLE void runApiDemo(const QString &apiName);

    // 属性读取方法
    QMap<QString, QVariant> templateList() const;
    QMap<QString, QVariant> apiList() const;

signals:
    // 信号
    void templateListChanged();
    void apiListChanged();
    void templateCreated(const QString &templateName);
    void templateLoaded(const QString &templateName);
    void apiDemoFinished(const QString &apiName, const QString &result);

private:
    // 私有成员
    TagManager *m_tagManager;
    DataProcessor *m_dataProcessor;
    ChartDataModel *m_chartDataModel;
    QMap<QString, QVariant> m_templateList;
    QMap<QString, QVariant> m_apiList;
    
    // 方法
    void initializeTemplates();
    void initializeApiList();
};

#endif // SCAFFOLDMANAGER_H
