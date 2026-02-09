#include <QTest>
#include <QSignalSpy>
#include <QTimer>
#include "dataprocessor.h"
#include "tagmanager.h"
#include "timeseriesdatabase.h"
#include "hymodbustcpdriver.h"

// 模拟Modbus TCP驱动类
class MockModbusTcpDriver : public HYModbusTcpDriver
{
    Q_OBJECT

public:
    MockModbusTcpDriver(QObject *parent = nullptr) : HYModbusTcpDriver(parent), m_connected(false) {}

    // 模拟连接设备
    bool connectToDevice(const QString &ipAddress, int port, int slaveId) override {
        Q_UNUSED(ipAddress);
        Q_UNUSED(port);
        Q_UNUSED(slaveId);
        m_connected = true;
        emit connected();
        return true;
    }

    // 模拟断开连接
    void disconnectFromDevice() override {
        m_connected = false;
        emit disconnected();
    }

    // 模拟检查连接状态
    bool isConnected() const override {
        return m_connected;
    }

    // 模拟读取保持寄存器
    bool readHoldingRegister(int address, quint16 &value) override {
        if (registers.contains(address)) {
            value = registers[address];
            return true;
        }
        value = 0;
        return false;
    }

    // 模拟写入保持寄存器
    bool writeHoldingRegister(int address, quint16 value) override {
        registers[address] = value;
        return true;
    }

    // 模拟读取输入寄存器
    bool readInputRegister(int address, quint16 &value) override {
        if (inputRegisters.contains(address)) {
            value = inputRegisters[address];
            return true;
        }
        value = 0;
        return false;
    }

    // 存储寄存器值
    QMap<int, quint16> registers;
    QMap<int, quint16> inputRegisters;
    bool m_connected = false;
};

/**
 * @brief 系统集成测试
 * 
 * 测试多个组件之间的交互，包括数据处理器、标签管理器和时间序列数据库
 */
class TestSystemIntegration : public QObject
{
    Q_OBJECT

private slots:
    /**
     * @brief 测试初始化
     * 
     * 在每个测试前初始化测试环境
     */
    void initTestCase() {
        // 初始化组件
        tagManager = new HYTagManager(this);
        modbusDriver = new MockModbusTcpDriver(this);
        timeSeriesDb = new HYTimeSeriesDatabase(this);
        dataProcessor = new HYDataProcessor(this);

        // 初始化时间序列数据库
        HYTimeSeriesDatabase::DatabaseConfig dbConfig;
        dbConfig.type = HYTimeSeriesDatabase::SQLITE;
        dbConfig.host = "localhost";
        dbConfig.port = 0;
        dbConfig.database = ":memory:";
        dbConfig.username = "";
        dbConfig.password = "";
        dbConfig.tableName = "test_data";
        timeSeriesDb->initialize(dbConfig);

        // 初始化数据处理器
        dataProcessor->initialize(modbusDriver, tagManager);
    }

    /**
     * @brief 测试清理
     * 
     * 在每个测试后清理测试环境
     */
    void cleanupTestCase() {
        if (timeSeriesDb->isConnected()) {
            timeSeriesDb->shutdown();
        }
        delete dataProcessor;
        delete timeSeriesDb;
        delete modbusDriver;
        delete tagManager;
    }

    /**
     * @brief 测试标签管理和数据处理集成
     * 
     * 测试标签的添加、数据采集和处理
     */
    void testTagManagementAndDataProcessing() {
        // 添加标签
        bool result = tagManager->addTag("Test_Tag", "Test_Group", 0);
        QVERIFY(result);

        // 映射标签到设备寄存器
        result = dataProcessor->mapTagToDeviceRegister("Test_Tag", 100);
        QVERIFY(result);

        // 设置模拟寄存器值
        modbusDriver->registers[100] = 123;

        // 启动数据采集
        dataProcessor->startDataCollection(500);

        // 等待一段时间让数据采集执行
        QTimer::singleShot(1000, this, [this]() {
            // 检查标签值是否更新
            QVariant value = tagManager->getTagValue("Test_Tag");
            QVERIFY(value.isValid());
            QCOMPARE(value.toInt(), 123);

            // 停止数据采集
            dataProcessor->stopDataCollection();
        });

        // 等待测试完成
        QEventLoop loop;
        QTimer::singleShot(2000, &loop, &QEventLoop::quit);
        loop.exec();
    }

    /**
     * @brief 测试命令发送功能
     * 
     * 测试从标签发送命令到设备
     */
    void testCommandSending() {
        // 添加标签
        tagManager->addTag("Command_Tag", "Command_Group", 0);

        // 映射标签到设备寄存器
        dataProcessor->mapTagToDeviceRegister("Command_Tag", 200);

        // 发送命令
        bool result = dataProcessor->sendCommand("Command_Tag", 255);
        QVERIFY(result);

        // 检查寄存器值是否更新
        QVERIFY(modbusDriver->registers.contains(200));
        QCOMPARE(modbusDriver->registers[200], static_cast<quint16>(255));
    }

    /**
     * @brief 测试数据采集和存储集成
     * 
     * 测试数据采集后是否正确存储到时间序列数据库
     */
    void testDataCollectionAndStorage() {
        // 添加标签
        tagManager->addTag("Storage_Tag", "Storage_Group", 0);

        // 映射标签到设备寄存器
        dataProcessor->mapTagToDeviceRegister("Storage_Tag", 300);

        // 设置模拟寄存器值
        modbusDriver->registers[300] = 456;

        // 启动数据采集
        dataProcessor->startDataCollection(200);

        // 等待一段时间让数据采集和存储执行
        QTimer::singleShot(1000, this, [this]() {
            // 停止数据采集
            dataProcessor->stopDataCollection();

            // 从数据库查询数据
            QDateTime now = QDateTime::currentDateTime();
            QMap<QDateTime, QVariant> result = timeSeriesDb->queryTagHistory("Storage_Tag", now.addSecs(-10), now.addSecs(10), 10);
            QVERIFY(result.size() > 0);
        });

        // 等待测试完成
        QEventLoop loop;
        QTimer::singleShot(2000, &loop, &QEventLoop::quit);
        loop.exec();
    }

    /**
     * @brief 测试标签映射管理
     * 
     * 测试标签的映射和解除映射功能
     */
    void testTagMappingManagement() {
        // 添加标签
        tagManager->addTag("Mapping_Tag", "Mapping_Group", 0);

        // 测试映射标签
        bool result = dataProcessor->mapTagToDeviceRegister("Mapping_Tag", 400);
        QVERIFY(result);

        // 测试解除映射
        result = dataProcessor->unmapTagFromDeviceRegister("Mapping_Tag");
        QVERIFY(result);

        // 测试映射不存在的标签
        result = dataProcessor->mapTagToDeviceRegister("Non_Existent_Tag", 500);
        QVERIFY(!result);

        // 测试解除不存在标签的映射
        result = dataProcessor->unmapTagFromDeviceRegister("Non_Existent_Tag");
        QVERIFY(!result);
    }

    /**
     * @brief 测试数据处理器信号
     * 
     * 测试数据处理器发出的各种信号
     */
    void testDataProcessorSignals() {
        // 创建信号间谍
        QSignalSpy startSpy(dataProcessor, SIGNAL(dataCollectionStarted()));
        QSignalSpy stopSpy(dataProcessor, SIGNAL(dataCollectionStopped()));
        QSignalSpy commandSpy(dataProcessor, SIGNAL(commandSent(QString, QVariant, bool)));

        // 测试数据采集开始信号
        dataProcessor->startDataCollection(100);
        QVERIFY(startSpy.wait());
        QCOMPARE(startSpy.count(), 1);

        // 测试数据采集停止信号
        dataProcessor->stopDataCollection();
        QVERIFY(stopSpy.wait());
        QCOMPARE(stopSpy.count(), 1);

        // 添加标签并映射
        tagManager->addTag("Signal_Tag", "Signal_Group", 0);
        dataProcessor->mapTagToDeviceRegister("Signal_Tag", 600);

        // 测试命令发送信号
        dataProcessor->sendCommand("Signal_Tag", 789);
        QVERIFY(commandSpy.wait());
        QCOMPARE(commandSpy.count(), 1);

        // 检查命令发送信号参数
        QList<QVariant> arguments = commandSpy.takeFirst();
        QCOMPARE(arguments.at(0).toString(), QString("Signal_Tag"));
        QCOMPARE(arguments.at(1).toInt(), 789);
        QCOMPARE(arguments.at(2).toBool(), true);
    }

private:
    HYDataProcessor *dataProcessor; ///< 数据处理器实例
    HYTagManager *tagManager; ///< 标签管理器实例
    MockModbusTcpDriver *modbusDriver; ///< 模拟Modbus TCP驱动
    HYTimeSeriesDatabase *timeSeriesDb; ///< 时间序列数据库实例
};

QTEST_MAIN(TestSystemIntegration)
#include "test_systemintegration.moc"
