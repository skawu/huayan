# 共享库
add_library(HuayanShared INTERFACE)

# 包含目录
target_include_directories(HuayanShared INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/components
    ${CMAKE_CURRENT_SOURCE_DIR}/models
    ${CMAKE_CURRENT_SOURCE_DIR}/themes
    ${CMAKE_CURRENT_SOURCE_DIR}/utils
)

# 链接Qt库
target_link_libraries(HuayanShared INTERFACE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Network
    Qt6::Sql
    Qt6::Charts
)
