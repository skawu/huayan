cmake_minimum_required(VERSION 3.16)

project(HMIControls VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick)

qt_add_library(HMIControls STATIC)

qt6_add_qml_module(HMIControls
    URI Huayan.HMIControls
    VERSION 1.0
    QML_FILES
        Button.qml
        IndicatorLight.qml
        Slider.qml
        DIPSwitch.qml
        Dashboard.qml
        ToggleSwitch.qml
        ProgressBar.qml
        NumericDisplay.qml
        TextDisplay.qml
        MultiStateButton.qml
    RESOURCE_PREFIX /
)

set_target_properties(HMIControls PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick)

target_link_libraries(HMIControls PRIVATE
    Qt6::Core
    Qt6::Qml
    Qt6::Quick
)

install(TARGETS HMIControls
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
