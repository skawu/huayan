QT += core quick charts network serialbus sql

QT += opcua mqtt

CONFIG += c++17

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    src/main.cpp \
    src/datasource/opcuadatasource.cpp \
    src/datasource/mqttdatasource.cpp \
    src/datasource/modbusdatasource.cpp \
    src/core/tagmanager.cpp \
    src/core/dataprocessor.cpp \
    src/core/timeseriesdatabase.cpp \
    src/core/chartdatamodel.cpp \
    src/export/csvexporter.cpp

HEADERS += \
    src/datasource/opcuadatasource.h \
    src/datasource/mqttdatasource.h \
    src/datasource/modbusdatasource.h \
    src/core/tagmanager.h \
    src/core/dataprocessor.h \
    src/core/timeseriesdatabase.h \
    src/core/chartdatamodel.h \
    src/export/csvexporter.h

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = qml

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# Enable high DPI support
QT += quickcontrols2

# Add QML plugins directory
QML2_IMPORT_PATH += $$PWD/qml/plugins

# Enable touch support
DEFINES += QT_QML_DEBUG

# Performance optimization
QMAKE_CXXFLAGS_RELEASE += -O3
QMAKE_LFLAGS_RELEASE += -O3

# Add include directories
INCLUDEPATH += \
    $$PWD/src \
    $$PWD/src/core \
    $$PWD/src/datasource \
    $$PWD/src/export
