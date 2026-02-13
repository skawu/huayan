# Main application CMakeLists.txt

# Set Qt policy to suppress QTP0001 warning
qt_policy(SET QTP0001 NEW)

# Add executable
qt_add_executable(SCADASystem
    main.cpp
    communication/hymodbustcpdriver.cpp
    core/tagmanager.cpp
    core/dataprocessor.cpp
    core/chartdatamodel.cpp
    core/chartdatamodel.h
    core/configmanager.cpp
    core/configmanager.h
    core/extensionmanager.cpp
    core/extensionmanager.h
    datasource/datasource.cpp
    datasource/datasource.h
    datasource/modbusdatasource.cpp
    datasource/modbusdatasource.h
    datasource/mqttdatasource.cpp
    datasource/mqttdatasource.h
    datasource/opcuadatasource.cpp
    datasource/opcuadatasource.h
    communication/hymodbustcpdriver.h
    core/tagmanager.h
    core/dataprocessor.h
    core/timeseriesdatabase.cpp
    core/timeseriesdatabase.h
    editor/core/editorcore.cpp
    editor/core/editorcore.h
)

# Copy editor QML files
add_custom_command(TARGET SCADASystem POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/src/editor
        ${CMAKE_BINARY_DIR}/editor
    COMMENT "Copying editor files to build directory"
)

# Also copy editor files to the executable directory (next to the built executable)
add_custom_command(TARGET SCADASystem POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/src/editor
        $<TARGET_FILE_DIR:SCADASystem>/editor
    COMMENT "Copying editor files to executable directory"
)

# Also copy editor files to the executable directory
add_custom_command(TARGET SCADASystem POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/src/editor
        $<TARGET_FILE_DIR:SCADASystem>/editor
    COMMENT "Copying editor files to executable directory"
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

# Link OpcUa if available
if(HAVE_OPCUA)
    target_link_libraries(SCADASystem PRIVATE Qt6::OpcUa)
    target_compile_definitions(SCADASystem PRIVATE HAVE_OPCUA=1)
endif()

# Link Mqtt if available
if(HAVE_MQTT)
    target_link_libraries(SCADASystem PRIVATE Qt6::Mqtt)
    target_compile_definitions(SCADASystem PRIVATE HAVE_MQTT=1)
endif()

# Set properties
set_target_properties(SCADASystem PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)

# Install configuration
install(TARGETS SCADASystem
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Install QML module
install(TARGETS SCADASystemQml
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_QMLDIR}/SCADASystemQml
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Copy QML files and plugins to build directory for development
add_custom_command(TARGET SCADASystem POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/qml
        ${CMAKE_BINARY_DIR}/qml
    COMMENT "Copying QML files to build directory"
)

# Also copy QML files to the executable directory (next to the built executable)
add_custom_command(TARGET SCADASystem POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/qml
        $<TARGET_FILE_DIR:SCADASystem>/qml
    COMMENT "Copying QML files to executable directory"
)

# Also copy QML files to the directory where the executable is built
# This handles the case where the executable is built directly in the bin directory
# (as in Qt Creator's build setup)
add_custom_command(TARGET SCADASystem POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/qml
        $<TARGET_FILE_DIR:SCADASystem>/qml
    COMMENT "Copying QML files to executable directory"
)

# Also copy built QML plugins to the executable directory
# This ensures that the plugins are available in the same directory as the executable
add_custom_command(TARGET SCADASystem POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_BINARY_DIR}/qml/plugins
        $<TARGET_FILE_DIR:SCADASystem>/qml/plugins
    COMMENT "Copying built QML plugins to executable directory"
)

# Copy resources to build directory
add_custom_command(TARGET SCADASystem POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/src/resources
        ${CMAKE_BINARY_DIR}/resources
    COMMENT "Copying resources to build directory"
)

# Also copy resources to the executable directory
add_custom_command(TARGET SCADASystem POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/src/resources
        $<TARGET_FILE_DIR:SCADASystem>/resources
    COMMENT "Copying resources to executable directory"
)

# Also copy resources to the executable directory
add_custom_command(TARGET SCADASystem POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/src/resources
        $<TARGET_FILE_DIR:SCADASystem>/resources
    COMMENT "Copying resources to executable directory"
)

# Ensure the plugins directory exists in build directory
add_custom_command(TARGET SCADASystem PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory
        ${CMAKE_BINARY_DIR}/qml/plugins
    COMMENT "Creating QML plugins directory in build directory"
)

# Ensure the resources directory exists in build directory
add_custom_command(TARGET SCADASystem PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory
        ${CMAKE_BINARY_DIR}/resources
    COMMENT "Creating resources directory in build directory"
)

# Create run script for development
if(UNIX)
    configure_file(
        ${CMAKE_SOURCE_DIR}/scripts/run.sh.in
        ${CMAKE_BINARY_DIR}/run.sh
        @ONLY
    )
    execute_process(
        COMMAND chmod +x ${CMAKE_BINARY_DIR}/run.sh
    )
elseif(WIN32)
    configure_file(
        ${CMAKE_SOURCE_DIR}/scripts/run.bat.in
        ${CMAKE_BINARY_DIR}/run.bat
        @ONLY
    )
endif()
