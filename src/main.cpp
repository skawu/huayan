#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QQmlContext>
#include <QIcon>
#include <QDir>
#include <QStandardPaths>

#include "core/tagmanager.h"
#include "core/chartdatamodel.h"
#include "datasource/opcuadatasource.h"
#include "datasource/mqttdatasource.h"
#include "datasource/modbusdatasource.h"

/**
 * @file main.cpp
 * @brief Huayan工业软件应用程序入口
 * 
 * 实现了Huayan工业软件的应用程序入口点，初始化C++后端与QML前端
 * 注册QML类型，设置上下文属性，启动应用程序
 */

int main(int argc, char *argv[])
{
    // 设置Qt应用程序属性
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setApplicationName("Huayan工业软件");
    QCoreApplication::setApplicationVersion("1.0.0");
    QCoreApplication::setOrganizationName("Huayan Software");
    QCoreApplication::setOrganizationDomain("huayan.com");

    // 创建应用程序实例
    QApplication app(argc, argv);

    // 设置应用程序图标
    app.setWindowIcon(QIcon());

    // 初始化Huayan点位管理系统
    HYTagManager *tagManager = new HYTagManager(&app);

    // 初始化图表数据模型
    ChartDataModel *chartDataModel = new ChartDataModel(tagManager, &app);

    // 初始化数据源
    OpcUaDataSource *opcUaDataSource = new OpcUaDataSource(tagManager, &app);
    MqttDataSource *mqttDataSource = new MqttDataSource(tagManager, &app);
    ModbusDataSource *modbusDataSource = new ModbusDataSource(tagManager, &app);

    // 创建QML应用程序引擎
    QQmlApplicationEngine engine;

    // 注册QML类型
    qmlRegisterType<HYTagManager>("Huayan.Core", 1, 0, "HYTagManager");
    qmlRegisterType<ChartDataModel>("Huayan.Core", 1, 0, "ChartDataModel");
    qmlRegisterType<OpcUaDataSource>("Huayan.DataSource", 1, 0, "OpcUaDataSource");
    qmlRegisterType<MqttDataSource>("Huayan.DataSource", 1, 0, "MqttDataSource");
    qmlRegisterType<ModbusDataSource>("Huayan.DataSource", 1, 0, "ModbusDataSource");

    // 设置QML上下文属性
    QQmlContext *context = engine.rootContext();
    context->setContextProperty("tagManager", tagManager);
    context->setContextProperty("chartDataModel", chartDataModel);
    context->setContextProperty("opcUaDataSource", opcUaDataSource);
    context->setContextProperty("mqttDataSource", mqttDataSource);
    context->setContextProperty("modbusDataSource", modbusDataSource);

    // 设置QML导入路径
    engine.addImportPath(QDir::currentPath() + "/qml");

    // 加载QML主文件
    const QUrl url(QStringLiteral("qml/main.qml"));
    engine.load(url);

    // 检查QML加载是否成功
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    // 获取主窗口
    QQuickWindow *window = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
    if (window) {
        // 设置窗口最小大小
        window->setMinimumSize(QSize(1024, 768));
        
        // 连接信号槽
        QObject::connect(&engine, &QQmlApplicationEngine::quit, &app, &QCoreApplication::quit);
    }

    // 运行应用程序
    int result = app.exec();

    // 清理资源
    delete opcUaDataSource;
    delete mqttDataSource;
    delete modbusDataSource;
    delete chartDataModel;
    delete tagManager;

    return result;
}
