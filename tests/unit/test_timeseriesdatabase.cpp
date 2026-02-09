#include <QTest>
#include <QSignalSpy>
#include <QDateTime>
#include "timeseriesdatabase.h"

/**
 * @brief 时间序列数据库单元测试
 * 
 * 测试HYTimeSeriesDatabase类的功能，包括数据库连接、数据存储和查询等
 */
class TestTimeSeriesDatabase : public QObject
{
    Q_OBJECT

private slots:
    /**
     * @brief 测试初始化
     * 
     * 在每个测试前初始化测试环境
     */
    void initTestCase() {
        db = new HYTimeSeriesDatabase(this);
    }

    /**
     * @brief 测试清理
     * 
     * 在每个测试后清理测试环境
     */
    void cleanupTestCase() {
        if (db->isConnected()) {
            db->shutdown();
        }
        delete db;
    }

    /**
     * @brief 测试SQLite数据库初始化
     * 
     * 测试使用SQLite数据库的初始化功能
     */
    void testInitializeSQLite() {
        // 配置SQLite数据库
        HYTimeSeriesDatabase::DatabaseConfig config;
        config.type = HYTimeSeriesDatabase::SQLITE;
        config.host = "localhost";
        config.port = 0;
        config.database = ":memory:"; // 使用内存数据库
        config.username = "";
        config.password = "";
        config.tableName = "test_data";

        // 测试初始化
        bool result = db->initialize(config);
        QVERIFY(result);
        QVERIFY(db->isConnected());
    }

    /**
     * @brief 测试InfluxDB数据库初始化
     * 
     * 测试使用InfluxDB数据库的初始化功能（预期失败，因为没有实际的InfluxDB服务）
     */
    void testInitializeInfluxDB() {
        // 配置InfluxDB数据库
        HYTimeSeriesDatabase::DatabaseConfig config;
        config.type = HYTimeSeriesDatabase::INFLUXDB;
        config.host = "localhost";
        config.port = 8086;
        config.database = "test_db";
        config.username = "admin";
        config.password = "admin";
        config.tableName = "test_data";

        // 测试初始化（预期失败）
        bool result = db->initialize(config);
        QVERIFY(!result);
        QVERIFY(!db->isConnected());
    }

    /**
     * @brief 测试TimescaleDB数据库初始化
     * 
     * 测试使用TimescaleDB数据库的初始化功能（预期失败，因为没有实际的TimescaleDB服务）
     */
    void testInitializeTimescaleDB() {
        // 配置TimescaleDB数据库
        HYTimeSeriesDatabase::DatabaseConfig config;
        config.type = HYTimeSeriesDatabase::TIMESCALEDB;
        config.host = "localhost";
        config.port = 5432;
        config.database = "test_db";
        config.username = "postgres";
        config.password = "postgres";
        config.tableName = "test_data";

        // 测试初始化（预期失败）
        bool result = db->initialize(config);
        QVERIFY(!result);
        QVERIFY(!db->isConnected());
    }

    /**
     * @brief 测试存储标签值
     * 
     * 测试存储单个标签值到SQLite数据库
     */
    void testStoreTagValue() {
        // 先初始化SQLite数据库
        HYTimeSeriesDatabase::DatabaseConfig config;
        config.type = HYTimeSeriesDatabase::SQLITE;
        config.host = "localhost";
        config.port = 0;
        config.database = ":memory:";
        config.username = "";
        config.password = "";
        config.tableName = "test_data";

        db->initialize(config);

        // 创建信号间谍
        QSignalSpy spy(db, SIGNAL(dataStored(QString, QVariant)));

        // 测试存储标签值
        QDateTime timestamp = QDateTime::currentDateTime();
        bool result = db->storeTagValue("Test_Tag", 123.45, timestamp);
        QVERIFY(result);

        // 检查信号是否发出
        QVERIFY(spy.wait());
        QCOMPARE(spy.count(), 1);

        // 检查信号参数
        QList<QVariant> arguments = spy.takeFirst();
        QCOMPARE(arguments.at(0).toString(), QString("Test_Tag"));
        QCOMPARE(arguments.at(1).toDouble(), 123.45);
    }

    /**
     * @brief 测试查询历史数据
     * 
     * 测试查询单个标签的历史数据
     */
    void testQueryTagHistory() {
        // 先初始化SQLite数据库并存储一些数据
        HYTimeSeriesDatabase::DatabaseConfig config;
        config.type = HYTimeSeriesDatabase::SQLITE;
        config.host = "localhost";
        config.port = 0;
        config.database = ":memory:";
        config.username = "";
        config.password = "";
        config.tableName = "test_data";

        db->initialize(config);

        // 存储一些测试数据
        QDateTime now = QDateTime::currentDateTime();
        for (int i = 0; i < 5; i++) {
            QDateTime timestamp = now.addSecs(i * 60);
            db->storeTagValue("Test_Tag", 100.0 + i * 10, timestamp);
        }

        // 创建信号间谍
        QSignalSpy spy(db, SIGNAL(dataRetrieved(QString, int)));

        // 测试查询历史数据
        QMap<QDateTime, QVariant> result = db->queryTagHistory("Test_Tag", now.addSecs(-60), now.addSecs(300), 10);
        QVERIFY(result.size() >= 5);

        // 检查信号是否发出
        QVERIFY(spy.wait());
        QCOMPARE(spy.count(), 1);

        // 检查信号参数
        QList<QVariant> arguments = spy.takeFirst();
        QCOMPARE(arguments.at(0).toString(), QString("Test_Tag"));
        QVERIFY(arguments.at(1).toInt() >= 5);
    }

    /**
     * @brief 测试批量存储标签值
     * 
     * 测试批量存储多个标签值
     */
    void testStoreTagValues() {
        // 先初始化SQLite数据库
        HYTimeSeriesDatabase::DatabaseConfig config;
        config.type = HYTimeSeriesDatabase::SQLITE;
        config.host = "localhost";
        config.port = 0;
        config.database = ":memory:";
        config.username = "";
        config.password = "";
        config.tableName = "test_data";

        db->initialize(config);

        // 准备批量数据
        QMap<QString, QVariant> tagValues;
        tagValues["Tag1"] = 100.0;
        tagValues["Tag2"] = 200.0;
        tagValues["Tag3"] = 300.0;

        // 测试批量存储
        bool result = db->storeTagValues(tagValues, QDateTime::currentDateTime());
        QVERIFY(result);

        // 验证数据是否存储成功
        QMap<QDateTime, QVariant> tag1Data = db->queryTagHistory("Tag1", QDateTime::currentDateTime().addSecs(-60), QDateTime::currentDateTime().addSecs(60), 10);
        QMap<QDateTime, QVariant> tag2Data = db->queryTagHistory("Tag2", QDateTime::currentDateTime().addSecs(-60), QDateTime::currentDateTime().addSecs(60), 10);
        QMap<QDateTime, QVariant> tag3Data = db->queryTagHistory("Tag3", QDateTime::currentDateTime().addSecs(-60), QDateTime::currentDateTime().addSecs(60), 10);

        QVERIFY(tag1Data.size() > 0);
        QVERIFY(tag2Data.size() > 0);
        QVERIFY(tag3Data.size() > 0);
    }

    /**
     * @brief 测试批量查询标签历史数据
     * 
     * 测试批量查询多个标签的历史数据
     */
    void testQueryMultipleTagsHistory() {
        // 先初始化SQLite数据库并存储一些数据
        HYTimeSeriesDatabase::DatabaseConfig config;
        config.type = HYTimeSeriesDatabase::SQLITE;
        config.host = "localhost";
        config.port = 0;
        config.database = ":memory:";
        config.username = "";
        config.password = "";
        config.tableName = "test_data";

        db->initialize(config);

        // 存储一些测试数据
        QDateTime now = QDateTime::currentDateTime();
        for (int i = 0; i < 3; i++) {
            QDateTime timestamp = now.addSecs(i * 60);
            db->storeTagValue("TagA", 10.0 + i, timestamp);
            db->storeTagValue("TagB", 20.0 + i, timestamp);
            db->storeTagValue("TagC", 30.0 + i, timestamp);
        }

        // 准备标签列表
        QStringList tagNames;
        tagNames << "TagA" << "TagB" << "TagC";

        // 测试批量查询
        QMap<QString, QMap<QDateTime, QVariant>> result = db->queryMultipleTagsHistory(tagNames, now.addSecs(-60), now.addSecs(180), 10);
        QVERIFY(result.size() >= 3);
        QVERIFY(result.contains("TagA"));
        QVERIFY(result.contains("TagB"));
        QVERIFY(result.contains("TagC"));
        QVERIFY(result["TagA"].size() >= 3);
        QVERIFY(result["TagB"].size() >= 3);
        QVERIFY(result["TagC"].size() >= 3);
    }

    /**
     * @brief 测试创建数据库和表
     * 
     * 测试创建数据库和表的功能
     */
    void testCreateDatabaseAndTable() {
        // 先初始化SQLite数据库
        HYTimeSeriesDatabase::DatabaseConfig config;
        config.type = HYTimeSeriesDatabase::SQLITE;
        config.host = "localhost";
        config.port = 0;
        config.database = ":memory:";
        config.username = "";
        config.password = "";
        config.tableName = "test_data";

        db->initialize(config);

        // 测试创建数据库
        bool result = db->createDatabase();
        QVERIFY(result);

        // 测试创建表
        result = db->createTable();
        QVERIFY(result);
    }

    /**
     * @brief 测试清除数据
     * 
     * 测试清除指定标签或所有数据的功能
     */
    void testClearData() {
        // 先初始化SQLite数据库并存储一些数据
        HYTimeSeriesDatabase::DatabaseConfig config;
        config.type = HYTimeSeriesDatabase::SQLITE;
        config.host = "localhost";
        config.port = 0;
        config.database = ":memory:";
        config.username = "";
        config.password = "";
        config.tableName = "test_data";

        db->initialize(config);

        // 存储一些测试数据
        QDateTime now = QDateTime::currentDateTime();
        for (int i = 0; i < 3; i++) {
            db->storeTagValue("Clear_Test", 100.0 + i, now.addSecs(i * 60));
            db->storeTagValue("Keep_Test", 200.0 + i, now.addSecs(i * 60));
        }

        // 测试清除指定标签的数据
        bool result = db->clearData("Clear_Test");
        QVERIFY(result);

        // 验证数据是否清除
        QMap<QDateTime, QVariant> clearResult = db->queryTagHistory("Clear_Test", now.addSecs(-60), now.addSecs(180), 10);
        QMap<QDateTime, QVariant> keepResult = db->queryTagHistory("Keep_Test", now.addSecs(-60), now.addSecs(180), 10);

        QVERIFY(clearResult.isEmpty());
        QVERIFY(keepResult.size() >= 3);

        // 测试清除所有数据
        result = db->clearData();
        QVERIFY(result);

        // 验证所有数据是否清除
        clearResult = db->queryTagHistory("Clear_Test", now.addSecs(-60), now.addSecs(180), 10);
        keepResult = db->queryTagHistory("Keep_Test", now.addSecs(-60), now.addSecs(180), 10);

        QVERIFY(clearResult.isEmpty());
        QVERIFY(keepResult.isEmpty());
    }

    /**
     * @brief 测试关闭连接
     * 
     * 测试关闭数据库连接的功能
     */
    void testShutdown() {
        // 先初始化SQLite数据库
        HYTimeSeriesDatabase::DatabaseConfig config;
        config.type = HYTimeSeriesDatabase::SQLITE;
        config.host = "localhost";
        config.port = 0;
        config.database = ":memory:";
        config.username = "";
        config.password = "";
        config.tableName = "test_data";

        db->initialize(config);
        QVERIFY(db->isConnected());

        // 测试关闭连接
        db->shutdown();
        QVERIFY(!db->isConnected());
    }

    /**
     * @brief 测试连接状态检查
     * 
     * 测试检查数据库连接状态的功能
     */
    void testIsConnected() {
        // 测试初始状态
        QVERIFY(!db->isConnected());

        // 初始化数据库后测试
        HYTimeSeriesDatabase::DatabaseConfig config;
        config.type = HYTimeSeriesDatabase::SQLITE;
        config.host = "localhost";
        config.port = 0;
        config.database = ":memory:";
        config.username = "";
        config.password = "";
        config.tableName = "test_data";

        db->initialize(config);
        QVERIFY(db->isConnected());

        // 关闭连接后测试
        db->shutdown();
        QVERIFY(!db->isConnected());
    }

    /**
     * @brief 测试连接状态获取
     * 
     * 测试获取数据库连接状态的功能
     */
    void testConnectionStatus() {
        // 测试初始状态
        QString status = db->connectionStatus();
        QVERIFY(!status.isEmpty());

        // 初始化数据库后测试
        HYTimeSeriesDatabase::DatabaseConfig config;
        config.type = HYTimeSeriesDatabase::SQLITE;
        config.host = "localhost";
        config.port = 0;
        config.database = ":memory:";
        config.username = "";
        config.password = "";
        config.tableName = "test_data";

        db->initialize(config);
        status = db->connectionStatus();
        QVERIFY(!status.isEmpty());
    }

private:
    HYTimeSeriesDatabase *db; ///< 时间序列数据库实例
};

QTEST_MAIN(TestTimeSeriesDatabase)
#include "test_timeseriesdatabase.moc"
