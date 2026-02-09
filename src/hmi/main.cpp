#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "layoutmanager.h"
#include "hmicommunicationmanager.h"
#include "touchmanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // 注册QML类型
    qmlRegisterType<LayoutManager>("Huayan.HMI", 1, 0, "LayoutManager");
    qmlRegisterType<HMICommunicationManager>("Huayan.HMI", 1, 0, "HMICommunicationManager");
    qmlRegisterType<TouchManager>("Huayan.HMI", 1, 0, "TouchManager");

    QQmlApplicationEngine engine;
    
    // 设置根上下文属性
    engine.rootContext()->setContextProperty("applicationDirPath", app.applicationDirPath());

    // 加载HMI演示文件
    const QUrl url(u"qrc:/qml/hmi/HMIDemo.qml");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            QCoreApplication::exit(-1);
        }
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
