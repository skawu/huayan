cmake_minimum_required(VERSION 3.22)

project(SCADASystemTests LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Test Core)

# 启用测试
enable_testing()

# 添加单元测试
add_subdirectory(unit)

# 添加集成测试
add_subdirectory(integration)

# 添加QML测试
add_subdirectory(qml)
