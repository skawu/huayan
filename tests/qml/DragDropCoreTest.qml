import QtQuick
import QtQuick.Controls
import QtTest
import "../../qml/modules/helpers"

TestCase {
    name: "DragDropCoreTest"
    width: 800
    height: 600

    // Test objects
    property var dragDropCore
    property var testCanvas
    property var testItem

    // Setup test environment
    function initTestCase() {
        // Create test canvas
        testCanvas = Qt.createQmlObject('import QtQuick 2.15; Item { width: 800; height: 600; }', root);
        
        // Create drag drop core
        dragDropCore = Qt.createQmlObject('import QtQuick 2.15; import "../../qml/modules/helpers"; DragDropCore { }', root);
        dragDropCore.init(testCanvas);
    }

    // Cleanup test environment
    function cleanupTestCase() {
        if (testCanvas) testCanvas.destroy();
        if (dragDropCore) dragDropCore.destroy();
        if (testItem) testItem.destroy();
    }

    // Test initialization
    function test_init() {
        verify(dragDropCore !== null, "DragDropCore should be initialized");
        verify(dragDropCore.canvas === testCanvas, "Canvas should be set");
    }

    // Test item creation and selection
    function test_selectItem() {
        // Create test item
        testItem = Qt.createQmlObject('import QtQuick 2.15; Rectangle { width: 100; height: 100; color: "red"; }', testCanvas);
        
        // Select item
        dragDropCore.selectItem(testItem);
        
        // Verify selection
        compare(dragDropCore.selectedItems.length, 1, "Should have one selected item");
        compare(dragDropCore.selectedItems[0], testItem, "Selected item should be the test item");
    }

    // Test clear selection
    function test_clearSelection() {
        // Create test item and select it
        testItem = Qt.createQmlObject('import QtQuick 2.15; Rectangle { width: 100; height: 100; color: "red"; }', testCanvas);
        dragDropCore.selectItem(testItem);
        
        // Clear selection
        dragDropCore.clearSelection();
        
        // Verify selection is cleared
        compare(dragDropCore.selectedItems.length, 0, "Selection should be cleared");
    }

    // Test snap to grid
    function test_snapToGrid() {
        // Set grid size
        dragDropCore.gridSize = 10;
        
        // Test snap to grid
        compare(dragDropCore.snapToGrid(13), 10, "13 should snap to 10");
        compare(dragDropCore.snapToGrid(15), 20, "15 should snap to 20");
        compare(dragDropCore.snapToGrid(27), 30, "27 should snap to 30");
    }

    // Test move item up
    function test_moveItemUp() {
        // Create test items
        const item1 = Qt.createQmlObject('import QtQuick 2.15; Rectangle { width: 50; height: 50; color: "red"; }', testCanvas);
        const item2 = Qt.createQmlObject('import QtQuick 2.15; Rectangle { width: 50; height: 50; color: "blue"; }', testCanvas);
        
        // Move item1 up
        dragDropCore.moveItemUp(item1);
        
        // Verify item1 is above item2
        compare(testCanvas.children.indexOf(item1), 1, "Item1 should be above item2");
        compare(testCanvas.children.indexOf(item2), 0, "Item2 should be below item1");
        
        // Cleanup
        item1.destroy();
        item2.destroy();
    }

    // Test move item to top
    function test_moveItemToTop() {
        // Create test items
        const item1 = Qt.createQmlObject('import QtQuick 2.15; Rectangle { width: 50; height: 50; color: "red"; }', testCanvas);
        const item2 = Qt.createQmlObject('import QtQuick 2.15; Rectangle { width: 50; height: 50; color: "blue"; }', testCanvas);
        const item3 = Qt.createQmlObject('import QtQuick 2.15; Rectangle { width: 50; height: 50; color: "green"; }', testCanvas);
        
        // Move item1 to top
        dragDropCore.moveItemToTop(item1);
        
        // Verify item1 is at the top
        compare(testCanvas.children.indexOf(item1), 2, "Item1 should be at the top");
        
        // Cleanup
        item1.destroy();
        item2.destroy();
        item3.destroy();
    }

    // Test batch update properties
    function test_batchUpdateProperties() {
        // Create test items
        const item1 = Qt.createQmlObject('import QtQuick 2.15; Rectangle { width: 50; height: 50; color: "red"; opacity: 1.0; }', testCanvas);
        const item2 = Qt.createQmlObject('import QtQuick 2.15; Rectangle { width: 50; height: 50; color: "blue"; opacity: 1.0; }', testCanvas);
        
        // Select both items
        dragDropCore.selectedItems = [item1, item2];
        
        // Batch update properties
        dragDropCore.batchUpdateProperties({ opacity: 0.5 });
        
        // Verify properties are updated
        compare(item1.opacity, 0.5, "Item1 opacity should be updated");
        compare(item2.opacity, 0.5, "Item2 opacity should be updated");
        
        // Cleanup
        item1.destroy();
        item2.destroy();
    }

    // Test optimized smart snap
    function test_optimizedSmartSnap() {
        // Set grid size
        dragDropCore.gridSize = 10;
        
        // Create reference item
        const refItem = Qt.createQmlObject('import QtQuick 2.15; Rectangle { x: 100; y: 100; width: 100; height: 100; color: "red"; }', testCanvas);
        
        // Create test item
        testItem = Qt.createQmlObject('import QtQuick 2.15; Rectangle { width: 100; height: 100; color: "blue"; }', testCanvas);
        
        // Test snap to left edge
        const snapX = dragDropCore.optimizedSmartSnap(105, "x", testItem);
        compare(snapX, 100, "Should snap to left edge of reference item");
        
        // Test snap to top edge
        const snapY = dragDropCore.optimizedSmartSnap(105, "y", testItem);
        compare(snapY, 100, "Should snap to top edge of reference item");
        
        // Cleanup
        refItem.destroy();
    }
}
