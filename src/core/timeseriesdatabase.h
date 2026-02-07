#ifndef HYTIMESERIESDATABASE_H
#define HYTIMESERIESDATABASE_H

#include <QObject>
#include <QString>
#include <QVariant>
#include <QDateTime>
#include <QMap>
#include <QMutex>

class HYTimeSeriesDatabase : public QObject
{
    Q_OBJECT

public:
    enum DatabaseType {
        INFLUXDB,
        TIMESCALEDB,
        SQLITE
    };

    struct DatabaseConfig {
        DatabaseType type;
        QString host;
        int port;
        QString database;
        QString username;
        QString password;
        QString tableName;
    };

    explicit HYTimeSeriesDatabase(QObject *parent = nullptr);
    ~HYTimeSeriesDatabase();

    // Initialization
    bool initialize(const DatabaseConfig &config);
    void shutdown();

    // Connection management
    bool isConnected() const;
    QString connectionStatus() const;

    // Data storage
    bool storeTagValue(const QString &tagName, const QVariant &value, const QDateTime &timestamp = QDateTime::currentDateTime());
    bool storeTagValues(const QMap<QString, QVariant> &tagValues, const QDateTime &timestamp = QDateTime::currentDateTime());

    // Data retrieval
    QMap<QDateTime, QVariant> queryTagHistory(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime, int limit = 1000);
    QMap<QString, QMap<QDateTime, QVariant>> queryMultipleTagsHistory(const QStringList &tagNames, const QDateTime &startTime, const QDateTime &endTime, int limit = 1000);

    // Database operations
    bool createDatabase();
    bool createTable();
    bool clearData(const QString &tagName = QString());

signals:
    void connected();
    void disconnected();
    void dataStored(const QString &tagName, const QVariant &value);
    void dataRetrieved(const QString &tagName, int count);

private:
    // Database-specific implementations
    bool connectToInfluxDB();
    bool connectToTimescaleDB();
    bool connectToSQLite();

    bool storeInInfluxDB(const QString &tagName, const QVariant &value, const QDateTime &timestamp);
    bool storeInTimescaleDB(const QString &tagName, const QVariant &value, const QDateTime &timestamp);
    bool storeInSQLite(const QString &tagName, const QVariant &value, const QDateTime &timestamp);

    QMap<QDateTime, QVariant> queryFromInfluxDB(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime, int limit);
    QMap<QDateTime, QVariant> queryFromTimescaleDB(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime, int limit);
    QMap<QDateTime, QVariant> queryFromSQLite(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime, int limit);

    // Private members
    DatabaseConfig m_config;
    bool m_connected;
    QString m_status;
    QMutex m_mutex;

    // Database-specific handles (to be defined in implementation)
    void *m_dbHandle; // Void pointer to be cast to specific database handle
};

#endif // HYTIMESERIESDATABASE_H
