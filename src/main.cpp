#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QFile>
#include <QDebug>

#include "communication/hymodbustcpdriver.h"
#include "core/tagmanager.h"
#include "core/dataprocessor.h"

int main(int argc, char *argv[])
{
    // Set Qt application attributes
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);

    // Create application
    QApplication app(argc, argv);

    // Create QML engine
    QQmlApplicationEngine engine;

    // Add QML import paths
    // Try multiple import paths to handle different build directory structures
    QStringList importPaths = {
        QDir::currentPath() + "/qml",
        QDir::currentPath() + "/qml/plugins",
        QDir::currentPath() + "/../qml",
        QDir::currentPath() + "/../qml/plugins",
        QDir::currentPath() + "/../../qml",
        QDir::currentPath() + "/../../qml/plugins",
        QCoreApplication::applicationDirPath() + "/qml",
        QCoreApplication::applicationDirPath() + "/qml/plugins",
        QCoreApplication::applicationDirPath() + "/../qml",
        QCoreApplication::applicationDirPath() + "/../qml/plugins",
        QCoreApplication::applicationDirPath() + "/../../qml",
        QCoreApplication::applicationDirPath() + "/../../qml/plugins"
    };
    
    for (const QString &path : importPaths) {
        if (QDir(path).exists()) {
            engine.addImportPath(path);
            qDebug() << "Added QML import path:" << path;
        }
    }

    // Create core modules
    HYModbusTcpDriver *modbusDriver = new HYModbusTcpDriver(&app);
    HYTagManager *tagManager = new HYTagManager(&app);
    HYDataProcessor *dataProcessor = new HYDataProcessor(&app);

    // Initialize data processor with driver and tag manager
    dataProcessor->initialize(modbusDriver, tagManager);

    // Register core modules with QML engine
    engine.rootContext()->setContextProperty("modbusDriver", modbusDriver);
    engine.rootContext()->setContextProperty("tagManager", tagManager);
    engine.rootContext()->setContextProperty("dataProcessor", dataProcessor);

    // Add some example tags
    tagManager->addTag("Motor1_Running", "Motor Control", false, "Motor 1 running status");
    tagManager->addTag("Tank1_Level", "Tank Levels", 50, "Tank 1 level percentage");
    tagManager->addTag("Valve1_Open", "Valve Control", false, "Valve 1 open status");
    tagManager->addTag("Temperature1", "Process Values", 25.5, "Temperature sensor 1");
    tagManager->addTag("Pressure1", "Process Values", 100.0, "Pressure sensor 1");

    // Map tags to Modbus registers (example addresses)
    dataProcessor->mapTagToDeviceRegister("Motor1_Running", 0, false); // Coil
    dataProcessor->mapTagToDeviceRegister("Tank1_Level", 1);           // Holding register
    dataProcessor->mapTagToDeviceRegister("Valve1_Open", 1, false);     // Coil
    dataProcessor->mapTagToDeviceRegister("Temperature1", 2);           // Holding register
    dataProcessor->mapTagToDeviceRegister("Pressure1", 3);              // Holding register

    // Start data collection
    dataProcessor->startDataCollection(1000); // 1 second interval

    // Load main QML file from file system path
    // Start with file system path directly
    QUrl url;
    bool found = false;
    
    // Try relative paths from current working directory
    QStringList relativePaths = {
        "./qml/main.qml",
        "qml/main.qml",
        "./../qml/main.qml",
        "../qml/main.qml",
        "./../../qml/main.qml",
        "../../qml/main.qml"
    };
    
    for (const QString &relativePath : relativePaths) {
        QString qmlPath = QDir::currentPath() + "/" + relativePath;
        if (QFile::exists(qmlPath)) {
            url = QUrl::fromLocalFile(qmlPath);
            qDebug() << "Using relative path for QML:" << qmlPath;
            found = true;
            break;
        }
    }
    
    // Try paths relative to executable location
    if (!found) {
        QString exePath = QCoreApplication::applicationDirPath();
        QStringList exeRelativePaths = {
            "./qml/main.qml",
            "qml/main.qml",
            "./../qml/main.qml",
            "../qml/main.qml",
            "./../../qml/main.qml",
            "../../qml/main.qml"
        };
        
        for (const QString &relativePath : exeRelativePaths) {
            QString qmlPath = exePath + "/" + relativePath;
            if (QFile::exists(qmlPath)) {
                url = QUrl::fromLocalFile(qmlPath);
                qDebug() << "Using executable relative path for QML:" << qmlPath;
                found = true;
                break;
            }
        }
    }
    
    if (!found) {
        qDebug() << "Failed to find main.qml in any location";
        qDebug() << "Current working directory:" << QDir::currentPath();
        qDebug() << "Application directory:" << QCoreApplication::applicationDirPath();
        
        // Try to list directory contents to help debug
        QDir currentDir(QDir::currentPath());
        qDebug() << "Current directory contents:" << currentDir.entryList(QDir::AllEntries | QDir::NoDotAndDotDot);
    }
    
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            qDebug() << "Failed to load QML file:" << url.toString();
            QCoreApplication::exit(-1);
        }
    }, Qt::QueuedConnection);

    qDebug() << "Attempting to load QML from:" << url.toString();
    engine.load(url);

    // Run application
    int result = app.exec();

    // Cleanup
    delete dataProcessor;
    delete tagManager;
    delete modbusDriver;

    return result;
}
