cmake_minimum_required(VERSION 3.22)

# QML Tests
find_package(Qt6 REQUIRED COMPONENTS Test Quick)

# Test for main.qml
add_executable(tst_mainqmltest mainqmltest.cpp)
qt_add_qml_module(tst_mainqmltest
    URI tst_mainqmltest
    VERSION 1.0
    QML_FILES
        MainQmlTest.qml
        CanvasOperationsTest.qml
        DragDropCoreTest.qml
)

target_link_libraries(tst_mainqmltest PRIVATE
    Qt6::Test
    Qt6::Quick
)

# Register the test
add_test(NAME MainQmlTest COMMAND tst_mainqmltest)
set_tests_properties(MainQmlTest PROPERTIES TIMEOUT 60)

# Alternative approach: Direct QML test runner
# If qmltestrunner is available, we can run QML tests directly
find_program(QMLTESTRUNNER qmltestrunner)
if(QMLTESTRUNNER)
    add_test(NAME MainQmlTestDirect
             COMMAND ${QMLTESTRUNNER} -input ${CMAKE_CURRENT_SOURCE_DIR}/MainQmlTest.qml)
endif()