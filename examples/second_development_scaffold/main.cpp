#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include <QStandardPaths>

// 包含示例的头文件
#include "scaffoldmanager.h"
#include "apidemo.h"

// 包含Huayan核心头文件
#include "core/tagmanager.h"
#include "core/dataprocessor.h"
#include "core/chartdatamodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // 设置应用程序信息
    app.setApplicationName("SecondDevelopmentScaffold");
    app.setApplicationVersion("1.0");
    app.setOrganizationName("Huayan");

    // 创建QML引擎
    QQmlApplicationEngine engine;

    // 设置QML导入路径
    QString qmlImportPath = QDir::currentPath() + "/../qml";
    engine.addImportPath(qmlImportPath);

    // 注册C++类型到QML
    qmlRegisterType<ScaffoldManager>("SecondDevelopmentScaffold", 1, 0, "ScaffoldManager");
    qmlRegisterType<ApiDemo>("SecondDevelopmentScaffold", 1, 0, "ApiDemo");
    
    // 注册Huayan核心类型到QML（如果需要）
    qmlRegisterType<TagManager>("Huayan.Core", 1, 0, "TagManager");
    qmlRegisterType<DataProcessor>("Huayan.Core", 1, 0, "DataProcessor");
    qmlRegisterType<ChartDataModel>("Huayan.Core", 1, 0, "ChartDataModel");

    // 加载主QML文件
    const QUrl url(u"qrc:/scaffold.qml");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
