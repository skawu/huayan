#ifndef EDITORCORE_H
#define EDITORCORE_H

#include <QObject>
#include <QMap>
#include <QVariant>
#include <QPointF>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

class EditorCore : public QObject
{
    Q_OBJECT

public:
    explicit EditorCore(QObject *parent = nullptr);
    ~EditorCore();

    Q_INVOKABLE void initialize();
    Q_INVOKABLE QVariantMap createComponent(const QString &type, const QPointF &position);
    Q_INVOKABLE void updateComponentPosition(const QString &id, const QPointF &position);
    Q_INVOKABLE void updateComponentProperty(const QString &id, const QString &property, const QVariant &value);
    Q_INVOKABLE void deleteComponent(const QString &id);
    Q_INVOKABLE QPointF snapToGrid(const QPointF &position);
    Q_INVOKABLE QPointF snapToComponent(const QPointF &position, const QString &excludeId = "");
    Q_INVOKABLE QVariantMap getComponentById(const QString &id) const;
    Q_INVOKABLE QVariantList getAllComponents() const;
    Q_INVOKABLE bool importTemplate(const QString &filePath);
    Q_INVOKABLE bool exportTemplate(const QString &filePath);
    Q_INVOKABLE void loadIndustryTemplate(const QString &industry);

signals:
    void componentCreated(const QVariantMap &component);
    void componentUpdated(const QString &id, const QVariantMap &properties);
    void componentDeleted(const QString &id);
    void templateLoaded(const QString &industry);

private:
    QMap<QString, QVariantMap> m_components;
    QJsonDocument m_currentTemplate;
    QPointF m_gridSize;
    qreal m_snapThreshold;

    QString generateComponentId();
    QPointF calculateSnapPosition(const QPointF &position);
    void loadSteelIndustryTemplate();
    void loadChemicalIndustryTemplate();
    void loadPowerIndustryTemplate();
};

#endif // EDITORCORE_H
