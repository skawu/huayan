# ThreeDComponents CMakeLists.txt

# Set Qt policy to suppress QTP0001 warning
qt_policy(SET QTP0001 NEW)

# Add QML module
qt_add_qml_module(ThreeDComponents
    URI ThreeDComponents
    VERSION 1.0
    QML_FILES
        ThreeDScene.qml
        ModelLoader.qml
        CameraController.qml
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml/plugins/ThreeDComponents
)

# Link libraries
target_link_libraries(ThreeDComponents PRIVATE
    Qt6::Core
    Qt6::Quick
)

# Set properties
set_target_properties(ThreeDComponents PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

# Install configuration
install(TARGETS ThreeDComponents
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_QMLDIR}/ThreeDComponents
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
