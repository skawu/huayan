# IndustrialComponents CMakeLists.txt

# Set Qt policy to suppress QTP0001 warning
qt_policy(SET QTP0001 NEW)

qt_add_qml_module(IndustrialComponents
    URI IndustrialComponents
    VERSION 1.0
    QML_FILES
        Valve.qml
        Tank.qml
        Motor.qml
    OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/qml/plugins/IndustrialComponents
)

# Set plugin properties
set_target_properties(IndustrialComponents PROPERTIES
    QT_QML_MODULE_VERSION 1.0
    QT_QML_MODULE_URI IndustrialComponents
)

# Install configuration
install(TARGETS IndustrialComponents
    LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/qml/IndustrialComponents
)

install(FILES qmldir
    DESTINATION ${CMAKE_INSTALL_PREFIX}/qml/IndustrialComponents
)
