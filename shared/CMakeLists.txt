# 共享组件库
add_library(HuayanShared STATIC)

# 设置库属性
set_target_properties(HuayanShared PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION 2
)

# 源文件
target_sources(HuayanShared PRIVATE
    # 主题系统
    shared/themes/IndustrialTheme.qml
    
    # 工具函数
    shared/utils/MathUtils.js
    shared/utils/StringUtils.js
    shared/utils/DateUtils.js
    
    # 基础组件
    shared/components/BaseComponent.qml
    shared/components/DraggableComponent.qml
)

# 包含目录
target_include_directories(HuayanShared PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/shared
)

# 链接Qt库
target_link_libraries(HuayanShared PUBLIC
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
)

# 安装规则
install(TARGETS HuayanShared
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(DIRECTORY shared/
    DESTINATION include/huayan
    FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp" PATTERN "*.qml"
)