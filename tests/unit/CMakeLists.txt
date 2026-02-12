cmake_minimum_required(VERSION 3.22)

# 添加单元测试

# 标签管理器测试
add_executable(test_tagmanager test_tagmanager.cpp
    ${CMAKE_SOURCE_DIR}/src/core/tagmanager.cpp
    ${CMAKE_SOURCE_DIR}/src/core/tagmanager.h
)
target_link_libraries(test_tagmanager PRIVATE
    Qt6::Test
    Qt6::Core
    Qt6::Sql
)
target_include_directories(test_tagmanager PRIVATE
    ${CMAKE_SOURCE_DIR}/src/core
)
add_test(NAME TagManagerTest COMMAND test_tagmanager)

# 数据处理器测试
add_executable(test_dataprocessor test_dataprocessor.cpp
    ${CMAKE_SOURCE_DIR}/src/core/dataprocessor.cpp
    ${CMAKE_SOURCE_DIR}/src/core/dataprocessor.h
    ${CMAKE_SOURCE_DIR}/src/core/tagmanager.cpp
    ${CMAKE_SOURCE_DIR}/src/core/tagmanager.h
    ${CMAKE_SOURCE_DIR}/src/core/timeseriesdatabase.cpp
    ${CMAKE_SOURCE_DIR}/src/core/timeseriesdatabase.h
    ${CMAKE_SOURCE_DIR}/src/communication/hymodbustcpdriver.cpp
    ${CMAKE_SOURCE_DIR}/src/communication/hymodbustcpdriver.h
)
target_link_libraries(test_dataprocessor PRIVATE
    Qt6::Test
    Qt6::Core
    Qt6::Network
    Qt6::SerialBus
    Qt6::Sql
)
target_include_directories(test_dataprocessor PRIVATE
    ${CMAKE_SOURCE_DIR}/src/core
    ${CMAKE_SOURCE_DIR}/src/communication
)
add_test(NAME DataProcessorTest COMMAND test_dataprocessor)

# Modbus TCP驱动测试
add_executable(test_modbustcpdriver test_modbustcpdriver.cpp
    ${CMAKE_SOURCE_DIR}/src/communication/hymodbustcpdriver.cpp
    ${CMAKE_SOURCE_DIR}/src/communication/hymodbustcpdriver.h
)
target_link_libraries(test_modbustcpdriver PRIVATE
    Qt6::Test
    Qt6::Core
    Qt6::Network
    Qt6::SerialBus
)
target_include_directories(test_modbustcpdriver PRIVATE
    ${CMAKE_SOURCE_DIR}/src/communication
    ${CMAKE_SOURCE_DIR}/src/core
)
add_test(NAME ModbusTcpDriverTest COMMAND test_modbustcpdriver)

# 时间序列数据库测试
add_executable(test_timeseriesdatabase test_timeseriesdatabase.cpp
    ${CMAKE_SOURCE_DIR}/src/core/timeseriesdatabase.cpp
    ${CMAKE_SOURCE_DIR}/src/core/timeseriesdatabase.h
)
target_link_libraries(test_timeseriesdatabase PRIVATE
    Qt6::Test
    Qt6::Core
    Qt6::Sql
    Qt6::Network
)
target_include_directories(test_timeseriesdatabase PRIVATE
    ${CMAKE_SOURCE_DIR}/src/core
)
add_test(NAME TimeSeriesDatabaseTest COMMAND test_timeseriesdatabase)

# 配置管理器测试
add_executable(test_configmanager test_configmanager.cpp
    ${CMAKE_SOURCE_DIR}/src/core/configmanager.cpp
    ${CMAKE_SOURCE_DIR}/src/core/configmanager.h
)
target_link_libraries(test_configmanager PRIVATE
    Qt6::Test
    Qt6::Core
    Qt6::Network
)
target_include_directories(test_configmanager PRIVATE
    ${CMAKE_SOURCE_DIR}/src/core
)
add_test(NAME ConfigManagerTest COMMAND test_configmanager)

# 扩展管理器测试
add_executable(test_extensionmanager test_extensionmanager.cpp
    ${CMAKE_SOURCE_DIR}/src/core/extensionmanager.cpp
    ${CMAKE_SOURCE_DIR}/src/core/extensionmanager.h
)
target_link_libraries(test_extensionmanager PRIVATE
    Qt6::Test
    Qt6::Core
)
target_include_directories(test_extensionmanager PRIVATE
    ${CMAKE_SOURCE_DIR}/src/core
)
add_test(NAME ExtensionManagerTest COMMAND test_extensionmanager)
