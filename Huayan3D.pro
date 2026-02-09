QT += quick quick3d

CONFIG += c++17

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    src/3d/modelloader.cpp \
    src/3d/3dpointbinder.cpp \
    src/3d/modeloptimizer.cpp \
    main.cpp

HEADERS += \
    src/3d/modelloader.h \
    src/3d/3dpointbinder.h \
    src/3d/modeloptimizer.h

RESOURCES += qml.qrc

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    qml/3d/Huayan3DView.qml \
    assets/models/test_model.gltf \
    assets/data/simulated_points.json

# Performance optimization flags
QMAKE_CXXFLAGS_RELEASE += -O3 -march=native
