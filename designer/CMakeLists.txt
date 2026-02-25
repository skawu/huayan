# 设计器应用
qt_add_executable(SCADADesigner
    designer/main.cpp
    designer/main.qml
    designer/resources.qrc
)

# 设置目标属性
set_target_properties(SCADADesigner PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

# 链接库
target_link_libraries(SCADADesigner PRIVATE
    HuayanShared
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Network
)

# 包含目录
target_include_directories(SCADADesigner PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/designer
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# 安装规则
install(TARGETS SCADADesigner
    RUNTIME DESTINATION bin
    BUNDLE DESTINATION .
)

# 安装QML文件
install(DIRECTORY designer/qml/
    DESTINATION qml/Designer
    FILES_MATCHING PATTERN "*.qml"
)