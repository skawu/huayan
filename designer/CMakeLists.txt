# 设计器应用 CMakeLists.txt
cmake_minimum_required(VERSION 3.16)

# 明确指定使用Qt自带的CMake
if(DEFINED ENV{QTDIR})
    set(CMAKE_PREFIX_PATH "$ENV{QTDIR}")
endif()

# 查找Qt6
find_package(Qt6 6.8 REQUIRED COMPONENTS
    Core Quick QuickControls2 Network
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

# 设计器应用
qt_add_executable(SCADADesigner
    src/main.cpp
    ../shared/models/core/tagmanager.cpp
    ../shared/models/core/tagmanager.h
    main.qml
)

set_target_properties(SCADADesigner PROPERTIES
    WIN32_EXECUTABLE TRUE
)

# 链接库
target_link_libraries(SCADADesigner PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Network
)

# 修复安装路径 - 直接安装到bin目录，而不是bin/bin
install(TARGETS SCADADesigner 
    RUNTIME DESTINATION .
    BUNDLE DESTINATION .
)