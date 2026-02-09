# ChartComponents CMakeLists.txt

# Set Qt policy to suppress QTP0001 warning
qt_policy(SET QTP0001 NEW)

qt_add_qml_module(ChartComponents
    URI ChartComponents
    VERSION 1.0
    QML_FILES
        TrendChart.qml
        BarChart.qml
    OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/qml/plugins/ChartComponents
)

# Set plugin properties
set_target_properties(ChartComponents PROPERTIES
    QT_QML_MODULE_VERSION 1.0
    QT_QML_MODULE_URI ChartComponents
)

# Link against Qt Charts
if(TARGET Qt6::Charts)
    target_link_libraries(ChartComponents PRIVATE Qt6::Charts)
endif()

# Install configuration
install(TARGETS ChartComponents
    LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/qml/ChartComponents
)

install(FILES qmldir
    DESTINATION ${CMAKE_INSTALL_PREFIX}/qml/ChartComponents
)
