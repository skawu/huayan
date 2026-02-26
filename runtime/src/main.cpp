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
    QGuiApplication app(argc, argv);
    
    // 设置应用程序属性
    app.setApplicationName("SCADA Runtime");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("Huayan Tech");
    
    // 创建QML引擎
    QQmlApplicationEngine engine;
    
    // 创建标签管理器实例
    TagManager *tagManager = new TagManager(&app);
    
    // 注册C++类型到QML
    qmlRegisterType<TagManager>("Huayan.SCADA", 1, 0, "TagManager");
    
    // 将标签管理器暴露给QML
    engine.rootContext()->setContextProperty("tagManager", tagManager);
    
    // 设置QML导入路径
    engine.addImportPath("qrc:/");
    engine.addImportPath(":/");
    
    // 添加当前目录到导入路径
    QDir currentDir(QDir::currentPath());
    engine.addImportPath(currentDir.absolutePath());

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

    if (engine.rootObjects().isEmpty()) {
        qWarning() << "Failed to load QML file:" << url.toString();
        return -1;
    }
    
    qDebug() << "SCADA Runtime started successfully";
    return app.exec();
}