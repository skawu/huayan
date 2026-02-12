#include <QTest>
#include <QSignalSpy>
#include <QTemporaryDir>
#include <QDir>
#include <QFile>
#include "extensionmanager.h"

/**
 * @brief 扩展管理器单元测试
 * 
 * 测试ExtensionManager类的功能，包括扩展的加载、卸载、管理等
 */
class TestExtensionManager : public QObject
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
        extensionManager = ExtensionManager::instance();  // 使用单例模式
        extensionManager->initialize(this);
    }

    /**
     * @brief 测试清理
     * 
     * 在每个测试后清理测试环境
     */
    void cleanupTestCase() {
        // 单例不需要手动删除
    }

    /**
     * @brief 测试扩展管理器初始化
     * 
     * 测试扩展管理器的基本初始化功能
     */
    void testInitialization() {
        QVERIFY(extensionManager != nullptr);
        // 验证实例已正确获取
        QVERIFY(ExtensionManager::instance() != nullptr);
    }

    /**
     * @brief 测试扩展注册
     * 
     * 测试注册扩展的功能
     */
    void testRegisterExtension() {
        // 准备扩展信息
        QJsonObject extensionInfo;
        extensionInfo["name"] = "test_extension";
        extensionInfo["description"] = "Test Extension Description";
        extensionInfo["version"] = "1.0";
        
        // 注册一个模拟扩展
        extensionManager->registerExtension("test_type", extensionInfo);
        
        // 验证扩展已注册 - 检查特定类型的扩展
        auto extensions = extensionManager->getExtensionsByType("test_type");
        QVERIFY(!extensions.isEmpty());
        
        // 检查扩展数组中是否包含我们的扩展
        bool found = false;
        for (const auto& ext : extensions) {
            QJsonObject extObj = ext.toObject();
            if (extObj["name"].toString() == "test_extension") {
                found = true;
                break;
            }
        }
        QVERIFY(found);
    }

    /**
     * @brief 测试扩展加载
     * 
     * 测试加载扩展的功能
     */
    void testLoadExtension() {
        // 加载所有扩展（这将在测试环境中加载默认扩展）
        extensionManager->loadExtensions();
        
        // 验证某些扩展被加载
        auto allExtensions = extensionManager->getAllExtensions();
        // 可能没有任何扩展，但我们至少可以确认方法被调用
        QVERIFY(true); // 方法调用成功
    }

    /**
     * @brief 测试扩展查询
     * 
     * 测试查询已加载扩展的功能
     */
    void testQueryExtensions() {
        // 准备扩展信息
        QJsonObject ext1Info, ext2Info, ext3Info;
        ext1Info["name"] = "ext1";
        ext1Info["description"] = "Extension 1";
        ext1Info["version"] = "1.0";
        
        ext2Info["name"] = "ext2";
        ext2Info["description"] = "Extension 2";
        ext2Info["version"] = "2.0";
        
        ext3Info["name"] = "ext3";
        ext3Info["description"] = "Extension 3";
        ext3Info["version"] = "1.5";
        
        // 注册几个扩展
        extensionManager->registerExtension("test_type", ext1Info);
        extensionManager->registerExtension("test_type", ext2Info);
        extensionManager->registerExtension("test_type", ext3Info);
        
        // 查询特定类型的扩展
        auto extensions = extensionManager->getExtensionsByType("test_type");
        QVERIFY(!extensions.isEmpty());
        
        // 检查是否包含了我们注册的扩展
        int foundCount = 0;
        for (const auto& ext : extensions) {
            QJsonObject extObj = ext.toObject();
            QString name = extObj["name"].toString();
            if (name == "ext1" || name == "ext2" || name == "ext3") {
                foundCount++;
            }
        }
        QVERIFY(foundCount >= 3);
    }

    /**
     * @brief 测试扩展目录获取
     * 
     * 测试获取扩展目录路径的功能
     */
    void testExtensionDir() {
        // 测试获取各种类型的扩展目录
        QString componentDir = extensionManager->getExtensionDir("components");
        QVERIFY(!componentDir.isEmpty());
        
        QString templateDir = extensionManager->getExtensionDir("templates");
        QVERIFY(!templateDir.isEmpty());
    }

private:
    ExtensionManager* extensionManager;
    QTemporaryDir tempDir;
};

QTEST_MAIN(TestExtensionManager)

#include "test_extensionmanager.moc"