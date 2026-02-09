#ifndef HYTIMESERIESDATABASE_H
#define HYTIMESERIESDATABASE_H

#include <QObject>
#include <QString>
#include <QVariant>
#include <QDateTime>
#include <QMap>
#include <QMutex>

/**
 * @file timeseriesdatabase.h
 * @brief 时间序列数据库类头文件
 * 
 * 此类实现了时间序列数据库的操作功能，包括连接管理、数据存储和查询等
 */

/**
 * @class HYTimeSeriesDatabase
 * @brief 时间序列数据库类
 * 
 * 负责与时间序列数据库的交互，支持InfluxDB、TimescaleDB和SQLite等数据库
 */
class HYTimeSeriesDatabase : public QObject
{
    Q_OBJECT

public:
    /**
     * @enum DatabaseType
     * @brief 数据库类型枚举
     */
    enum DatabaseType {
        INFLUXDB,   ///< InfluxDB数据库
        TIMESCALEDB, ///< TimescaleDB数据库
        SQLITE      ///< SQLite数据库
    };

    /**
     * @struct DatabaseConfig
     * @brief 数据库配置结构体
     */
    struct DatabaseConfig {
        DatabaseType type; ///< 数据库类型
        QString host; ///< 数据库主机
        int port; ///< 数据库端口
        QString database; ///< 数据库名称
        QString username; ///< 用户名
        QString password; ///< 密码
        QString tableName; ///< 表名
    };

    /**
     * @brief 构造函数
     * @param parent 父对象
     */
    explicit HYTimeSeriesDatabase(QObject *parent = nullptr);
    
    /**
     * @brief 析构函数
     */
    ~HYTimeSeriesDatabase();

    // 初始化
    /**
     * @brief 初始化
     * @param config 数据库配置
     * @return 初始化是否成功
     */
    bool initialize(const DatabaseConfig &config);
    
    /**
     * @brief 关闭数据库连接
     */
    void shutdown();

    // 连接管理
    /**
     * @brief 检查是否已连接
     * @return 是否已连接
     */
    bool isConnected() const;
    
    /**
     * @brief 获取连接状态
     * @return 连接状态
     */
    QString connectionStatus() const;

    // 数据存储
    /**
     * @brief 存储标签值
     * @param tagName 标签名称
     * @param value 标签值
     * @param timestamp 时间戳
     * @return 存储是否成功
     */
    bool storeTagValue(const QString &tagName, const QVariant &value, const QDateTime &timestamp = QDateTime::currentDateTime());
    
    /**
     * @brief 批量存储标签值
     * @param tagValues 标签值映射
     * @param timestamp 时间戳
     * @return 存储是否成功
     */
    bool storeTagValues(const QMap<QString, QVariant> &tagValues, const QDateTime &timestamp = QDateTime::currentDateTime());

    // 数据查询
    /**
     * @brief 查询标签历史数据
     * @param tagName 标签名称
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @param limit 限制数量
     * @return 历史数据
     */
    QMap<QDateTime, QVariant> queryTagHistory(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime, int limit = 1000);
    
    /**
     * @brief 批量查询标签历史数据
     * @param tagNames 标签名称列表
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @param limit 限制数量
     * @return 批量历史数据
     */
    QMap<QString, QMap<QDateTime, QVariant>> queryMultipleTagsHistory(const QStringList &tagNames, const QDateTime &startTime, const QDateTime &endTime, int limit = 1000);

    // 数据库操作
    /**
     * @brief 创建数据库
     * @return 创建是否成功
     */
    bool createDatabase();
    
    /**
     * @brief 创建表
     * @return 创建是否成功
     */
    bool createTable();
    
    /**
     * @brief 清除数据
     * @param tagName 标签名称，为空则清除所有数据
     * @return 清除是否成功
     */
    bool clearData(const QString &tagName = QString());

signals:
    /**
     * @brief 连接成功信号
     */
    void connected();
    
    /**
     * @brief 断开连接信号
     */
    void disconnected();
    
    /**
     * @brief 数据存储成功信号
     * @param tagName 标签名称
     * @param value 标签值
     */
    void dataStored(const QString &tagName, const QVariant &value);
    
    /**
     * @brief 数据查询成功信号
     * @param tagName 标签名称
     * @param count 查询数量
     */
    void dataRetrieved(const QString &tagName, int count);

private:
    // 数据库特定实现
    /**
     * @brief 连接到InfluxDB
     * @return 连接是否成功
     */
    bool connectToInfluxDB();
    
    /**
     * @brief 连接到TimescaleDB
     * @return 连接是否成功
     */
    bool connectToTimescaleDB();
    
    /**
     * @brief 连接到SQLite
     * @return 连接是否成功
     */
    bool connectToSQLite();

    /**
     * @brief 存储数据到InfluxDB
     * @param tagName 标签名称
     * @param value 标签值
     * @param timestamp 时间戳
     * @return 存储是否成功
     */
    bool storeInInfluxDB(const QString &tagName, const QVariant &value, const QDateTime &timestamp);
    
    /**
     * @brief 存储数据到TimescaleDB
     * @param tagName 标签名称
     * @param value 标签值
     * @param timestamp 时间戳
     * @return 存储是否成功
     */
    bool storeInTimescaleDB(const QString &tagName, const QVariant &value, const QDateTime &timestamp);
    
    /**
     * @brief 存储数据到SQLite
     * @param tagName 标签名称
     * @param value 标签值
     * @param timestamp 时间戳
     * @return 存储是否成功
     */
    bool storeInSQLite(const QString &tagName, const QVariant &value, const QDateTime &timestamp);

    /**
     * @brief 从InfluxDB查询数据
     * @param tagName 标签名称
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @param limit 限制数量
     * @return 查询结果
     */
    QMap<QDateTime, QVariant> queryFromInfluxDB(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime, int limit);
    
    /**
     * @brief 从TimescaleDB查询数据
     * @param tagName 标签名称
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @param limit 限制数量
     * @return 查询结果
     */
    QMap<QDateTime, QVariant> queryFromTimescaleDB(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime, int limit);
    
    /**
     * @brief 从SQLite查询数据
     * @param tagName 标签名称
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @param limit 限制数量
     * @return 查询结果
     */
    QMap<QDateTime, QVariant> queryFromSQLite(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime, int limit);

    // 私有成员
    DatabaseConfig m_config; ///< 数据库配置
    bool m_connected; ///< 是否连接
    QString m_status; ///< 连接状态
    QMutex m_mutex; ///< 互斥锁

    // 数据库特定句柄（在实现中定义）
    void *m_dbHandle; ///< 通用数据库句柄指针，需要转换为特定数据库句柄
};

#endif // HYTIMESERIESDATABASE_H
