#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QFile>
#include <QDebug>
#include <QStandardPaths>

#include "communication/hymodbustcpdriver.h"
#include "core/tagmanager.h"
#include "core/dataprocessor.h"

// Helper function to find QML files and import paths
class QmlPathFinder {
public:
    static QString findMainQmlFile() {
        // Try to find main.qml using standard directory structures
        QStringList searchPaths = getSearchPaths();
        
        for (const QString &basePath : searchPaths) {
            QString qmlPath = basePath + "/main.qml";
            if (QFile::exists(qmlPath)) {
                qDebug() << "Found main.qml at:" << qmlPath;
                return qmlPath;
            }
        }
        
        qDebug() << "Failed to find main.qml in any location";
        logDirectoryInfo();
        return QString();
    }
    
    static QStringList getQmlImportPaths() {
        QStringList importPaths;
        QStringList searchPaths = getSearchPaths();
        
        for (const QString &basePath : searchPaths) {
            // Add both the base path and its plugins subdirectory
            if (QDir(basePath).exists()) {
                importPaths << basePath;
                qDebug() << "Added QML import path:" << basePath;
            }
            
            QString pluginsPath = basePath + "/plugins";
            if (QDir(pluginsPath).exists()) {
                importPaths << pluginsPath;
                qDebug() << "Added QML import path:" << pluginsPath;
            }
        }
        
        return importPaths;
    }
    
private:
    static QStringList getSearchPaths() {
        QStringList paths;
        
        // 1. Paths relative to current working directory
        paths << QDir::currentPath() + "/qml";
        paths << QDir::currentPath() + "/../qml";
        paths << QDir::currentPath() + "/../../qml";
        
        // 2. Paths relative to executable directory
        QString exePath = QCoreApplication::applicationDirPath();
        paths << exePath + "/qml";
        paths << exePath + "/../qml";
        paths << exePath + "/../../qml";
        paths << exePath + "/../../../qml";
        
        // 3. Environment variable override
        QString envPath = qgetenv("QML_IMPORT_PATH");
        if (!envPath.isEmpty()) {
            paths << envPath;
        }
        
        return paths;
    }
    
    static void logDirectoryInfo() {
        qDebug() << "Current working directory:" << QDir::currentPath();
        qDebug() << "Application directory:" << QCoreApplication::applicationDirPath();
        
        // List current directory contents
        QDir currentDir(QDir::currentPath());
        qDebug() << "Current directory contents:" << currentDir.entryList(QDir::AllEntries | QDir::NoDotAndDotDot);
        
        // List application directory contents
        QDir appDir(QCoreApplication::applicationDirPath());
        qDebug() << "Application directory contents:" << appDir.entryList(QDir::AllEntries | QDir::NoDotAndDotDot);
    }
};

int main(int argc, char *argv[]) {
    // Set Qt application attributes
    // High DPI scaling is always enabled in Qt 6, no need to set these attributes

    // Create application
    QApplication app(argc, argv);

    // Create QML engine
    QQmlApplicationEngine engine;

    // Add QML import paths using helper function
    QStringList importPaths = QmlPathFinder::getQmlImportPaths();
    for (const QString &path : importPaths) {
        engine.addImportPath(path);
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

    // Find and load main QML file
    QString mainQmlPath = QmlPathFinder::findMainQmlFile();
    if (mainQmlPath.isEmpty()) {
        qCritical() << "Failed to find main.qml. Exiting.";
        return -1;
    }
    
    QUrl url = QUrl::fromLocalFile(mainQmlPath);
    
    // Connect error handling
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            qCritical() << "Failed to load QML file:" << url.toString();
            QCoreApplication::exit(-1);
        }
    }, Qt::QueuedConnection);

    qDebug() << "Loading QML from:" << url.toString();
    engine.load(url);

    // Run application
    int result = app.exec();

    // Cleanup
    delete dataProcessor;
    delete tagManager;
    delete modbusDriver;

    return result;
}
