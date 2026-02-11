#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include <QStandardPaths>

// 包含示例的头文件
#include "hysteelplantmanager.h"
#include "hysimulateddatasource.h"

// 包含Huayan核心头文件
#include "core/hy_tagmanager.h"
#include "core/hy_dataprocessor.h"
#include "core/hy_chartdatamodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // 设置应用程序信息
    app.setApplicationName("HYSteelPlantMonitoring");
    app.setApplicationVersion("1.0");
    app.setOrganizationName("Huayan");

    // 创建QML引擎
    QQmlApplicationEngine engine;

    // 设置QML导入路径
    QString qmlImportPath = QDir::currentPath() + "/../qml";
    engine.addImportPath(qmlImportPath);

    // 注册C++类型到QML
    qmlRegisterType<HYSteelPlantManager>("SteelPlantMonitoring", 1, 0, "HYSteelPlantManager");
    qmlRegisterType<HYSimulatedDataSource>("SteelPlantMonitoring", 1, 0, "HYSimulatedDataSource");
    
    // 注册Huayan核心类型到QML（如果需要）
    qmlRegisterType<HYTagManager>("Huayan.Core", 1, 0, "HYTagManager");
    qmlRegisterType<HYDataProcessor>("Huayan.Core", 1, 0, "HYDataProcessor");
    qmlRegisterType<HYChartDataModel>("Huayan.Core", 1, 0, "HYChartDataModel");

    // 加载主QML文件
    const QUrl url(u"qrc:/steel_plant_monitoring.qml");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
