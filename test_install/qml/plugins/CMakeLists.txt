# QML plugins CMakeLists.txt

# Define options for optional plugin modules
option(ENABLE_CHART_COMPONENTS "Enable Chart Components plugin" OFF)
option(ENABLE_CONTROL_COMPONENTS "Enable Control Components plugin" OFF)
option(ENABLE_HMI_CONTROLS "Enable HMI Controls plugin" OFF)
option(ENABLE_THREED_COMPONENTS "Enable 3D Components plugin" OFF)

# Add subdirectories for each plugin module
add_subdirectory(BasicComponents)
add_subdirectory(IndustrialComponents)

# Conditionally add optional plugin modules
if(ENABLE_CHART_COMPONENTS AND IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/ChartComponents")
    add_subdirectory(ChartComponents)
endif()

if(ENABLE_CONTROL_COMPONENTS AND IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/ControlComponents")
    add_subdirectory(ControlComponents)
endif()

if(ENABLE_HMI_CONTROLS AND IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/HMIControls")
    add_subdirectory(HMIControls)
endif()

if(ENABLE_THREED_COMPONENTS AND IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/ThreeDComponents")
    add_subdirectory(ThreeDComponents)
endif()
