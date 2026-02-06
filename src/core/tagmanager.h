#ifndef HYTAGMANAGER_H
#define HYTAGMANAGER_H

#include <QObject>
#include <QMap>
#include <QString>
#include <QVariant>
#include <QVector>
#include <QMutex>

class HYTag : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString group READ group CONSTANT)
    Q_PROPERTY(QVariant value READ value NOTIFY valueChanged)
    Q_PROPERTY(QString description READ description CONSTANT)

public:
    explicit HYTag(QObject *parent = nullptr);
    HYTag(const QString &name, const QString &group, const QVariant &value, const QString &description = "", QObject *parent = nullptr);

    // Getters
    QString name() const;
    QString group() const;
    QVariant value() const;
    QString description() const;

    // Setter
    void setValue(const QVariant &value);
    void setDescription(const QString &description);

signals:
    void valueChanged(const QVariant &newValue);

private:
    QString m_hyName;
    QString m_hyGroup;
    QVariant m_hyValue;
    QString m_hyDescription;
};

class HYTagManager : public QObject
{
    Q_OBJECT

public:
    explicit HYTagManager(QObject *parent = nullptr);
    ~HYTagManager();

    // Tag management
    bool addTag(const QString &name, const QString &group, const QVariant &value, const QString &description = "");
    bool removeTag(const QString &name);
    HYTag *getTag(const QString &name) const;
    QVector<HYTag *> getTagsByGroup(const QString &group) const;
    QVector<HYTag *> getAllTags() const;
    QVector<QString> getGroups() const;

    // Tag value operations
    bool setTagValue(const QString &name, const QVariant &value);
    QVariant getTagValue(const QString &name) const;

    // Tag binding
    void bindTagToProperty(const QString &tagName, QObject *object, const char *propertyName);
    void unbindTagFromProperty(const QString &tagName, QObject *object, const char *propertyName);

signals:
    void tagAdded(const QString &name);
    void tagRemoved(const QString &name);
    void tagValueChanged(const QString &name, const QVariant &newValue);

private slots:
    void onTagValueChanged(const QVariant &newValue);

private:
    QMap<QString, HYTag *> m_hyTags;
    QMap<QString, QVector<HYTag *>> m_hyTagsByGroup;
    QMutex m_hyMutex;

    // Binding management
    struct Binding {
        QObject *object;
        const char *propertyName;
    };
    QMap<QString, QVector<Binding>> m_hyBindings;
};

#endif // HYTAGMANAGER_H
