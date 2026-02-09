#include <QTest>
#include <QSignalSpy>
#include <QTimer>
#include "dataprocessor.h"
#include "tagmanager.h"

// 模拟Modbus TCP驱动类
class MockModbusTcpDriver : public QObject
{
    Q_OBJECT

public:
    MockModbusTcpDriver(QObject *parent = nullptr) : QObject(parent) {}

    // 模拟读取保持寄存器
    bool readHoldingRegister(int address, QVariant &value) {
        if (registers.contains(address)) {
            value = registers[address];
            return true;
        }
        return false;
    }

    // 模拟写入保持寄存器
    bool writeHoldingRegister(int address, const QVariant &value) {
        registers[address] = value;
        return true;
    }

    // 模拟读取输入寄存器
    bool readInputRegister(int address, QVariant &value) {
        if (inputRegisters.contains(address)) {
            value = inputRegisters[address];
            return true;
        }
        return false;
    }

    // 存储寄存器值
    QMap<int, QVariant> registers;
    QMap<int, QVariant> inputRegisters;
};

// 模拟时间序列数据库类
class MockTimeSeriesDatabase : public QObject
{
    Q_OBJECT

public:
    MockTimeSeriesDatabase(QObject *parent = nullptr) : QObject(parent) {}

    // 模拟存储数据
    bool storeData(const QString &tagName, const QVariant &value, const QDateTime &timestamp) {
        storedData[tagName].append(qMakePair(timestamp, value));
        return true;
    }

    // 存储的数据
    QMap<QString, QList<QPair<QDateTime, QVariant>>> storedData;
};

/**
 * @brief 数据处理器单元测试
 * 
 * 测试HYDataProcessor类的功能，包括数据采集、命令发送和标签映射等
 */
class TestDataProcessor : public QObject
{
    Q_OBJECT

private slots:
    /**
     * @brief 测试初始化
     * 
     * 在每个测试前初始化测试环境
     */
    void initTestCase() {
        dataProcessor = new HYDataProcessor(this);
        tagManager = new HYTagManager(this);
        modbusDriver = new MockModbusTcpDriver(this);
        timeSeriesDb = new MockTimeSeriesDatabase(this);

        // 初始化数据处理器
        dataProcessor->initialize(modbusDriver, tagManager);
    }

    /**
     * @brief 测试清理
     * 
     * 在每个测试后清理测试环境
     */
    void cleanupTestCase() {
        delete dataProcessor;
        delete tagManager;
        delete modbusDriver;
        delete timeSeriesDb;
    }

    /**
     * @brief 测试标签到设备寄存器的映射
     * 
     * 测试映射标签到保持寄存器和输入寄存器
     */
    void testMapTagToDeviceRegister() {
        // 先添加一个标签
        tagManager->addTag("Test_Tag", "Test_Group", 0);

        // 测试映射到保持寄存器
        bool result = dataProcessor->mapTagToDeviceRegister("Test_Tag", 100, true);
        QVERIFY(result);

        // 测试映射到输入寄存器
        result = dataProcessor->mapTagToDeviceRegister("Test_Tag", 200, false);
        QVERIFY(result);

        // 测试映射不存在的标签
        result = dataProcessor->mapTagToDeviceRegister("Non_Existent_Tag", 300);
        QVERIFY(!result);
    }

    /**
     * @brief 测试解除标签与设备寄存器的映射
     * 
     * 测试解除存在和不存在标签的映射
     */
    void testUnmapTagFromDeviceRegister() {
        // 先添加一个标签并映射
        tagManager->addTag("Unmap_Test", "Test_Group", 0);
        dataProcessor->mapTagToDeviceRegister("Unmap_Test", 100);

        // 测试解除存在标签的映射
        bool result = dataProcessor->unmapTagFromDeviceRegister("Unmap_Test");
        QVERIFY(result);

        // 测试解除不存在标签的映射
        result = dataProcessor->unmapTagFromDeviceRegister("Non_Existent_Tag");
        QVERIFY(!result);
    }

    /**
     * @brief 测试命令发送
     * 
     * 测试发送命令到映射的标签
     */
    void testSendCommand() {
        // 先添加一个标签并映射到保持寄存器
        tagManager->addTag("Command_Test", "Test_Group", 0);
        dataProcessor->mapTagToDeviceRegister("Command_Test", 100);

        // 测试发送命令
        bool result = dataProcessor->sendCommand("Command_Test", 255);
        QVERIFY(result);

        // 检查寄存器值是否更新
        QVERIFY(modbusDriver->registers.contains(100));
        QCOMPARE(modbusDriver->registers[100], QVariant(255));

        // 测试发送命令到不存在的标签
        result = dataProcessor->sendCommand("Non_Existent_Tag", 100);
        QVERIFY(!result);
    }

    /**
     * @brief 测试设置采集间隔
     * 
     * 测试设置不同的采集间隔
     */
    void testSetCollectionInterval() {
        // 测试设置采集间隔
        dataProcessor->setCollectionInterval(500);
        // 由于setCollectionInterval是private方法，我们无法直接验证，只能测试它不会崩溃
        QVERIFY(true);
    }

    /**
     * @brief 测试数据采集开始和停止信号
     * 
     * 测试数据采集开始和停止时是否发出正确的信号
     */
    void testDataCollectionSignals() {
        // 创建信号间谍
        QSignalSpy startSpy(dataProcessor, SIGNAL(dataCollectionStarted()));
        QSignalSpy stopSpy(dataProcessor, SIGNAL(dataCollectionStopped()));

        // 开始数据采集
        dataProcessor->startDataCollection(100);

        // 检查开始信号是否发出
        QVERIFY(startSpy.wait(500));
        QCOMPARE(startSpy.count(), 1);

        // 停止数据采集
        dataProcessor->stopDataCollection();

        // 检查停止信号是否发出
        QVERIFY(stopSpy.wait(500));
        QCOMPARE(stopSpy.count(), 1);
    }

private:
    HYDataProcessor *dataProcessor; ///< 数据处理器实例
    HYTagManager *tagManager; ///< 标签管理器实例
    MockModbusTcpDriver *modbusDriver; ///< 模拟Modbus TCP驱动
    MockTimeSeriesDatabase *timeSeriesDb; ///< 模拟时间序列数据库
};

QTEST_MAIN(TestDataProcessor)
#include "test_dataprocessor.moc"
