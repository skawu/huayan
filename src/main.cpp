#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QQmlContext>
#include <QIcon>
#include <QDir>
#include <QStandardPaths>
#include <QTimer>
#include <QFileInfo>
#include <QDebug>
#include <QDateTime>
#include <QSysInfo>

#include "core/tagmanager.h"
#include "core/chartdatamodel.h"
#include "core/configmanager.h"
#include "core/extensionmanager.h"

// Conditionally include Mqtt headers if available
#ifdef HAVE_MQTT
#include "datasource/mqttdatasource.h"
#endif

#include "datasource/modbusdatasource.h"

// Conditionally include OpcUa headers if available
#ifdef HAVE_OPCUA
#include "datasource/opcuadatasource.h"
#endif

#include "editor/core/editorcore.h"

/**
 * @file main.cpp
 * @brief Huayan工业软件应用程序入口
 * 
 * 实现了Huayan工业软件的应用程序入口点，初始化C++后端与QML前端
 * 注册QML类型，设置上下文属性，启动应用程序
 */

// 系统信息检测函数
QString detectSystemInfo() {
    QString systemInfo = "";
    
    // 检测操作系统
    QString osName = QSysInfo::productType();
    QString osVersion = QSysInfo::productVersion();
    systemInfo += QString("OS: %1 %2\n").arg(osName).arg(osVersion);
    
    // 检测CPU架构
    QString cpuArch = QSysInfo::currentCpuArchitecture();
    systemInfo += QString("CPU Arch: %1\n").arg(cpuArch);
    
    // 检测国产化系统
    if (osName.contains("kylin", Qt::CaseInsensitive) || osName.contains("uos", Qt::CaseInsensitive)) {
        systemInfo += "Domestic OS: Yes\n";
    }
    
    // 检测国产化CPU
    if (cpuArch.contains("arm", Qt::CaseInsensitive) || cpuArch.contains("aarch64", Qt::CaseInsensitive)) {
        systemInfo += "Domestic CPU: Likely (ARM architecture)\n";
    }
    
    return systemInfo;
}

// 内存使用监控函数
void monitorMemoryUsage() {
    static QTimer *memoryTimer = new QTimer();
    static int checkInterval = 60000; // 1分钟检查一次
    
    QObject::connect(memoryTimer, &QTimer::timeout, []() {
        // 这里可以添加内存使用监控逻辑
        // 例如使用QProcess调用系统命令获取内存使用情况
        qDebug() << "Memory usage checked at:" << QDateTime::currentDateTime().toString();
    });
    
    memoryTimer->start(checkInterval);
}

int main(int argc, char *argv[])
{
    // 设置Qt应用程序属性
    QCoreApplication::setApplicationName("HuayanSCADA");
    QCoreApplication::setApplicationVersion("1.0.0");
    QCoreApplication::setOrganizationName("Huayan Software");
    QCoreApplication::setOrganizationDomain("huayan.com");

    // 创建应用程序实例
    QApplication app(argc, argv);

    // 输出Qt版本信息
    qDebug() << "Qt Version:" << QT_VERSION_STR;
    qDebug() << "Qt Library Path:" << QCoreApplication::libraryPaths();

    // 设置应用程序图标
    app.setWindowIcon(QIcon());

    // 初始化配置管理器
    ConfigManager *configManager = ConfigManager::instance();
    qDebug() << "Initializing ConfigManager...";
    configManager->initialize(&app);
    qDebug() << "ConfigManager initialized successfully";
    qDebug() << "Config file path:" << configManager->getConfigFilePath();
    qDebug() << "Default config file path:" << configManager->getDefaultConfigFilePath();

    // 初始化Huayan点位管理系统
    qDebug() << "Initializing HYTagManager...";
    HYTagManager *tagManager = new HYTagManager(&app);
    qDebug() << "HYTagManager created successfully";
    
    // 启用点位管理器的持久化和历史数据存储
    qDebug() << "Enabling persistence and history storage...";
    tagManager->enablePersistence(true);
    tagManager->enableHistoryStorage(true, 1000, 365); // 1秒存储一次，保留365天
    qDebug() << "Persistence and history storage enabled";
    
    // 启用批量更新模式，提高性能
    qDebug() << "Enabling batch update mode...";
    tagManager->setBatchUpdateMode(true);
    tagManager->setBatchUpdateInterval(50); // 50ms更新一次，确保响应延迟≤500ms
    qDebug() << "Batch update mode enabled with interval: 50ms";
    
    // 加载之前的状态
    qDebug() << "Loading previous state...";
    tagManager->loadState();
    qDebug() << "State loaded successfully";
    
    // 初始化扩展管理器
    qDebug() << "Initializing ExtensionManager...";
    ExtensionManager *extensionManager = ExtensionManager::instance();
    extensionManager->initialize(&app);
    qDebug() << "ExtensionManager initialized successfully";
    
    // 打印系统信息
    qDebug() << "System Information:";
    qDebug() << detectSystemInfo();
    
    // 启动内存使用监控
    monitorMemoryUsage();
    
    // 设置定期保存状态的定时器
    QTimer *saveTimer = new QTimer(&app);
    QObject::connect(saveTimer, &QTimer::timeout, [tagManager]() {
        tagManager->saveState();
        qDebug() << "State saved at:" << QDateTime::currentDateTime().toString();
    });
    saveTimer->start(300000); // 5分钟保存一次
    
    // 延迟加载扩展，提高启动速度
    qDebug() << "Scheduling delayed extension loading...";
    QTimer::singleShot(1000, [extensionManager]() {
        qDebug() << "Starting extension loading...";
        extensionManager->loadExtensions();
        qDebug() << "Extension loading completed";
    });

    // 初始化图表数据模型
    qDebug() << "Initializing ChartDataModel...";
    ChartDataModel *chartDataModel = new ChartDataModel(tagManager, &app);
    qDebug() << "ChartDataModel initialized successfully";

    // 创建QML应用程序引擎
    qDebug() << "Creating QQmlApplicationEngine...";
    QQmlApplicationEngine engine;

    // 注册QML类型
    qmlRegisterType<HYTagManager>("Huayan.Core", 1, 0, "HYTagManager");
    qmlRegisterType<ChartDataModel>("Huayan.Core", 1, 0, "ChartDataModel");
    qmlRegisterType<ModbusDataSource>("Huayan.DataSource", 1, 0, "ModbusDataSource");
    qmlRegisterType<EditorCore>("Huayan.Editor", 1, 0, "EditorCore");
    qmlRegisterSingletonType<ConfigManager>("Huayan.Core", 1, 0, "ConfigManager", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return ConfigManager::instance();
    });
    qmlRegisterSingletonType<ExtensionManager>("Huayan.Core", 1, 0, "ExtensionManager", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return ExtensionManager::instance();
    });

    // 初始化数据源
    ModbusDataSource *modbusDataSource = new ModbusDataSource(tagManager, &app);

    // 初始化编辑器核心
    EditorCore *editorCore = new EditorCore(&app);

    // 设置QML上下文属性
    QQmlContext *context = engine.rootContext();
    context->setContextProperty("tagManager", tagManager);
    context->setContextProperty("chartDataModel", chartDataModel);
    context->setContextProperty("modbusDataSource", modbusDataSource);
    context->setContextProperty("editorCore", editorCore);
    context->setContextProperty("configManager", configManager);
    context->setContextProperty("extensionManager", extensionManager);

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
    // 优先使用应用程序目录的qml文件夹
    qDebug() << "Setting up QML import paths...";
    QString qmlPath = QCoreApplication::applicationDirPath() + "/qml";
    qDebug() << "Checking QML path 1:" << qmlPath;
    if (!QDir(qmlPath).exists()) {
        // 尝试从当前目录查找
        qmlPath = QDir::currentPath() + "/qml";
        qDebug() << "Checking QML path 2:" << qmlPath;
        if (!QDir(qmlPath).exists()) {
            // 尝试从构建目录的上一级查找
            qmlPath = QDir::currentPath() + "/../qml";
            qDebug() << "Checking QML path 3:" << qmlPath;
        }
    }
    qDebug() << "Using QML path:" << qmlPath;
    engine.addImportPath(qmlPath);
    // 添加标准的QML导入路径
    qDebug() << "Adding QRC import path: qrc:/";
    engine.addImportPath("qrc:/");
    
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

    // 连接QML引擎的错误信号，获取详细错误信息
    QObject::connect(&engine, &QQmlApplicationEngine::warnings, [](const QList<QQmlError> &warnings) {
        for (const QQmlError &warning : warnings) {
            qWarning() << "QML Warning:" << warning.toString();
        }
    });

    // 加载QML主文件
    QString mainQmlPath = qmlPath + "/main.qml";
    const QUrl url = QUrl::fromLocalFile(mainQmlPath);
    
    qDebug() << "Loading QML file from:" << mainQmlPath;
    qDebug() << "QML file exists:" << QFile::exists(mainQmlPath);
    
    if (!QFile::exists(mainQmlPath)) {
        qCritical() << "ERROR: QML file does not exist at:" << mainQmlPath;
        qCritical() << "Trying alternative locations...";
        
        // Try alternative paths
        QStringList altPaths;
        altPaths << QCoreApplication::applicationDirPath() + "/../src/main.qml";
        altPaths << QCoreApplication::applicationDirPath() + "/../qml/main.qml";
        altPaths << QDir::currentPath() + "/src/main.qml";
        altPaths << QDir::currentPath() + "/main.qml";
        
        bool found = false;
        for (const QString &altPath : altPaths) {
            if (QFile::exists(altPath)) {
                qDebug() << "Found QML file at alternative location:" << altPath;
                mainQmlPath = altPath;
                const QUrl altUrl = QUrl::fromLocalFile(altPath);
                engine.load(altUrl);
                found = true;
                break;
            }
        }
        
        if (!found) {
            qCritical() << "ERROR: Could not find main.qml at any expected location!";
            qCritical() << "Searched paths:";
            qCritical() << "-" << qmlPath + "/main.qml";
            for (const QString &altPath : altPaths) {
                qCritical() << "-" << altPath;
            }
            return -1;
        }
    } else {
        engine.load(url);
    }

    // 检查QML加载是否成功
    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Failed to load QML file. Check if main.qml exists at:" << mainQmlPath;
        qCritical() << "Current QML import paths:" << engine.importPathList();
        qCritical() << "Application directory:" << QCoreApplication::applicationDirPath();
        qCritical() << "Current directory:" << QDir::currentPath();
        return -1;
    }
    qDebug() << "QML file loaded successfully!";
    qDebug() << "Root objects count:" << engine.rootObjects().size();
    qDebug() << "Root object type:" << engine.rootObjects().first()->metaObject()->className();

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

    // 应用程序退出前保存状态
    tagManager->saveState();
    qDebug() << "Application state saved on exit";

    // 清理资源
    #ifdef HAVE_OPCUA
    delete opcUaDataSource;
    #endif
    #ifdef HAVE_MQTT
    delete mqttDataSource;
    #endif
    delete modbusDataSource;
    delete editorCore;
    delete chartDataModel;
    delete tagManager;

    return result;
}