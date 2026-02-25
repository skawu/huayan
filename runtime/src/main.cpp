#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QDir>
#include <QDebug>
#include <QDateTime>

// 包含共享组件（使用相对路径）
#include "../shared/models/core/tagmanager.h"

/**
 * @file main.cpp
 * @brief Huayan SCADA 运行时应用程序入口
 * 
 * 实现了SCADA运行时的应用程序入口点，初始化监控环境
 * 注册监控相关类型，设置数据绑定，启动运行时应用
 */

int main(int argc, char *argv[])
{
    // 设置Qt应用程序属性
    QCoreApplication::setApplicationName("SCADARuntime");
    QCoreApplication::setApplicationVersion("2.0.0");
    QCoreApplication::setOrganizationName("Huayan Industrial Automation");

    // 创建QML应用程序实例
    QGuiApplication app(argc, argv);

    // 输出版本信息
    qDebug() << "SCADA Runtime Version:" << QCoreApplication::applicationVersion();
    qDebug() << "Qt Version:" << QT_VERSION_STR;

    // 设置应用程序图标
    app.setWindowIcon(QIcon(":/icons/runtime.png"));

    // 创建QML引擎
    QQmlApplicationEngine engine;

    // 注册自定义类型
    qmlRegisterType<TagManager>("Huayan.Models", 1, 0, "TagManager");

    // 创建核心管理器实例
    TagManager *tagManager = new TagManager(&app);

    // 初始化一些示例标签用于演示
    tagManager->addTag("temperature", 25.0, "当前温度");
    tagManager->addTag("pressure", 10.5, "系统压力");
    tagManager->addTag("motor_status", false, "电机状态");
    tagManager->addTag("valve_position", 0.0, "阀门位置");

    // 设置QML上下文属性
    QQmlContext *context = engine.rootContext();
    context->setContextProperty("tagManager", tagManager);
    context->setContextProperty("applicationVersion", QCoreApplication::applicationVersion());

    // 设置QML导入路径
    QString qmlPath = QCoreApplication::applicationDirPath() + "/qml";
    if (QDir(qmlPath).exists()) {
        engine.addImportPath(qmlPath);
    }
    engine.addImportPath("qrc:/");

    // 连接引擎错误信号
    QObject::connect(&engine, &QQmlApplicationEngine::warnings, [](const QList<QQmlError> &warnings) {
        for (const QQmlError &warning : warnings) {
            qWarning() << "QML Warning:" << warning.toString();
        }
    });

    // 加载主QML文件
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    
    engine.load(url);

    // 检查QML加载是否成功
    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Failed to load QML file";
        return -1;
    }

    qDebug() << "Runtime started successfully";

    // 运行应用程序
    int result = app.exec();

    // 清理资源
    delete tagManager;

    return result;
}