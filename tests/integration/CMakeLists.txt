cmake_minimum_required(VERSION 3.22)

# 添加集成测试

# 系统集成测试
add_executable(test_systemintegration test_systemintegration.cpp
    ${CMAKE_SOURCE_DIR}/src/core/dataprocessor.cpp
    ${CMAKE_SOURCE_DIR}/src/core/dataprocessor.h
    ${CMAKE_SOURCE_DIR}/src/core/tagmanager.cpp
    ${CMAKE_SOURCE_DIR}/src/core/tagmanager.h
    ${CMAKE_SOURCE_DIR}/src/core/timeseriesdatabase.cpp
    ${CMAKE_SOURCE_DIR}/src/core/timeseriesdatabase.h
    ${CMAKE_SOURCE_DIR}/src/communication/hymodbustcpdriver.cpp
    ${CMAKE_SOURCE_DIR}/src/communication/hymodbustcpdriver.h
)
target_link_libraries(test_systemintegration PRIVATE
    Qt6::Test
    Qt6::Core
    Qt6::Network
    Qt6::SerialBus
    Qt6::Sql
)
target_include_directories(test_systemintegration PRIVATE
    ${CMAKE_SOURCE_DIR}/src/core
    ${CMAKE_SOURCE_DIR}/src/communication
)
add_test(NAME SystemIntegrationTest COMMAND test_systemintegration)

# 通信集成测试（待实现）
# add_executable(test_communicationintegration test_communicationintegration.cpp)
# target_link_libraries(test_communicationintegration PRIVATE
#     Qt6::Test
#     Qt6::Core
#     Qt6::Network
#     SCADASystemCore
#     SCADASystemCommunication
# )
# target_include_directories(test_communicationintegration PRIVATE
#     ${CMAKE_SOURCE_DIR}/src/core
#     ${CMAKE_SOURCE_DIR}/src/communication
# )
# add_test(NAME CommunicationIntegrationTest COMMAND test_communicationintegration)
