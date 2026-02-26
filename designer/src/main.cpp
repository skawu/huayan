#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QDebug>

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
    app.setApplicationName("华颜SCADA设计器");
    app.setApplicationVersion("2.0.0");
    app.setOrganizationName("华颜科技");
    app.setWindowIcon(QIcon(":/icons/app_icon.png"));
    
    // 启用高DPI支持
    app.setAttribute(Qt::AA_EnableHighDpiScaling);
    
    // 输出版本信息
    qDebug() << "SCADA Designer Version:" << app.applicationVersion();
    qDebug() << "Qt Version:" << QT_VERSION_STR;
    
    // 创建标签管理器实例
    TagManager *tagManager = new TagManager(&app);
    
    QQmlApplicationEngine engine;
    
    // 将标签管理器暴露给QML
    engine.rootContext()->setContextProperty("tagManager", tagManager);
    
    // 加载主界面
    const QUrl url(QStringLiteral("qrc:/src/designer_main.qml"));
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