#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>

#include "communication/modbustcpdriver.h"
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
    ModbusTcpDriver *modbusDriver = new ModbusTcpDriver(&app);
    TagManager *tagManager = new TagManager(&app);
    DataProcessor *dataProcessor = new DataProcessor(&app);

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

    // Load main QML file
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            QCoreApplication::exit(-1);
        }
    }, Qt::QueuedConnection);

    engine.load(url);

    // Run application
    int result = app.exec();

    // Cleanup
    delete dataProcessor;
    delete tagManager;
    delete modbusDriver;

    return result;
}
