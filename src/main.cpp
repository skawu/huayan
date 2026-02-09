#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QQmlContext>
#include <QIcon>
#include <QDir>
#include <QStandardPaths>

#include "core/tagmanager.h"
#include "core/chartdatamodel.h"

// Conditionally include Mqtt headers if available
#ifdef HAVE_MQTT
#include "datasource/mqttdatasource.h"
#endif

#include "datasource/modbusdatasource.h"

// Conditionally include OpcUa headers if available
#ifdef HAVE_OPCUA
#include "datasource/opcuadatasource.h"
#endif

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

    // 创建QML应用程序引擎
    QQmlApplicationEngine engine;

    // 注册QML类型
    qmlRegisterType<HYTagManager>("Huayan.Core", 1, 0, "HYTagManager");
    qmlRegisterType<ChartDataModel>("Huayan.Core", 1, 0, "ChartDataModel");
    qmlRegisterType<ModbusDataSource>("Huayan.DataSource", 1, 0, "ModbusDataSource");

    // 初始化数据源
    ModbusDataSource *modbusDataSource = new ModbusDataSource(tagManager, &app);

    // 设置QML上下文属性
    QQmlContext *context = engine.rootContext();
    context->setContextProperty("tagManager", tagManager);
    context->setContextProperty("chartDataModel", chartDataModel);
    context->setContextProperty("modbusDataSource", modbusDataSource);

    // Conditionally initialize and set up OpcUaDataSource if available
    #ifdef HAVE_OPCUA
    qmlRegisterType<OpcUaDataSource>("Huayan.DataSource", 1, 0, "OpcUaDataSource");
    OpcUaDataSource *opcUaDataSource = new OpcUaDataSource(tagManager, &app);
    context->setContextProperty("opcUaDataSource", opcUaDataSource);
    #endif

    // Conditionally initialize and set up MqttDataSource if available
    #ifdef HAVE_MQTT
    qmlRegisterType<MqttDataSource>("Huayan.DataSource", 1, 0, "MqttDataSource");
    MqttDataSource *mqttDataSource = new MqttDataSource(tagManager, &app);
    context->setContextProperty("mqttDataSource", mqttDataSource);
    #endif

    // 设置QML导入路径
    QString qmlPath = QDir::currentPath() + "/qml";
    if (!QDir(qmlPath).exists()) {
        // 尝试从构建目录的上一级查找
        qmlPath = QDir::currentPath() + "/../qml";
        if (!QDir(qmlPath).exists()) {
            // 尝试从项目根目录查找
            qmlPath = QCoreApplication::applicationDirPath() + "/../qml";
        }
    }
    engine.addImportPath(qmlPath);
    
    // 添加QML插件路径
    // 尝试多种可能的插件路径
    QStringList pluginPaths;
    pluginPaths << qmlPath + "/plugins";
    pluginPaths << QCoreApplication::applicationDirPath() + "/qml/plugins";
    pluginPaths << QCoreApplication::applicationDirPath() + "/../qml/plugins";
    pluginPaths << QDir::currentPath() + "/qml/plugins";
    pluginPaths << QDir::currentPath() + "/../qml/plugins";
    
    // 添加所有可能的插件路径
    for (const QString &path : pluginPaths) {
        if (QDir(path).exists()) {
            engine.addImportPath(path);
        }
    }
    
    // 添加构建目录中的插件路径
    QString buildPluginPath = QString::fromLocal8Bit("%1/qml/plugins").arg(QDir::tempPath());
    QDir buildDir = QDir::current();
    if (buildDir.dirName() == "build" || buildDir.dirName().contains("build")) {
        buildPluginPath = buildDir.absolutePath() + "/qml/plugins";
    } else {
        // 尝试在常见的构建目录中查找
        QDir parentDir = buildDir;
        if (parentDir.cdUp()) {
            QDir buildDirCandidate = parentDir.absolutePath() + "/build";
            if (buildDirCandidate.exists()) {
                buildPluginPath = buildDirCandidate.absolutePath() + "/qml/plugins";
            }
        }
    }
    
    if (QDir(buildPluginPath).exists()) {
        engine.addImportPath(buildPluginPath);
    }

    // 加载QML主文件
    QString mainQmlPath = qmlPath + "/main.qml";
    const QUrl url = QUrl::fromLocalFile(mainQmlPath);
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
    #ifdef HAVE_OPCUA
    delete opcUaDataSource;
    #endif
    #ifdef HAVE_MQTT
    delete mqttDataSource;
    #endif
    delete modbusDataSource;
    delete chartDataModel;
    delete tagManager;

    return result;
}
