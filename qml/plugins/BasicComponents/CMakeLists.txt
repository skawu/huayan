# BasicComponents plugin CMakeLists.txt

qt_add_qml_module(BasicComponents
    URI BasicComponents
    VERSION 1.0
    QML_FILES
        Indicator.qml
        PushButton.qml
        TextLabel.qml
    OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/qml/plugins/BasicComponents
)

# Set plugin properties
set_target_properties(BasicComponents PROPERTIES
    QT_QML_MODULE_VERSION 1.0
    QT_QML_MODULE_URI BasicComponents
)

# Install configuration
install(TARGETS BasicComponents
    LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/qml/BasicComponents
)

install(FILES qmldir
    DESTINATION ${CMAKE_INSTALL_PREFIX}/qml/BasicComponents
)
