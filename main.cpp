#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "src/3d/modelloader.h"
#include "src/3d/3dpointbinder.h"
#include "src/3d/modeloptimizer.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // 注册QML类型
    qmlRegisterType<ModelLoader>("Huayan3D", 1, 0, "ModelLoader");
    qmlRegisterType<DPointBinder>("Huayan3D", 1, 0, "DPointBinder");
    qmlRegisterType<ModelOptimizer>("Huayan3D", 1, 0, "ModelOptimizer");

    QQmlApplicationEngine engine;
    
    // 设置根上下文属性
    engine.rootContext()->setContextProperty("applicationDirPath", app.applicationDirPath());

    // 加载主QML文件
    const QUrl url(u"qrc:/qml/main.qml");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            QCoreApplication::exit(-1);
        }
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
