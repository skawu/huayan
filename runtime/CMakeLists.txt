# 运行时应用 CMakeLists.txt
cmake_minimum_required(VERSION 3.16)

# 明确指定使用Qt自带的CMake
if(DEFINED ENV{QTDIR})
    set(CMAKE_PREFIX_PATH "$ENV{QTDIR}")
endif()

# 查找Qt6
find_package(Qt6 6.8 REQUIRED COMPONENTS
    Core
    Quick
    QuickControls2
    Network
    Sql
    Charts
)

# 启用Qt特性
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 包含目录
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../shared
)

# 运行时应用
qt_add_executable(SCADARuntime
    src/main.cpp
    ../shared/models/core/tagmanager.cpp
    ../shared/models/core/tagmanager.h
    main.qml
)

# 设置目标属性
set_target_properties(SCADARuntime PROPERTIES
    WIN32_EXECUTABLE TRUE
)

# 链接库
target_link_libraries(SCADARuntime PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Network
    Qt6::Sql
    Qt6::Charts
)

# 安装规则
install(TARGETS SCADARuntime
    RUNTIME DESTINATION bin
    BUNDLE DESTINATION .
)