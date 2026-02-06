cmake_minimum_required(VERSION 3.22)

project(SCADASystem VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Qt 6 standard project setup
find_package(Qt6 6.8 REQUIRED COMPONENTS Core Quick Network SerialBus Sql Charts QuickControls2)
qt_standard_project_setup()

# Set QML import path
set(QML_IMPORT_PATH ${CMAKE_SOURCE_DIR}/qml CACHE STRING "QML import path")

# Add subdirectories
add_subdirectory(src)
add_subdirectory(qml/plugins)

# Install configuration
install(TARGETS SCADASystem
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.0
if(NOT DEFINED MACOSX_BUNDLE_GUI_IDENTIFIER)
  set(MACOSX_BUNDLE_GUI_IDENTIFIER com.example.SCADASystem)
endif()

# Enable testing if needed
if(BUILD_TESTING)
    find_package(Qt6 REQUIRED COMPONENTS Test)
    add_subdirectory(tests)
endif()
