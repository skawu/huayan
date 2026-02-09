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
    engine.addImportPath(QDir::currentPath() + "/qml");
    engine.addImportPath(QDir::currentPath() + "/qml/plugins");

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

    // Load main QML file with fallback
    QUrl url = QUrl(QStringLiteral("qrc:/qml/main.qml"));
    
    // Fallback to file system path if resource path fails
    if (!QFile::exists(":/qml/main.qml")) {
        QString qmlPath = QDir::currentPath() + "/qml/main.qml";
        if (QFile::exists(qmlPath)) {
            url = QUrl::fromLocalFile(qmlPath);
            qDebug() << "Using file system path for QML:" << qmlPath;
        } else {
            qmlPath = QDir::homePath() + "/workspace/huayan/qml/main.qml";
            if (QFile::exists(qmlPath)) {
                url = QUrl::fromLocalFile(qmlPath);
                qDebug() << "Using home path for QML:" << qmlPath;
            } else {
                // Try common project paths
                QStringList possiblePaths = {
                    QDir::homePath() + "/workspace/huayan/qml/main.qml",
                    QDir::homePath() + "/huayan/qml/main.qml",
                    "/home/hdzk/workspace/huayan/qml/main.qml",
                    "/home/hdzk/huayan/qml/main.qml"
                };
                
                bool found = false;
                for (const QString &path : possiblePaths) {
                    if (QFile::exists(path)) {
                        url = QUrl::fromLocalFile(path);
                        qDebug() << "Using common path for QML:" << path;
                        found = true;
                        break;
                    }
                }
                
                if (!found) {
                    qDebug() << "Failed to find main.qml in any location";
                    qDebug() << "Current working directory:" << QDir::currentPath();
                    qDebug() << "Home directory:" << QDir::homePath();
                }
            }
        }
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
