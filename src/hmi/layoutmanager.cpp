#include "layoutmanager.h"
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QStandardPaths>

LayoutManager::LayoutManager(QObject *parent) : QObject(parent)
{
    initializeTemplatePath();
    scanTemplateDirectory();
}

LayoutManager::~LayoutManager()
{
}

bool LayoutManager::saveTemplate(const QString &name, const QJsonObject &layoutData)
{
    if (name.isEmpty()) {
        emit templateError("Template name cannot be empty");
        return false;
    }

    // 确保模板目录存在
    QDir templateDir(m_templatePath);
    if (!templateDir.exists()) {
        if (!templateDir.mkpath(m_templatePath)) {
            emit templateError("Failed to create template directory");
            return false;
        }
    }

    // 保存模板
    if (writeTemplateToFile(name, layoutData)) {
        m_currentTemplate = name;
        emit currentTemplateChanged();
        emit templateSaved(name);
        
        // 重新扫描模板目录
        scanTemplateDirectory();
        return true;
    }

    return false;
}

QJsonObject LayoutManager::loadTemplate(const QString &name)
{
    if (name.isEmpty()) {
        emit templateError("Template name cannot be empty");
        return QJsonObject();
    }

    QJsonObject layoutData = readTemplateFromFile(name);
    if (!layoutData.isEmpty()) {
        m_currentTemplate = name;
        emit currentTemplateChanged();
        emit templateLoaded(name);
    }

    return layoutData;
}

bool LayoutManager::deleteTemplate(const QString &name)
{
    if (name.isEmpty()) {
        emit templateError("Template name cannot be empty");
        return false;
    }

    QString templateFile = m_templatePath + "/" + name + ".json";
    QFile file(templateFile);

    if (!file.exists()) {
        emit templateError("Template does not exist");
        return false;
    }

    if (file.remove()) {
        if (m_currentTemplate == name) {
            m_currentTemplate.clear();
            emit currentTemplateChanged();
        }

        emit templateDeleted(name);
        
        // 重新扫描模板目录
        scanTemplateDirectory();
        return true;
    }

    emit templateError("Failed to delete template");
    return false;
}

void LayoutManager::listTemplates()
{
    scanTemplateDirectory();
}

QString LayoutManager::currentTemplate() const
{
    return m_currentTemplate;
}

void LayoutManager::setCurrentTemplate(const QString &name)
{
    if (m_currentTemplate != name) {
        m_currentTemplate = name;
        emit currentTemplateChanged();
    }
}

QVector<QString> LayoutManager::templates() const
{
    return m_templates;
}

QString LayoutManager::templatePath() const
{
    return m_templatePath;
}

void LayoutManager::initializeTemplatePath()
{
    // 使用应用程序数据目录作为模板存储位置
    QString appDataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    m_templatePath = appDataDir + "/layouts";
}

bool LayoutManager::writeTemplateToFile(const QString &name, const QJsonObject &data)
{
    QString templateFile = m_templatePath + "/" + name + ".json";
    QFile file(templateFile);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        emit templateError("Failed to open template file for writing");
        return false;
    }

    QJsonDocument doc(data);
    QByteArray jsonData = doc.toJson(QJsonDocument::Indented);

    if (file.write(jsonData) == -1) {
        emit templateError("Failed to write template file");
        file.close();
        return false;
    }

    file.close();
    return true;
}

QJsonObject LayoutManager::readTemplateFromFile(const QString &name)
{
    QString templateFile = m_templatePath + "/" + name + ".json";
    QFile file(templateFile);

    if (!file.exists()) {
        emit templateError("Template file does not exist");
        return QJsonObject();
    }

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        emit templateError("Failed to open template file for reading");
        return QJsonObject();
    }

    QByteArray jsonData = file.readAll();
    QJsonDocument doc = QJsonDocument::fromJson(jsonData);

    if (!doc.isObject()) {
        emit templateError("Invalid template file format");
        file.close();
        return QJsonObject();
    }

    file.close();
    return doc.object();
}

void LayoutManager::scanTemplateDirectory()
{
    QVector<QString> templateNames;
    QDir templateDir(m_templatePath);

    if (templateDir.exists()) {
        // 获取所有.json文件
        QStringList filters;
        filters << "*.json";
        templateDir.setNameFilters(filters);

        QFileInfoList fileInfos = templateDir.entryInfoList(QDir::Files, QDir::Name);
        for (const QFileInfo &fileInfo : fileInfos) {
            QString templateName = fileInfo.baseName();
            templateNames.append(templateName);
        }
    }

    if (m_templates != templateNames) {
        m_templates = templateNames;
        emit templatesChanged();
    }
}
