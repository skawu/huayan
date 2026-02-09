# ControlComponents CMakeLists.txt

# Set Qt policy to suppress QTP0001 warning
qt_policy(SET QTP0001 NEW)

qt_add_qml_module(ControlComponents
    URI ControlComponents
    VERSION 1.0
    QML_FILES
        Slider.qml
        Knob.qml
    RESOURCES
        qmldir
    DEPENDENCIES
        QtQuick
        QtQuick.Controls
)

# Set target properties
set_target_properties(ControlComponents PROPERTIES
    QT_QML_MODULE_INSTALL TRUE
    QT_QML_MODULE_VERSION 1.0
    QT_QML_MODULE_URI ControlComponents
)

# Install the plugin
install(TARGETS ControlComponents
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Install QML files
install(FILES
    Slider.qml
    Knob.qml
    qmldir
    DESTINATION ${CMAKE_INSTALL_PREFIX}/qml/ControlComponents
)
