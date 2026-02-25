#ifndef LAYOUTMANAGER_H
#define LAYOUTMANAGER_H

#include <QObject>
#include <QString>
#include <QVector>
#include <QMap>
#include <QJsonObject>

class LayoutManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentTemplate READ currentTemplate WRITE setCurrentTemplate NOTIFY currentTemplateChanged)
    Q_PROPERTY(QVector<QString> templates READ templates NOTIFY templatesChanged)

public:
    explicit LayoutManager(QObject *parent = nullptr);
    ~LayoutManager();

    // 模板管理
    Q_INVOKABLE bool saveTemplate(const QString &name, const QJsonObject &layoutData);
    Q_INVOKABLE QJsonObject loadTemplate(const QString &name);
    Q_INVOKABLE bool deleteTemplate(const QString &name);
    Q_INVOKABLE void listTemplates();
    
    // 获取当前模板
    QString currentTemplate() const;
    void setCurrentTemplate(const QString &name);
    
    // 获取模板列表
    QVector<QString> templates() const;
    
    // 模板文件路径
    Q_INVOKABLE QString templatePath() const;

signals:
    void currentTemplateChanged();
    void templatesChanged();
    void templateSaved(const QString &name);
    void templateLoaded(const QString &name);
    void templateDeleted(const QString &name);
    void templateError(const QString &error);

private:
    QString m_currentTemplate;
    QVector<QString> m_templates;
    QString m_templatePath;
    
    // 初始化模板路径
    void initializeTemplatePath();
    
    // 序列化/反序列化
    bool writeTemplateToFile(const QString &name, const QJsonObject &data);
    QJsonObject readTemplateFromFile(const QString &name);
    
    // 扫描模板目录
    void scanTemplateDirectory();
};

#endif // LAYOUTMANAGER_H
