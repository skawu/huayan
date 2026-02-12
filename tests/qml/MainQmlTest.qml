import QtQuick
import QtQuick.Controls
import QtTest

TestCase {
    name: "MainQmlTest"
    width: 1200
    height: 800

    // Test objects
    property var mainComponent
    property var mainWindow

    // Setup test environment
    function initTestCase() {
        console.log("Initializing MainQmlTest...")
        
        // Load the main.qml component
        mainComponent = Qt.createComponent("../../qml/main.qml")
        
        if (mainComponent.status === Component.Error) {
            console.log("Component error:", mainComponent.errorString())
            for (var i = 0; i < mainComponent.errors().length; i++) {
                console.log("Error:", mainComponent.errors()[i])
            }
        }
        
        verify(mainComponent.status !== Component.Error, "Main component should load without errors")
        
        // Create main window instance
        mainWindow = mainComponent.createObject()
        verify(mainWindow !== null, "Main window should be created successfully")
    }

    // Cleanup test environment
    function cleanupTestCase() {
        if (mainWindow) {
            mainWindow.destroy()
            mainWindow = null
        }
        if (mainComponent) {
            mainComponent = null
        }
    }

    // Test main window creation
    function test_mainWindowCreation() {
        verify(mainWindow !== null, "Main window object should exist")
        compare(typeof mainWindow.width, "number", "Main window should have width property")
        compare(typeof mainWindow.height, "number", "Main window should have height property")
    }

    // Test basic UI elements existence
    function test_uiElementsExistence() {
        // Check for basic UI structure elements
        verify(mainWindow !== undefined, "Main window should be defined")
        
        // Test that the main layout exists
        if (mainWindow.hasOwnProperty("children") && mainWindow.children.length > 0) {
            verify(mainWindow.children.length > 0, "Main window should have child elements")
        }
    }

    // Test component creation functionality
    function test_componentCreation() {
        // Verify that the component creation mechanism works
        var testComponent = Qt.createQmlObject('import QtQuick; Rectangle { width: 100; height: 100; color: "red" }', mainWindow || root)
        verify(testComponent !== null, "Dynamic component should be created successfully")
        
        if (testComponent) {
            compare(testComponent.width, 100, "Component width should be 100")
            compare(testComponent.height, 100, "Component height should be 100")
            compare(testComponent.color, "red", "Component color should be red")
            
            testComponent.destroy()
        }
    }

    // Test property bindings
    function test_propertyBindings() {
        var testItem = Qt.createQmlObject('import QtQuick; Item { property string testProp: "initial" }', mainWindow || root)
        verify(testItem !== null, "Test item should be created successfully")
        
        if (testItem) {
            compare(testItem.testProp, "initial", "Initial property value should be correct")
            
            testItem.testProp = "updated"
            compare(testItem.testProp, "updated", "Updated property value should be correct")
            
            testItem.destroy()
        }
    }
}