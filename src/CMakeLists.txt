# Main application CMakeLists.txt

# Add executable
qt_add_executable(SCADASystem
    main.cpp
    communication/modbustcpdriver.cpp
    core/tagmanager.cpp
    core/dataprocessor.cpp
    communication/modbustcpdriver.h
    core/tagmanager.h
    core/dataprocessor.h
)

# Add QML module for main application
qt_add_qml_module(SCADASystemQml
    URI SCADASystemQml
    VERSION 1.0
    QML_FILES
        ../qml/main.qml
        ../qml/DragAndDropHelper.qml
    RESOURCES
        resources.qrc
)

# Link libraries
target_link_libraries(SCADASystem PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Network
    Qt6::SerialBus
    Qt6::Sql
    Qt6::Charts
    Qt6::QuickControls2
    SCADASystemQml
)

# Set properties
set_target_properties(SCADASystem PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

# Install configuration
install(TARGETS SCADASystem
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Install QML imports
install(DIRECTORY ${CMAKE_SOURCE_DIR}/qml/plugins
    DESTINATION ${CMAKE_INSTALL_PREFIX}/qml
)
