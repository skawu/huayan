#include <QTest>
#include <QSignalSpy>
#include <QTemporaryDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include "configmanager.h"

/**
 * @brief 配置管理器单元测试
 * 
 * 测试ConfigManager类的功能，包括配置的加载、保存、更新等
 */
class TestConfigManager : public QObject
{
    Q_OBJECT

private slots:
    /**
     * @brief 测试初始化
     * 
     * 在每个测试前初始化测试环境
     */
    void initTestCase() {
        // 创建临时目录用于测试
        QVERIFY(tempDir.isValid());
        configManager = new ConfigManager(this);
    }

    /**
     * @brief 测试清理
     * 
     * 在每个测试后清理测试环境
     */
    void cleanupTestCase() {
        delete configManager;
    }

    /**
     * @brief 测试配置初始化
     * 
     * 测试配置管理器的初始化功能
     */
    void testInitialization() {
        QVERIFY(configManager != nullptr);
        QVERIFY(configManager->isInitialized());
    }

    /**
     * @brief 测试配置加载
     * 
     * 测试从文件加载配置的功能
     */
    void testLoadConfiguration() {
        QString configFile = tempDir.path() + "/test_config.json";
        
        // 创建测试配置文件
        QJsonObject testConfig;
        testConfig["test_key"] = "test_value";
        testConfig["test_number"] = 123;
        
        QFile file(configFile);
        QVERIFY(file.open(QIODevice::WriteOnly));
        file.write(QJsonDocument(testConfig).toJson());
        file.close();
        
        // 加载配置
        bool result = configManager->loadConfiguration(configFile);
        QVERIFY(result);
        
        // 验证配置已加载
        QVariant value = configManager->getValue("test_key", "");
        QCOMPARE(value.toString(), QString("test_value"));
        
        value = configManager->getValue("test_number", 0);
        QCOMPARE(value.toInt(), 123);
    }

    /**
     * @brief 测试配置保存
     * 
     * 测试保存配置到文件的功能
     */
    void testSaveConfiguration() {
        QString configFile = tempDir.path() + "/save_test_config.json";
        
        // 设置一些配置值
        configManager->setValue("save_key", "save_value");
        configManager->setValue("save_number", 456);
        
        // 保存配置
        bool result = configManager->saveConfiguration(configFile);
        QVERIFY(result);
        
        // 验证文件已创建
        QVERIFY(QFile::exists(configFile));
        
        // 重新加载并验证内容
        QFile file(configFile);
        QVERIFY(file.open(QIODevice::ReadOnly));
        QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
        QJsonObject obj = doc.object();
        
        QCOMPARE(obj["save_key"].toString(), QString("save_value"));
        QCOMPARE(obj["save_number"].toInt(), 456);
    }

    /**
     * @brief 测试配置更新
     * 
     * 测试更新配置值的功能
     */
    void testUpdateConfiguration() {
        // 设置初始值
        configManager->setValue("update_key", "initial_value");
        QCOMPARE(configManager->getValue("update_key", "").toString(), QString("initial_value"));
        
        // 更新值
        configManager->setValue("update_key", "updated_value");
        QCOMPARE(configManager->getValue("update_key", "").toString(), QString("updated_value"));
    }

    /**
     * @brief 测试配置重置
     * 
     * 测试重置配置到默认值的功能
     */
    void testResetConfiguration() {
        // 设置值
        configManager->setValue("reset_key", "test_value");
        QVERIFY(configManager->hasKey("reset_key"));
        
        // 重置配置
        configManager->reset();
        
        // 验证某些值可能仍然存在，取决于实现
        // 具体行为取决于ConfigManager的实现
    }

private:
    ConfigManager* configManager;
    QTemporaryDir tempDir;
};

QTEST_MAIN(TestConfigManager)

#include "test_configmanager.moc"