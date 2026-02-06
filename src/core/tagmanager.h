#ifndef TAGMANAGER_H
#define TAGMANAGER_H

#include <QObject>
#include <QMap>
#include <QString>
#include <QVariant>
#include <QVector>
#include <QMutex>

class Tag : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString group READ group CONSTANT)
    Q_PROPERTY(QVariant value READ value NOTIFY valueChanged)
    Q_PROPERTY(QString description READ description CONSTANT)

public:
    explicit Tag(QObject *parent = nullptr);
    Tag(const QString &name, const QString &group, const QVariant &value, const QString &description = "", QObject *parent = nullptr);

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
    QString m_name;
    QString m_group;
    QVariant m_value;
    QString m_description;
};

class TagManager : public QObject
{
    Q_OBJECT

public:
    explicit TagManager(QObject *parent = nullptr);
    ~TagManager();

    // Tag management
    bool addTag(const QString &name, const QString &group, const QVariant &value, const QString &description = "");
    bool removeTag(const QString &name);
    Tag *getTag(const QString &name) const;
    QVector<Tag *> getTagsByGroup(const QString &group) const;
    QVector<Tag *> getAllTags() const;
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
    QMap<QString, Tag *> m_tags;
    QMap<QString, QVector<Tag *>> m_tagsByGroup;
    QMutex m_mutex;

    // Binding management
    struct Binding {
        QObject *object;
        const char *propertyName;
    };
    QMap<QString, QVector<Binding>> m_bindings;
};

#endif // TAGMANAGER_H
