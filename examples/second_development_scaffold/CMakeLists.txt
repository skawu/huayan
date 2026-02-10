cmake_minimum_required(VERSION 3.22)

# 二次开发脚手架示例
project(SecondDevelopmentScaffold VERSION 1.0 LANGUAGES CXX)

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
qt_add_executable(SecondDevelopmentScaffold
    main.cpp
    scaffold.qml
    resources.qrc
    scaffoldmanager.cpp
    scaffoldmanager.h
    apidemo.cpp
    apidemo.h
)

# 链接库
target_link_libraries(SecondDevelopmentScaffold PRIVATE
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
    target_link_libraries(SecondDevelopmentScaffold PRIVATE Qt6::OpcUa)
    target_compile_definitions(SecondDevelopmentScaffold PRIVATE HAVE_OPCUA=1)
endif()

if(HAVE_MQTT)
    target_link_libraries(SecondDevelopmentScaffold PRIVATE Qt6::Mqtt)
    target_compile_definitions(SecondDevelopmentScaffold PRIVATE HAVE_MQTT=1)
endif()

# 包含Huayan核心代码头文件路径
target_include_directories(SecondDevelopmentScaffold PRIVATE
    ${HUAYAN_CORE_DIR}
    ${HUAYAN_CORE_DIR}/core
    ${HUAYAN_CORE_DIR}/datasource
    ${HUAYAN_CORE_DIR}/communication
    ${HUAYAN_CORE_DIR}/3d
)

# 链接Huayan核心库（如果有）
# 注意：这里假设Huayan的核心库已经构建
# 如果Huayan核心库还未构建，需要先构建Huayan核心库
if(EXISTS ${CMAKE_BINARY_DIR}/../src/libSCADASystemQml.so)
    target_link_libraries(SecondDevelopmentScaffold PRIVATE
        ${CMAKE_BINARY_DIR}/../src/libSCADASystemQml.so
    )
endif()

# 设置属性
set_target_properties(SecondDevelopmentScaffold PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
)

# 安装配置
install(TARGETS SecondDevelopmentScaffold
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# 安装QML文件和资源
install(FILES scaffold.qml
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# 安装快速上手文档
install(FILES "二次开发快速上手.md"
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)
