#include <QTest>
#include <QSignalSpy>
#include "tagmanager.h"

/**
 * @brief 标签管理器单元测试
 * 
 * 测试HYTag和HYTagManager类的功能，包括标签的添加、删除、查询和值更新等
 */
class TestTagManager : public QObject
{
    Q_OBJECT

private slots:
    /**
     * @brief 测试初始化
     * 
     * 在每个测试前初始化测试环境
     */
    void initTestCase() {
        tagManager = new HYTagManager(this);
    }

    /**
     * @brief 测试清理
     * 
     * 在每个测试后清理测试环境
     */
    void cleanupTestCase() {
        delete tagManager;
    }

    /**
     * @brief 测试添加标签
     * 
     * 测试添加单个标签和多个标签的功能
     */
    void testAddTag() {
        // 测试添加单个标签
        bool result = tagManager->addTag("Test_Tag", "Test_Group", 100, "Test tag description");
        QVERIFY(result);

        // 测试添加重复标签
        result = tagManager->addTag("Test_Tag", "Test_Group", 200, "Another description");
        QVERIFY(!result);

        // 测试添加多个标签到不同组
        result = tagManager->addTag("Tag1", "Group1", 10, "Tag 1");
        QVERIFY(result);

        result = tagManager->addTag("Tag2", "Group1", 20, "Tag 2");
        QVERIFY(result);

        result = tagManager->addTag("Tag3", "Group2", 30, "Tag 3");
        QVERIFY(result);
    }

    /**
     * @brief 测试移除标签
     * 
     * 测试移除存在和不存在的标签
     */
    void testRemoveTag() {
        // 先添加一个标签
        tagManager->addTag("Remove_Test", "Test_Group", 50);

        // 测试移除存在的标签
        bool result = tagManager->removeTag("Remove_Test");
        QVERIFY(result);

        // 测试移除不存在的标签
        result = tagManager->removeTag("Non_Existent_Tag");
        QVERIFY(!result);
    }

    /**
     * @brief 测试获取标签
     * 
     * 测试获取存在和不存在的标签
     */
    void testGetTag() {
        // 先添加一个标签
        tagManager->addTag("Get_Test", "Test_Group", 75);

        // 测试获取存在的标签
        HYTag *tag = tagManager->getTag("Get_Test");
        QVERIFY(tag != nullptr);
        QCOMPARE(tag->name(), QString("Get_Test"));
        QCOMPARE(tag->group(), QString("Test_Group"));
        QCOMPARE(tag->value(), QVariant(75));

        // 测试获取不存在的标签
        tag = tagManager->getTag("Non_Existent_Tag");
        QVERIFY(tag == nullptr);
    }

    /**
     * @brief 测试根据组获取标签
     * 
     * 测试获取指定组的所有标签
     */
    void testGetTagsByGroup() {
        // 先添加一些标签到不同组
        tagManager->addTag("Group_Tag1", "Test_Group", 10);
        tagManager->addTag("Group_Tag2", "Test_Group", 20);
        tagManager->addTag("Other_Tag", "Other_Group", 30);

        // 测试获取指定组的标签
        QVector<HYTag *> tags = tagManager->getTagsByGroup("Test_Group");
        QVERIFY(tags.size() >= 2);

        // 测试获取不存在组的标签
        tags = tagManager->getTagsByGroup("Non_Existent_Group");
        QVERIFY(tags.isEmpty());
    }

    /**
     * @brief 测试获取所有标签
     * 
     * 测试获取所有标签的功能
     */
    void testGetAllTags() {
        // 先添加一些标签
        tagManager->addTag("All_Tag1", "GroupA", 1);
        tagManager->addTag("All_Tag2", "GroupB", 2);

        // 测试获取所有标签
        QVector<HYTag *> tags = tagManager->getAllTags();
        QVERIFY(tags.size() >= 2);
    }

    /**
     * @brief 测试获取所有组
     * 
     * 测试获取所有标签组的功能
     */
    void testGetGroups() {
        // 先添加一些标签到不同组
        tagManager->addTag("Group_Test1", "GroupX", 100);
        tagManager->addTag("Group_Test2", "GroupY", 200);

        // 测试获取所有组
        QVector<QString> groups = tagManager->getGroups();
        QVERIFY(groups.contains("GroupX"));
        QVERIFY(groups.contains("GroupY"));
    }

    /**
     * @brief 测试设置标签值
     * 
     * 测试设置存在和不存在标签的值
     */
    void testSetTagValue() {
        // 先添加一个标签
        tagManager->addTag("Value_Test", "Test_Group", 50);

        // 测试设置存在标签的值
        bool result = tagManager->setTagValue("Value_Test", 150);
        QVERIFY(result);
        QCOMPARE(tagManager->getTagValue("Value_Test"), QVariant(150));

        // 测试设置不存在标签的值
        result = tagManager->setTagValue("Non_Existent_Tag", 100);
        QVERIFY(!result);
    }

    /**
     * @brief 测试获取标签值
     * 
     * 测试获取存在和不存在标签的值
     */
    void testGetTagValue() {
        // 先添加一个标签
        tagManager->addTag("Get_Value_Test", "Test_Group", 75);

        // 测试获取存在标签的值
        QVariant value = tagManager->getTagValue("Get_Value_Test");
        QCOMPARE(value, QVariant(75));

        // 测试获取不存在标签的值
        value = tagManager->getTagValue("Non_Existent_Tag");
        QVERIFY(value.isNull());
    }

    /**
     * @brief 测试标签值变化信号
     * 
     * 测试标签值变化时是否发出正确的信号
     */
    void testTagValueChangedSignal() {
        // 先添加一个标签
        tagManager->addTag("Signal_Test", "Test_Group", 100);

        // 创建信号间谍
        QSignalSpy spy(tagManager, SIGNAL(tagValueChanged(QString, QVariant)));

        // 更改标签值
        tagManager->setTagValue("Signal_Test", 200);

        // 检查信号是否发出
        QVERIFY(spy.wait());
        QCOMPARE(spy.count(), 1);

        // 检查信号参数
        QList<QVariant> arguments = spy.takeFirst();
        QCOMPARE(arguments.at(0).toString(), QString("Signal_Test"));
        QCOMPARE(arguments.at(1).toInt(), 200);
    }

    /**
     * @brief 测试标签添加信号
     * 
     * 测试添加标签时是否发出正确的信号
     */
    void testTagAddedSignal() {
        // 创建信号间谍
        QSignalSpy spy(tagManager, SIGNAL(tagAdded(QString)));

        // 添加标签
        tagManager->addTag("Added_Signal_Test", "Test_Group", 100);

        // 检查信号是否发出
        QVERIFY(spy.wait());
        QCOMPARE(spy.count(), 1);

        // 检查信号参数
        QList<QVariant> arguments = spy.takeFirst();
        QCOMPARE(arguments.at(0).toString(), QString("Added_Signal_Test"));
    }

    /**
     * @brief 测试标签移除信号
     * 
     * 测试移除标签时是否发出正确的信号
     */
    void testTagRemovedSignal() {
        // 先添加一个标签
        tagManager->addTag("Removed_Signal_Test", "Test_Group", 100);

        // 创建信号间谍
        QSignalSpy spy(tagManager, SIGNAL(tagRemoved(QString)));

        // 移除标签
        tagManager->removeTag("Removed_Signal_Test");

        // 检查信号是否发出
        QVERIFY(spy.wait());
        QCOMPARE(spy.count(), 1);

        // 检查信号参数
        QList<QVariant> arguments = spy.takeFirst();
        QCOMPARE(arguments.at(0).toString(), QString("Removed_Signal_Test"));
    }

private:
    HYTagManager *tagManager; ///< 标签管理器实例
};

QTEST_MAIN(TestTagManager)
#include "test_tagmanager.moc"
