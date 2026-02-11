cmake_minimum_required(VERSION 3.24)

# 钢铁厂监控平台示例
project(HYSteelPlantMonitoring VERSION 1.0 LANGUAGES CXX)

# 设置C++标准
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 跨平台编译参数
if(MSVC)
    # MSVC 2022 编译参数
    add_compile_options(/W4 /WX /MP /permissive-)
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    # GCC 11+ 编译参数
    add_compile_options(-Wall -Wextra -Werror -pedantic)
    add_compile_options(-Wno-unused-parameter -Wno-unused-variable)
endif()

# 包含Huayan核心代码路径
set(HUAYAN_CORE_DIR ${CMAKE_SOURCE_DIR}/../src)

# Qt 6标准项目设置
find_package(Qt6 6.8 REQUIRED COMPONENTS Core Quick Network SerialBus Sql Charts QuickControls2)

# 尝试查找可选的Qt组件
find_package(Qt6 COMPONENTS OpcUa QUIET)
set(HAVE_OPCUA ${Qt6OpcUa_FOUND})

find_package(Qt6 COMPONENTS Mqtt QUIET)
set(HAVE_MQTT ${Qt6Mqtt_FOUND})

qt_standard_project_setup()

# 设置QML导入路径
set(QML_IMPORT_PATH ${CMAKE_SOURCE_DIR}/../qml CACHE STRING "QML import path")

# 添加可执行文件
qt_add_executable(HYSteelPlantMonitoring
    main.cpp
    steel_plant_monitoring.qml
    resources.qrc
    steelplantmanager.cpp
    steelplantmanager.h
    simulateddatasource.cpp
    simulateddatasource.h
)

# 链接库
target_link_libraries(HYSteelPlantMonitoring PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Network
    Qt6::SerialBus
    Qt6::Sql
    Qt6::Charts
    Qt6::QuickControls2
)

# 链接可选的Qt组件
if(HAVE_OPCUA)
    target_link_libraries(HYSteelPlantMonitoring PRIVATE Qt6::OpcUa)
    target_compile_definitions(HYSteelPlantMonitoring PRIVATE HAVE_OPCUA=1)
endif()

if(HAVE_MQTT)
    target_link_libraries(HYSteelPlantMonitoring PRIVATE Qt6::Mqtt)
    target_compile_definitions(HYSteelPlantMonitoring PRIVATE HAVE_MQTT=1)
endif()

# 包含Huayan核心代码头文件路径
target_include_directories(HYSteelPlantMonitoring PRIVATE
    ${HUAYAN_CORE_DIR}
    ${HUAYAN_CORE_DIR}/core
    ${HUAYAN_CORE_DIR}/datasource
    ${HUAYAN_CORE_DIR}/communication
    ${HUAYAN_CORE_DIR}/3d
)

# 链接Huayan核心库（如果有）
# 注意：这里假设Huayan的核心库已经构建
# 如果Huayan核心库还未构建，需要先构建Huayan核心库
if(EXISTS ${CMAKE_BINARY_DIR}/../src/libHYSCADASystemQml.so)
    target_link_libraries(HYSteelPlantMonitoring PRIVATE
        ${CMAKE_BINARY_DIR}/../src/libHYSCADASystemQml.so
    )
elseif(EXISTS ${CMAKE_BINARY_DIR}/../src/Debug/HYSCADASystemQml.dll)
    target_link_libraries(HYSteelPlantMonitoring PRIVATE
        ${CMAKE_BINARY_DIR}/../src/Debug/HYSCADASystemQml.dll
    )
elseif(EXISTS ${CMAKE_BINARY_DIR}/../src/Release/HYSCADASystemQml.dll)
    target_link_libraries(HYSteelPlantMonitoring PRIVATE
        ${CMAKE_BINARY_DIR}/../src/Release/HYSCADASystemQml.dll
    )
endif()

# 设置属性
set_target_properties(HYSteelPlantMonitoring PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
)

# 安装配置
install(TARGETS HYSteelPlantMonitoring
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# 安装QML文件和资源
install(FILES steel_plant_monitoring.qml
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# 安装配置文件
install(DIRECTORY config
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# 安装仿真数据
install(DIRECTORY data
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# 安装3D模型
install(DIRECTORY models
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# 安装图标
install(DIRECTORY icons
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# 安装快速体验文档
install(FILES "钢铁厂例程快速体验.md"
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# 安装运行脚本
install(PROGRAMS run_steel_plant.sh
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(FILES run_steel_plant.bat
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

