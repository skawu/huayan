# ControlComponents CMakeLists.txt

# Set Qt policy to suppress QTP0001 warning
qt_policy(SET QTP0001 NEW)

qt_add_qml_module(ControlComponents
    URI ControlComponents
    VERSION 1.0
    QML_FILES
        Slider.qml
        Knob.qml
    OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/qml/plugins/ControlComponents
)

# Set plugin properties
set_target_properties(ControlComponents PROPERTIES
    QT_QML_MODULE_VERSION 1.0
    QT_QML_MODULE_URI ControlComponents
)

# Install configuration
install(TARGETS ControlComponents
    LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/qml/ControlComponents
)

install(FILES qmldir
    DESTINATION ${CMAKE_INSTALL_PREFIX}/qml/ControlComponents
)
