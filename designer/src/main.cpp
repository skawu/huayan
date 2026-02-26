#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QDebug>
#include <QFile>
#include <QDateTime>

// 包含共享组件（使用相对路径）
#include "../shared/models/core/tagmanager.h"

/**
 * @file main.cpp
 * @brief Huayan SCADA 设计器应用程序入口
 * 
 * 实现了SCADA设计器的应用程序入口点，初始化QML环境
 * 注册自定义类型，设置上下文属性，启动设计器应用
 */

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    
    // 设置应用程序属性
    app.setApplicationName("SCADA Designer");
    app.setApplicationVersion("2.0.0");
    app.setOrganizationName("Huayan Tech");
    
    // 输出版本信息
    qDebug() << "SCADA Designer Version:" << app.applicationVersion();
    qDebug() << "Qt Version:" << QT_VERSION_STR;
    
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
    
    // 构建QML文件路径
    QString qmlFilePath = QDir::currentPath() + "/designer/main.qml";
    if (!QFile::exists(qmlFilePath)) {
        // 尝试相对路径
        qmlFilePath = "designer/main.qml";
    }
    
    const QUrl url = QUrl::fromLocalFile(qmlFilePath);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    
    qDebug() << "Loading QML file:" << url.toString();
    engine.load(url);
    
    if (engine.rootObjects().isEmpty()) {
        qWarning() << "Failed to load QML file:" << url.toString();
        return -1;
    }
    
    qDebug() << "SCADA Designer started successfully";
    return app.exec();
}