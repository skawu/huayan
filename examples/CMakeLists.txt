cmake_minimum_required(VERSION 3.22)

# 示例配置
# 这些示例展示如何使用SCADASystem项目的功能和API

# 添加API使用示例
add_executable(APIUsageExample
    api_usage_example.cpp
)

# 链接项目库
target_link_libraries(APIUsageExample PRIVATE
    SCADASystemQml
)

# 设置属性
set_target_properties(APIUsageExample PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/examples
)

# 安装配置
install(TARGETS APIUsageExample
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}/examples
)

# 安装示例文件
install(FILES
    api_usage_example.cpp
    component_usage_example.qml
    integration_example.cpp
    extension_example.cpp
    DESTINATION ${CMAKE_INSTALL_BINDIR}/examples
)
