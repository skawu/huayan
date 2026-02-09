#include "timeseriesdatabase.h"
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QFile>
#include <QDebug>
#include <QEventLoop>

HYTimeSeriesDatabase::HYTimeSeriesDatabase(QObject *parent) : QObject(parent),
    m_connected(false),
    m_dbHandle(nullptr)
{
}

HYTimeSeriesDatabase::~HYTimeSeriesDatabase()
{
    shutdown();
}

bool HYTimeSeriesDatabase::initialize(const DatabaseConfig &config)
{
    m_config = config;
    m_connected = false;
    m_status = "Disconnected";

    // Connect to the appropriate database
    switch (m_config.type) {
    case INFLUXDB:
        m_connected = connectToInfluxDB();
        break;
    case TIMESCALEDB:
        m_connected = connectToTimescaleDB();
        break;
    case SQLITE:
        m_connected = connectToSQLite();
        break;
    default:
        m_status = "Unsupported database type";
        return false;
    }

    if (m_connected) {
        m_status = "Connected";
        emit connected();

        // Create database and table if needed
        createDatabase();
        createTable();
    }

    return m_connected;
}

void HYTimeSeriesDatabase::shutdown()
{
    if (m_connected) {
        m_connected = false;
        m_status = "Disconnected";

        // Clean up database-specific resources
        switch (m_config.type) {
        case INFLUXDB:
            // InfluxDB uses HTTP, no persistent connection to close
            break;
        case TIMESCALEDB:
            // TimescaleDB uses PostgreSQL, close connection
            if (m_dbHandle) {
                QSqlDatabase *db = static_cast<QSqlDatabase *>(m_dbHandle);
                db->close();
                delete db;
                m_dbHandle = nullptr;
            }
            break;
        case SQLITE:
            // SQLite uses QSqlDatabase, close connection
            if (m_dbHandle) {
                QSqlDatabase *db = static_cast<QSqlDatabase *>(m_dbHandle);
                db->close();
                delete db;
                m_dbHandle = nullptr;
            }
            break;
        }

        emit disconnected();
    }
}

bool HYTimeSeriesDatabase::isConnected() const
{
    return m_connected;
}

QString HYTimeSeriesDatabase::connectionStatus() const
{
    return m_status;
}

bool HYTimeSeriesDatabase::storeTagValue(const QString &tagName, const QVariant &value, const QDateTime &timestamp)
{
    if (!m_connected) {
        return false;
    }

    bool success = false;

    switch (m_config.type) {
    case INFLUXDB:
        success = storeInInfluxDB(tagName, value, timestamp);
        break;
    case TIMESCALEDB:
        success = storeInTimescaleDB(tagName, value, timestamp);
        break;
    case SQLITE:
        success = storeInSQLite(tagName, value, timestamp);
        break;
    }

    if (success) {
        emit dataStored(tagName, value);
    }

    return success;
}

bool HYTimeSeriesDatabase::storeTagValues(const QMap<QString, QVariant> &tagValues, const QDateTime &timestamp)
{
    if (!m_connected) {
        return false;
    }

    bool allSuccess = true;

    for (auto it = tagValues.constBegin(); it != tagValues.constEnd(); ++it) {
        if (!storeTagValue(it.key(), it.value(), timestamp)) {
            allSuccess = false;
        }
    }

    return allSuccess;
}

QMap<QDateTime, QVariant> HYTimeSeriesDatabase::queryTagHistory(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime, int limit)
{
    if (!m_connected) {
        return QMap<QDateTime, QVariant>();
    }

    QMap<QDateTime, QVariant> result;

    switch (m_config.type) {
    case INFLUXDB:
        result = queryFromInfluxDB(tagName, startTime, endTime, limit);
        break;
    case TIMESCALEDB:
        result = queryFromTimescaleDB(tagName, startTime, endTime, limit);
        break;
    case SQLITE:
        result = queryFromSQLite(tagName, startTime, endTime, limit);
        break;
    }

    emit dataRetrieved(tagName, result.size());
    return result;
}

QMap<QString, QMap<QDateTime, QVariant>> HYTimeSeriesDatabase::queryMultipleTagsHistory(const QStringList &tagNames, const QDateTime &startTime, const QDateTime &endTime, int limit)
{
    QMap<QString, QMap<QDateTime, QVariant>> result;

    for (const QString &tagName : tagNames) {
        result[tagName] = queryTagHistory(tagName, startTime, endTime, limit);
    }

    return result;
}

bool HYTimeSeriesDatabase::createDatabase()
{
    if (!m_connected) {
        return false;
    }

    // Database creation is handled differently for each type
    switch (m_config.type) {
    case INFLUXDB:
        // InfluxDB creates databases automatically on first write
        return true;
    case TIMESCALEDB:
        // TimescaleDB (PostgreSQL) requires explicit creation
        if (m_dbHandle) {
            QSqlDatabase *db = static_cast<QSqlDatabase *>(m_dbHandle);
            QSqlQuery query(*db);
            QString sql = QString("CREATE DATABASE IF NOT EXISTS %1").arg(m_config.database);
            return query.exec(sql);
        }
        return false;
    case SQLITE:
        // SQLite creates databases automatically
        return true;
    default:
        return false;
    }
}

bool HYTimeSeriesDatabase::createTable()
{
    if (!m_connected) {
        return false;
    }

    switch (m_config.type) {
    case INFLUXDB:
        // InfluxDB uses measurements instead of tables
        return true;
    case TIMESCALEDB:
        if (m_dbHandle) {
            QSqlDatabase *db = static_cast<QSqlDatabase *>(m_dbHandle);
            QSqlQuery query(*db);
            
            // Create regular table
            QString sql = QString(
                "CREATE TABLE IF NOT EXISTS %1 (" 
                "timestamp TIMESTAMP NOT NULL, " 
                "tag_name TEXT NOT NULL, " 
                "value DOUBLE PRECISION, " 
                "value_text TEXT, " 
                "PRIMARY KEY (timestamp, tag_name)" 
                ")").arg(m_config.tableName);
            
            if (!query.exec(sql)) {
                qDebug() << "Failed to create table:" << query.lastError().text();
                return false;
            }
            
            // Convert to hypertable for TimescaleDB
            sql = QString("SELECT create_hypertable('%1', 'timestamp')").arg(m_config.tableName);
            return query.exec(sql);
        }
        return false;
    case SQLITE:
        if (m_dbHandle) {
            QSqlDatabase *db = static_cast<QSqlDatabase *>(m_dbHandle);
            QSqlQuery query(*db);
            
            QString sql = QString(
                "CREATE TABLE IF NOT EXISTS %1 (" 
                "timestamp INTEGER NOT NULL, " 
                "tag_name TEXT NOT NULL, " 
                "value REAL, " 
                "value_text TEXT, " 
                "PRIMARY KEY (timestamp, tag_name)" 
                ")").arg(m_config.tableName);
            
            return query.exec(sql);
        }
        return false;
    default:
        return false;
    }
}

bool HYTimeSeriesDatabase::clearData(const QString &tagName)
{
    if (!m_connected) {
        return false;
    }

    switch (m_config.type) {
    case INFLUXDB:
        // InfluxDB uses DELETE queries
        // Implementation depends on InfluxDB version
        return true;
    case TIMESCALEDB:
        if (m_dbHandle) {
            QSqlDatabase *db = static_cast<QSqlDatabase *>(m_dbHandle);
            QSqlQuery query(*db);
            QString sql;
            
            if (tagName.isEmpty()) {
                sql = QString("DELETE FROM %1").arg(m_config.tableName);
            } else {
                sql = QString("DELETE FROM %1 WHERE tag_name = '%2'").arg(m_config.tableName).arg(tagName);
            }
            
            return query.exec(sql);
        }
        return false;
    case SQLITE:
        if (m_dbHandle) {
            QSqlDatabase *db = static_cast<QSqlDatabase *>(m_dbHandle);
            QSqlQuery query(*db);
            QString sql;
            
            if (tagName.isEmpty()) {
                sql = QString("DELETE FROM %1").arg(m_config.tableName);
            } else {
                sql = QString("DELETE FROM %1 WHERE tag_name = '%2'").arg(m_config.tableName).arg(tagName);
            }
            
            return query.exec(sql);
        }
        return false;
    default:
        return false;
    }
}

bool HYTimeSeriesDatabase::connectToInfluxDB()
{
    // InfluxDB uses HTTP API, no persistent connection
    // Just validate configuration
    if (m_config.host.isEmpty() || m_config.port <= 0) {
        m_status = "Invalid InfluxDB configuration";
        return false;
    }

    m_status = "Connected to InfluxDB";
    return true;
}

bool HYTimeSeriesDatabase::connectToTimescaleDB()
{
    // TimescaleDB uses PostgreSQL
    QSqlDatabase *db = new QSqlDatabase(QSqlDatabase::addDatabase("QPSQL"));
    db->setHostName(m_config.host);
    db->setPort(m_config.port);
    db->setDatabaseName(m_config.database);
    db->setUserName(m_config.username);
    db->setPassword(m_config.password);

    if (!db->open()) {
        m_status = "Failed to connect to TimescaleDB: " + db->lastError().text();
        delete db;
        return false;
    }

    m_dbHandle = db;
    m_status = "Connected to TimescaleDB";
    return true;
}

bool HYTimeSeriesDatabase::connectToSQLite()
{
    // SQLite uses local file
    QString dbPath = m_config.host.isEmpty() ? m_config.database : m_config.host;
    QSqlDatabase *db = new QSqlDatabase(QSqlDatabase::addDatabase("QSQLITE"));
    db->setDatabaseName(dbPath);

    if (!db->open()) {
        m_status = "Failed to connect to SQLite: " + db->lastError().text();
        delete db;
        return false;
    }

    m_dbHandle = db;
    m_status = "Connected to SQLite";
    return true;
}

bool HYTimeSeriesDatabase::storeInInfluxDB(const QString &tagName, const QVariant &value, const QDateTime &timestamp)
{
    // Use HTTP API to write data to InfluxDB
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QUrl url(QString("http://%1:%2/write?db=%3&u=%4&p=%5")
             .arg(m_config.host)
             .arg(m_config.port)
             .arg(m_config.database)
             .arg(m_config.username)
             .arg(m_config.password));

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "text/plain");

    // Format data in InfluxDB line protocol
    QString lineProtocol;
    if (value.typeId() == QMetaType::Double || value.typeId() == QMetaType::Int) {
        lineProtocol = QString("%1,tag=%2 value=%3 %4")
                       .arg(m_config.tableName)
                       .arg(tagName)
                       .arg(value.toString())
                       .arg(timestamp.toMSecsSinceEpoch() * 1000000); // Nanoseconds
    } else {
        lineProtocol = QString("%1,tag=%2 value=\"%3\" %4")
                       .arg(m_config.tableName)
                       .arg(tagName)
                       .arg(value.toString().replace('"', QString("\\\"")))
                       .arg(timestamp.toMSecsSinceEpoch() * 1000000);
    }

    QNetworkReply *reply = manager->post(request, lineProtocol.toUtf8());

    // Wait for reply (synchronous for simplicity)
    QEventLoop loop;
    connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    bool success = (reply->error() == QNetworkReply::NoError);
    reply->deleteLater();
    manager->deleteLater();

    return success;
}

bool HYTimeSeriesDatabase::storeInTimescaleDB(const QString &tagName, const QVariant &value, const QDateTime &timestamp)
{
    if (!m_dbHandle) {
        return false;
    }

    QSqlDatabase *db = static_cast<QSqlDatabase *>(m_dbHandle);
    QSqlQuery query(*db);

    QString sql = QString(
        "INSERT INTO %1 (timestamp, tag_name, value, value_text) "
        "VALUES (:timestamp, :tag_name, :value, :value_text) "
        "ON CONFLICT (timestamp, tag_name) DO UPDATE SET "
        "value = :value, value_text = :value_text"
    ).arg(m_config.tableName);

    query.prepare(sql);
    query.bindValue(":timestamp", timestamp);
    query.bindValue(":tag_name", tagName);

    if (value.typeId() == QMetaType::Double || value.typeId() == QMetaType::Int) {
        query.bindValue(":value", value.toDouble());
        query.bindValue(":value_text", QVariant(QString()));
    } else {
        query.bindValue(":value", QVariant(0.0));
        query.bindValue(":value_text", value.toString());
    }

    return query.exec();
}

bool HYTimeSeriesDatabase::storeInSQLite(const QString &tagName, const QVariant &value, const QDateTime &timestamp)
{
    if (!m_dbHandle) {
        return false;
    }

    QSqlDatabase *db = static_cast<QSqlDatabase *>(m_dbHandle);
    QSqlQuery query(*db);

    QString sql = QString(
        "INSERT INTO %1 (timestamp, tag_name, value, value_text) "
        "VALUES (:timestamp, :tag_name, :value, :value_text) "
        "ON CONFLICT (timestamp, tag_name) DO UPDATE SET "
        "value = :value, value_text = :value_text"
    ).arg(m_config.tableName);

    query.prepare(sql);
    query.bindValue(":timestamp", timestamp.toMSecsSinceEpoch() / 1000); // Unix timestamp in seconds
    query.bindValue(":tag_name", tagName);

    if (value.typeId() == QMetaType::Double || value.typeId() == QMetaType::Int) {
        query.bindValue(":value", value.toDouble());
        query.bindValue(":value_text", QVariant(QString()));
    } else {
        query.bindValue(":value", QVariant(0.0));
        query.bindValue(":value_text", value.toString());
    }

    return query.exec();
}

QMap<QDateTime, QVariant> HYTimeSeriesDatabase::queryFromInfluxDB(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime, int limit)
{
    QMap<QDateTime, QVariant> result;

    // Use HTTP API to query data from InfluxDB
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QUrl url(QString("http://%1:%2/query?db=%3&u=%4&p=%5&q=%6")
             .arg(m_config.host)
             .arg(m_config.port)
             .arg(m_config.database)
             .arg(m_config.username)
             .arg(m_config.password)
             .arg(QUrl::toPercentEncoding(QString(
                 "SELECT value FROM %1 WHERE tag='%2' AND time >= '%3' AND time <= '%4' ORDER BY time DESC LIMIT %5"
                 ).arg(m_config.tableName)
                 .arg(tagName)
                 .arg(startTime.toString(Qt::ISODate))
                 .arg(endTime.toString(Qt::ISODate))
                 .arg(limit))));

    QNetworkRequest request(url);
    QNetworkReply *reply = manager->get(request);

    // Wait for reply (synchronous for simplicity)
    QEventLoop loop;
    connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    if (reply->error() == QNetworkReply::NoError) {
        QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        if (doc.isObject()) {
            QJsonObject root = doc.object();
            if (root.contains("results")) {
                QJsonArray results = root["results"].toArray();
                if (!results.isEmpty()) {
                    QJsonObject resultObj = results[0].toObject();
                    if (resultObj.contains("series")) {
                        QJsonArray series = resultObj["series"].toArray();
                        if (!series.isEmpty()) {
                            QJsonObject seriesObj = series[0].toObject();
                            if (seriesObj.contains("values")) {
                                QJsonArray values = seriesObj["values"].toArray();
                                for (const QJsonValue &value : values) {
                                    QJsonArray valueArray = value.toArray();
                                    if (valueArray.size() >= 2) {
                                        QString timeStr = valueArray[0].toString();
                                        QDateTime time = QDateTime::fromString(timeStr, Qt::ISODate);
                                        QJsonValue val = valueArray[1];
                                        if (val.isDouble()) {
                                            result[time] = val.toDouble();
                                        } else if (val.isString()) {
                                            result[time] = val.toString();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    reply->deleteLater();
    manager->deleteLater();
    return result;
}

QMap<QDateTime, QVariant> HYTimeSeriesDatabase::queryFromTimescaleDB(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime, int limit)
{
    QMap<QDateTime, QVariant> result;

    if (!m_dbHandle) {
        return result;
    }

    QSqlDatabase *db = static_cast<QSqlDatabase *>(m_dbHandle);
    QSqlQuery query(*db);

    QString sql = QString(
        "SELECT timestamp, value, value_text FROM %1 "
        "WHERE tag_name = :tag_name AND timestamp >= :start_time AND timestamp <= :end_time "
        "ORDER BY timestamp DESC LIMIT :limit"
    ).arg(m_config.tableName);

    query.prepare(sql);
    query.bindValue(":tag_name", tagName);
    query.bindValue(":start_time", startTime);
    query.bindValue(":end_time", endTime);
    query.bindValue(":limit", limit);

    if (query.exec()) {
        while (query.next()) {
            QDateTime time = query.value(0).toDateTime();
            QVariant value;
            
            if (!query.value(1).isNull()) {
                value = query.value(1).toDouble();
            } else if (!query.value(2).isNull()) {
                value = query.value(2).toString();
            }
            
            result[time] = value;
        }
    }

    return result;
}

QMap<QDateTime, QVariant> HYTimeSeriesDatabase::queryFromSQLite(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime, int limit)
{
    QMap<QDateTime, QVariant> result;

    if (!m_dbHandle) {
        return result;
    }

    QSqlDatabase *db = static_cast<QSqlDatabase *>(m_dbHandle);
    QSqlQuery query(*db);

    QString sql = QString(
        "SELECT timestamp, value, value_text FROM %1 "
        "WHERE tag_name = :tag_name AND timestamp >= :start_time AND timestamp <= :end_time "
        "ORDER BY timestamp DESC LIMIT :limit"
    ).arg(m_config.tableName);

    query.prepare(sql);
    query.bindValue(":tag_name", tagName);
    query.bindValue(":start_time", startTime.toMSecsSinceEpoch() / 1000); // Unix timestamp in seconds
    query.bindValue(":end_time", endTime.toMSecsSinceEpoch() / 1000);
    query.bindValue(":limit", limit);

    if (query.exec()) {
        while (query.next()) {
            qint64 timestamp = query.value(0).toLongLong();
            QDateTime time = QDateTime::fromMSecsSinceEpoch(timestamp * 1000); // Convert back to milliseconds
            QVariant value;
            
            if (!query.value(1).isNull()) {
                value = query.value(1).toDouble();
            } else if (!query.value(2).isNull()) {
                value = query.value(2).toString();
            }
            
            result[time] = value;
        }
    }

    return result;
}
