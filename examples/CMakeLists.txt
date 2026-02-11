cmake_minimum_required(VERSION 3.24)

# 示例配置
# 这些示例展示如何使用华颜工业SCADA系统项目的功能和API

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

# 查找Qt依赖
find_package(Qt6 6.8 REQUIRED COMPONENTS
    Core
    Network
    Qml
)

# 添加API使用示例
add_executable(APIUsageExample
    api_usage_example.cpp
)

# 链接项目库
target_link_libraries(APIUsageExample PRIVATE
    Qt6::Core
    Qt6::Network
    HYSCADASystemQml
)

# 包含头文件目录
target_include_directories(APIUsageExample PRIVATE
    ${CMAKE_SOURCE_DIR}/src/core
    ${CMAKE_SOURCE_DIR}/src/datasource
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
    BasicComponentsExample.qml
    IndustrialComponentsExample.qml
    MainExample.qml
    ThreeDComponentsExample.qml
    WaterTreatmentSystemExample.qml
    DESTINATION ${CMAKE_INSTALL_BINDIR}/examples
)

# 安装钢铁厂监控示例
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/steel_plant_monitoring)
    install(DIRECTORY
        steel_plant_monitoring
        DESTINATION ${CMAKE_INSTALL_BINDIR}/examples
        PATTERN "build" EXCLUDE
    )
endif()

# 安装二次开发脚手架
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/second_development_scaffold)
    install(DIRECTORY
        second_development_scaffold
        DESTINATION ${CMAKE_INSTALL_BINDIR}/examples
    )
endif()
