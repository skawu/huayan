# 运行时应用
qt_add_executable(SCADARuntime
    runtime/main.cpp
    runtime/main.qml
    runtime/resources.qrc
)

# 设置目标属性
set_target_properties(SCADARuntime PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

# 链接库
target_link_libraries(SCADARuntime PRIVATE
    HuayanShared
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Network
    Qt6::Sql
    Qt6::Charts
)

# 包含目录
target_include_directories(SCADARuntime PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/runtime
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# 安装规则
install(TARGETS SCADARuntime
    RUNTIME DESTINATION bin
    BUNDLE DESTINATION .
)

# 安装QML文件
install(DIRECTORY runtime/qml/
    DESTINATION qml/Runtime
    FILES_MATCHING PATTERN "*.qml"
)