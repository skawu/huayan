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
    add_compile_options(/W4 /WX)
else()
    add_compile_options(-Wall -Wextra -Wpedantic -Werror)
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

# Qt 6 standard project setup
find_package(Qt6 6.8 REQUIRED COMPONENTS Core Quick Network SerialBus Sql Charts QuickControls2)

# Try to find OpcUa component (optional)
find_package(Qt6 COMPONENTS OpcUa QUIET)
set(HAVE_OPCUA ${Qt6OpcUa_FOUND})

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

# Install configuration
set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/bin CACHE PATH "Installation prefix" FORCE)
set(CMAKE_INSTALL_BINDIR bin CACHE PATH "Executables directory" FORCE)
set(CMAKE_INSTALL_LIBDIR lib CACHE PATH "Libraries directory" FORCE)
set(CMAKE_INSTALL_QMLDIR qml CACHE PATH "QML modules directory" FORCE)

install(TARGETS SCADASystem
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Install QML modules
install(DIRECTORY ${CMAKE_SOURCE_DIR}/qml/plugins
    DESTINATION ${CMAKE_INSTALL_QMLDIR}
)

# Install examples
install(DIRECTORY ${CMAKE_SOURCE_DIR}/examples
    DESTINATION ${CMAKE_INSTALL_PREFIX}
)

# Install documentation
install(DIRECTORY ${CMAKE_SOURCE_DIR}/docs
    DESTINATION ${CMAKE_INSTALL_PREFIX}
    OPTIONAL
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.0
if(NOT DEFINED MACOSX_BUNDLE_GUI_IDENTIFIER)
  set(MACOSX_BUNDLE_GUI_IDENTIFIER com.example.SCADASystem)
endif()

# Create package target
add_custom_target(package
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
