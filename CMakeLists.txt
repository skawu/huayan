cmake_minimum_required(VERSION 3.22)
project(HuayanSCADA VERSION 2.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Qt配置
find_package(Qt6 6.8 REQUIRED COMPONENTS
    Core Quick QuickControls2 Network Sql Charts
)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 设置输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# 包含目录
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/shared)

# 添加子目录
add_subdirectory(shared)
add_subdirectory(designer)
add_subdirectory(runtime)
