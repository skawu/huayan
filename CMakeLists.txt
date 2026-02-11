cmake_minimum_required(VERSION 3.22)

project(SCADASystem VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Build type configuration
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type" FORCE)
endif()

# Available build types
set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "RelWithDebInfo" "MinSizeRel")

# Compiler options
if(MSVC)
    add_compile_options(/W4)
else()
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# Debug build options
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_compile_definitions(DEBUG=1)
    if(MSVC)
        add_compile_options(/Zi)
        add_link_options(/DEBUG)
    else()
        add_compile_options(-g -O0)
    endif()
endif()

# Release build options
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    add_compile_definitions(NDEBUG=1)
    if(MSVC)
        add_compile_options(/O2 /Ob2 /DNDEBUG)
    else()
        add_compile_options(-O3 -DNDEBUG)
    endif()
endif()

# Set RPATH for dynamic library linking
set(CMAKE_BUILD_RPATH_USE_ORIGIN TRUE)
set(CMAKE_INSTALL_RPATH "$ORIGIN/../lib")
# Ensure RPATH is set for both debug and release builds
set(CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
# Add additional RPATH entries for Qt Creator compatibility
set(CMAKE_BUILD_RPATH "$ORIGIN;$ORIGIN/lib;$ORIGIN/../lib")

# Qt 6 standard project setup
find_package(Qt6 6.8 REQUIRED COMPONENTS Core Quick Network SerialBus Sql Charts QuickControls2)

# Try to find optional Qt components
find_package(Qt6 COMPONENTS OpcUa QUIET)
set(HAVE_OPCUA ${Qt6OpcUa_FOUND})

find_package(Qt6 COMPONENTS Mqtt QUIET)
set(HAVE_MQTT ${Qt6Mqtt_FOUND})

qt_standard_project_setup()

# Set QML import path
set(QML_IMPORT_PATH ${CMAKE_SOURCE_DIR}/qml CACHE STRING "QML import path")

# Add subdirectories
add_subdirectory(src)
add_subdirectory(qml/plugins)

# Enable testing
option(BUILD_TESTING "Build tests" OFF)
if(BUILD_TESTING)
    find_package(Qt6 REQUIRED COMPONENTS Test)
    add_subdirectory(tests)
endif()

# Option for building documentation
option(BUILD_DOCUMENTATION "Build documentation" OFF)
if(BUILD_DOCUMENTATION)
    find_package(Doxygen REQUIRED)
    set(DOXYGEN_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/docs)
    set(DOXYGEN_GENERATE_HTML YES)
    set(DOXYGEN_GENERATE_MAN NO)
    set(DOXYGEN_GENERATE_LATEX NO)
    set(DOXYGEN_EXTRACT_ALL YES)
    set(DOXYGEN_EXTRACT_PRIVATE YES)
    set(DOXYGEN_EXTRACT_STATIC YES)
    set(DOXYGEN_OUTPUT_LANGUAGE Chinese)
    set(DOXYGEN_PROJECT_NAME "华颜工业SCADA系统")
    set(DOXYGEN_PROJECT_BRIEF "基于Qt 6的工业SCADA系统")
    set(DOXYGEN_PROJECT_NUMBER ${PROJECT_VERSION})
    set(DOXYGEN_INPUT ${CMAKE_SOURCE_DIR}/src)
    doxygen_add_docs(doxygen ${CMAKE_SOURCE_DIR}/src)
endif()

# Option for building examples
option(BUILD_EXAMPLES "Build examples" OFF)
if(BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

# Install configuration
set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/bin CACHE PATH "Installation prefix" FORCE)
set(CMAKE_INSTALL_BINDIR . CACHE PATH "Executables directory" FORCE)
set(CMAKE_INSTALL_LIBDIR lib CACHE PATH "Libraries directory" FORCE)
set(CMAKE_INSTALL_QMLDIR qml CACHE PATH "QML modules directory" FORCE)
set(CMAKE_INSTALL_PLUGINDIR plugins CACHE PATH "Plugins directory" FORCE)

# Ensure bin directory exists
file(MAKE_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)

install(TARGETS SCADASystem
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Install QML modules
install(DIRECTORY ${CMAKE_SOURCE_DIR}/qml
    DESTINATION ${CMAKE_INSTALL_PREFIX}
    PATTERN "*.so" EXCLUDE
    PATTERN "*.dll" EXCLUDE
    PATTERN "*.dylib" EXCLUDE
    PATTERN "*.a" EXCLUDE
    PATTERN ".rcc" EXCLUDE
    PATTERN ".qt" EXCLUDE
    PATTERN "meta_types" EXCLUDE
    PATTERN "qmltypes" EXCLUDE
    PATTERN "*plugin_*Plugin.cpp" EXCLUDE
    PATTERN "*plugin_*Plugin_in.cpp" EXCLUDE
    PATTERN "*.qmltypes" EXCLUDE
    PATTERN "*_qml_module_dir_map.qrc" EXCLUDE
    PATTERN "*_autogen" EXCLUDE
    PATTERN "*qmltyperegistrations.cpp" EXCLUDE
)

# Install built QML plugins
if(EXISTS ${CMAKE_BINARY_DIR}/qml/plugins)
    install(DIRECTORY ${CMAKE_BINARY_DIR}/qml/plugins
        DESTINATION ${CMAKE_INSTALL_PREFIX}/qml
        FILES_MATCHING
        PATTERN "*.so"
        PATTERN "*.dll"
        PATTERN "*.dylib"
    )
endif()

# Install Qt platform plugins (if needed)
if(EXISTS "${QT_PLUGINS_DIR}/platforms")
    install(DIRECTORY "${QT_PLUGINS_DIR}/platforms"
        DESTINATION ${CMAKE_INSTALL_PLUGINDIR}
    )
endif()

# Install examples
install(DIRECTORY ${CMAKE_SOURCE_DIR}/examples
    DESTINATION ${CMAKE_INSTALL_PREFIX}
    OPTIONAL
)

# Install documentation
install(DIRECTORY ${CMAKE_SOURCE_DIR}/docs
    DESTINATION ${CMAKE_INSTALL_PREFIX}
    OPTIONAL
)

# Create run script for installation
if(UNIX)
    configure_file(
        ${CMAKE_SOURCE_DIR}/scripts/run.sh.in
        ${CMAKE_BINARY_DIR}/run.sh
        @ONLY
    )
    execute_process(
        COMMAND chmod +x ${CMAKE_BINARY_DIR}/run.sh
    )
    install(PROGRAMS ${CMAKE_BINARY_DIR}/run.sh
        DESTINATION ${CMAKE_INSTALL_PREFIX}
        RENAME run.sh
    )
elseif(WIN32)
    configure_file(
        ${CMAKE_SOURCE_DIR}/scripts/run.bat.in
        ${CMAKE_BINARY_DIR}/run.bat
        @ONLY
    )
    install(PROGRAMS ${CMAKE_BINARY_DIR}/run.bat
        DESTINATION ${CMAKE_INSTALL_PREFIX}
        RENAME run.bat
    )
endif()

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.0
if(NOT DEFINED MACOSX_BUNDLE_GUI_IDENTIFIER)
  set(MACOSX_BUNDLE_GUI_IDENTIFIER com.example.SCADASystem)
endif()

# Create package target
add_custom_target(create-package
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --config Release
    COMMAND ${CMAKE_COMMAND} --install ${CMAKE_BINARY_DIR} --config Release
    COMMENT "Creating package"
)

# Create clean target
add_custom_target(clean-all
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_SOURCE_DIR}/bin
    COMMENT "Cleaning all build artifacts"
)

# Create run target for development
add_custom_target(run
    COMMAND ${CMAKE_BINARY_DIR}/src/SCADASystem
    DEPENDS SCADASystem
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Running SCADASystem"
)

# CPack configuration for creating installation packages
set(CPACK_PACKAGE_NAME "Huayan工业SCADA系统")
set(CPACK_PACKAGE_VENDOR "Huayan Software")
set(CPACK_PACKAGE_VERSION "1.0.0")
set(CPACK_PACKAGE_DESCRIPTION "基于Qt 6.8 LTS的工业SCADA系统，支持钢铁、化工、电力等行业的组态编辑和运维管理")
set(CPACK_PACKAGE_HOMEPAGE_URL "https://github.com/skawu/huayan")
set(CPACK_PACKAGE_FILE_NAME "huayan-${CPACK_PACKAGE_VERSION}")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_README "${CMAKE_SOURCE_DIR}/README_CN.md")

# Windows specific configuration
if(WIN32)
    set(CPACK_GENERATOR "NSIS")
    set(CPACK_NSIS_DISPLAY_NAME "Huayan工业SCADA系统")
    set(CPACK_NSIS_PACKAGE_NAME "Huayan工业SCADA系统 ${CPACK_PACKAGE_VERSION}")
    set(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\SCADASystem.exe")
    set(CPACK_NSIS_HELP_LINK "${CPACK_PACKAGE_HOMEPAGE_URL}")
    set(CPACK_NSIS_URL_INFO_ABOUT "${CPACK_PACKAGE_HOMEPAGE_URL}")
    set(CPACK_NSIS_CONTACT "support@huayan.com")
    set(CPACK_NSIS_MODIFY_PATH ON)
    set(CPACK_NSIS_CREATE_ICONS_EXTRA "\n  CreateShortCut '$SMPROGRAMS\\$STARTMENU_FOLDER\\Huayan工业SCADA系统.lnk' '$INSTDIR\\bin\\SCADASystem.exe'")
    set(CPACK_NSIS_DELETE_ICONS_EXTRA "\n  Delete '$SMPROGRAMS\\$STARTMENU_FOLDER\\Huayan工业SCADA系统.lnk'")

# Linux specific configuration
elseif(UNIX AND NOT APPLE)
    set(CPACK_GENERATOR "DEB;RPM;TGZ")
    set(CPACK_DEBIAN_PACKAGE_NAME "huayan")
    set(CPACK_DEBIAN_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}")
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Huayan Software <support@huayan.com>")
    set(CPACK_DEBIAN_PACKAGE_DESCRIPTION "${CPACK_PACKAGE_DESCRIPTION}")
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "qt6-base, qt6-declarative, qt6-network, qt6-serialbus, qt6-charts, qt6-quickcontrols2")
    set(CPACK_DEBIAN_PACKAGE_SECTION "science")
    set(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
    set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "${CPACK_PACKAGE_HOMEPAGE_URL}")
    
    set(CPACK_RPM_PACKAGE_NAME "huayan")
    set(CPACK_RPM_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}")
    set(CPACK_RPM_PACKAGE_RELEASE "1")
    set(CPACK_RPM_PACKAGE_ARCHITECTURE "x86_64")
    set(CPACK_RPM_PACKAGE_SUMMARY "Huayan工业SCADA系统")
    set(CPACK_RPM_PACKAGE_DESCRIPTION "${CPACK_PACKAGE_DESCRIPTION}")
    set(CPACK_RPM_PACKAGE_GROUP "Applications/Science")
    set(CPACK_RPM_PACKAGE_VENDOR "${CPACK_PACKAGE_VENDOR}")
    set(CPACK_RPM_PACKAGE_URL "${CPACK_PACKAGE_HOMEPAGE_URL}")
    set(CPACK_RPM_PACKAGE_LICENSE "Apache-2.0")
    set(CPACK_RPM_PACKAGE_REQUIRES "qt6-base, qt6-declarative, qt6-network, qt6-serialbus, qt6-charts, qt6-quickcontrols2")

# ARM specific configuration
if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm|aarch64")
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "arm64")
    set(CPACK_RPM_PACKAGE_ARCHITECTURE "aarch64")
    set(CPACK_PACKAGE_FILE_NAME "huayan-${CPACK_PACKAGE_VERSION}-arm64")
endif()

# macOS specific configuration
elseif(APPLE)
    set(CPACK_GENERATOR "DragNDrop")
    set(CPACK_DMG_VOLUME_NAME "Huayan工业SCADA系统")
    set(CPACK_DMG_DS_STORE_SETUP_SCRIPT "${CMAKE_SOURCE_DIR}/scripts/dmg-setup.scpt")
    set(CPACK_DMG_BACKGROUND_IMAGE "${CMAKE_SOURCE_DIR}/assets/dmg-background.png")
endif()

# Include CPack
include(CPack)
