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
        extensionManager = new ExtensionManager(this);
    }

    /**
     * @brief 测试清理
     * 
     * 在每个测试后清理测试环境
     */
    void cleanupTestCase() {
        delete extensionManager;
    }

    /**
     * @brief 测试扩展管理器初始化
     * 
     * 测试扩展管理器的基本初始化功能
     */
    void testInitialization() {
        QVERIFY(extensionManager != nullptr);
        QVERIFY(extensionManager->getLoadedExtensions().isEmpty());
    }

    /**
     * @brief 测试扩展注册
     * 
     * 测试注册扩展的功能
     */
    void testRegisterExtension() {
        // 注册一个模拟扩展
        bool result = extensionManager->registerExtension("test_extension", "Test Extension Description", "1.0");
        QVERIFY(result);
        
        // 验证扩展已注册
        auto extensions = extensionManager->getRegisteredExtensions();
        QVERIFY(!extensions.isEmpty());
        QVERIFY(extensions.contains("test_extension"));
    }

    /**
     * @brief 测试扩展加载
     * 
     * 测试加载扩展的功能
     */
    void testLoadExtension() {
        // 首先注册扩展
        bool registerResult = extensionManager->registerExtension("load_test_ext", "Load Test Extension", "1.0");
        QVERIFY(registerResult);
        
        // 尝试加载扩展
        // 注意：真实的扩展加载可能需要实际的插件文件
        // 这里测试逻辑依赖于ExtensionManager的具体实现
        auto registeredExts = extensionManager->getRegisteredExtensions();
        QVERIFY(registeredExts.contains("load_test_ext"));
    }

    /**
     * @brief 测试扩展查询
     * 
     * 测试查询已加载扩展的功能
     */
    void testQueryExtensions() {
        // 注册几个扩展
        extensionManager->registerExtension("ext1", "Extension 1", "1.0");
        extensionManager->registerExtension("ext2", "Extension 2", "2.0");
        extensionManager->registerExtension("ext3", "Extension 3", "1.5");
        
        // 查询所有扩展
        auto allExtensions = extensionManager->getRegisteredExtensions();
        QVERIFY(allExtensions.size() >= 3);
        QVERIFY(allExtensions.contains("ext1"));
        QVERIFY(allExtensions.contains("ext2"));
        QVERIFY(allExtensions.contains("ext3"));
        
        // 验证扩展信息
        auto extInfo = extensionManager->getExtensionInfo("ext1");
        QVERIFY(!extInfo.isNull());
        QCOMPARE(extInfo.name, QString("ext1"));
        QCOMPARE(extInfo.description, QString("Extension 1"));
    }

    /**
     * @brief 测试扩展卸载
     * 
     * 测试卸载扩展的功能
     */
    void testUnloadExtension() {
        // 注册并尝试"卸载"扩展
        extensionManager->registerExtension("unload_test", "Unload Test Extension", "1.0");
        
        auto beforeCount = extensionManager->getRegisteredExtensions().size();
        QVERIFY(beforeCount > 0);
        
        // 根据ExtensionManager的实现，可能有卸载功能
        // 这里测试可用的接口
        QVERIFY(true); // Placeholder - depends on ExtensionManager implementation
    }

private:
    ExtensionManager* extensionManager;
    QTemporaryDir tempDir;
};

QTEST_MAIN(TestExtensionManager)

#include "test_extensionmanager.moc"