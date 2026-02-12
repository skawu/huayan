cmake_minimum_required(VERSION 3.22)

# QML Tests
find_package(Qt6 REQUIRED COMPONENTS Test Quick)

# Alternative approach: Direct QML test runner
# If qmltestrunner is available, we can run QML tests directly
find_program(QMLTESTRUNNER qmltestrunner)
if(QMLTESTRUNNER)
    # Create individual test targets for each QML test file
    add_custom_target(MainQmlTest ALL
        COMMAND ${QMLTESTRUNNER} -input ${CMAKE_CURRENT_SOURCE_DIR}/MainQmlTest.qml
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Running MainQmlTest.qml")
    
    add_custom_target(CanvasOperationsTest ALL
        COMMAND ${QMLTESTRUNNER} -input ${CMAKE_CURRENT_SOURCE_DIR}/CanvasOperationsTest.qml
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Running CanvasOperationsTest.qml")
    
    add_custom_target(DragDropCoreTest ALL
        COMMAND ${QMLTESTRUNNER} -input ${CMAKE_CURRENT_SOURCE_DIR}/DragDropCoreTest.qml
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Running DragDropCoreTest.qml")
        
    # Register tests with CTest
    add_test(NAME MainQmlTestDirect
             COMMAND ${QMLTESTRUNNER} -input ${CMAKE_CURRENT_SOURCE_DIR}/MainQmlTest.qml
             WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
             
    add_test(NAME CanvasOperationsTestDirect
             COMMAND ${QMLTESTRUNNER} -input ${CMAKE_CURRENT_SOURCE_DIR}/CanvasOperationsTest.qml
             WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
             
    add_test(NAME DragDropCoreTestDirect
             COMMAND ${QMLTESTRUNNER} -input ${CMAKE_CURRENT_SOURCE_DIR}/DragDropCoreTest.qml
             WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
else()
    message(WARNING "qmltestrunner not found. QML tests will not be built.")
endif()