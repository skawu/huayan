cmake_minimum_required(VERSION 3.22)

# 添加单元测试

# 标签管理器测试
add_executable(test_tagmanager test_tagmanager.cpp)
target_link_libraries(test_tagmanager PRIVATE
    Qt6::Test
    Qt6::Core
    SCADASystemCore
)
target_include_directories(test_tagmanager PRIVATE
    ${CMAKE_SOURCE_DIR}/src/core
)
add_test(NAME TagManagerTest COMMAND test_tagmanager)

# 数据处理器测试
add_executable(test_dataprocessor test_dataprocessor.cpp)
target_link_libraries(test_dataprocessor PRIVATE
    Qt6::Test
    Qt6::Core
    SCADASystemCore
)
target_include_directories(test_dataprocessor PRIVATE
    ${CMAKE_SOURCE_DIR}/src/core
)
add_test(NAME DataProcessorTest COMMAND test_dataprocessor)

# Modbus TCP驱动测试
add_executable(test_modbustcpdriver test_modbustcpdriver.cpp)
target_link_libraries(test_modbustcpdriver PRIVATE
    Qt6::Test
    Qt6::Core
    Qt6::Network
    SCADASystemCommunication
)
target_include_directories(test_modbustcpdriver PRIVATE
    ${CMAKE_SOURCE_DIR}/src/communication
    ${CMAKE_SOURCE_DIR}/src/core
)
add_test(NAME ModbusTcpDriverTest COMMAND test_modbustcpdriver)

# 时间序列数据库测试
add_executable(test_timeseriesdatabase test_timeseriesdatabase.cpp)
target_link_libraries(test_timeseriesdatabase PRIVATE
    Qt6::Test
    Qt6::Core
    Qt6::Sql
    SCADASystemCore
)
target_include_directories(test_timeseriesdatabase PRIVATE
    ${CMAKE_SOURCE_DIR}/src/core
)
add_test(NAME TimeSeriesDatabaseTest COMMAND test_timeseriesdatabase)
