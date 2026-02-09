# Main application CMakeLists.txt

# Set Qt policy to suppress QTP0001 warning
qt_policy(SET QTP0001 NEW)

# Add executable
qt_add_executable(SCADASystem
    main.cpp
    communication/hymodbustcpdriver.cpp
    core/tagmanager.cpp
    core/dataprocessor.cpp
    communication/hymodbustcpdriver.h
    core/tagmanager.h
    core/dataprocessor.h
    core/timeseriesdatabase.cpp
    core/timeseriesdatabase.h
    resources.qrc
)

# Add QML module for main application
qt_add_qml_module(SCADASystemQml
    URI SCADASystemQml
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/SCADASystemQml
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

# Copy QML files and plugins to build directory for development
add_custom_command(TARGET SCADASystem POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/qml
        ${CMAKE_BINARY_DIR}/qml
    COMMENT "Copying QML files to build directory"
)

# Ensure the plugins directory exists in build directory
add_custom_command(TARGET SCADASystem PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory
        ${CMAKE_BINARY_DIR}/qml/plugins
    COMMENT "Creating QML plugins directory in build directory"
)
