import QtQuick
import QtQuick.Controls
import QtTest
import "../../qml/modules/helpers"

TestCase {
    name: "CanvasOperationsTest"
    width: 800
    height: 600

    // Test objects
    property var canvasOperations
    property var testCanvas

    // Setup test environment
    function initTestCase() {
        // Create test canvas
        testCanvas = Qt.createQmlObject('import QtQuick 2.15; Item { width: 800; height: 600; }', root);
        
        // Create canvas operations
        canvasOperations = Qt.createQmlObject('import QtQuick 2.15; import "../../qml/modules/helpers"; CanvasOperations { }', root);
        canvasOperations.init(testCanvas);
    }

    // Cleanup test environment
    function cleanupTestCase() {
        if (testCanvas) testCanvas.destroy();
        if (canvasOperations) canvasOperations.destroy();
    }

    // Test initialization
    function test_init() {
        verify(canvasOperations !== null, "CanvasOperations should be initialized");
        verify(canvasOperations.canvas === testCanvas, "Canvas should be set");
    }

    // Test zoom canvas
    function test_zoomCanvas() {
        // Get initial scale
        const initialScale = canvasOperations.canvasScale;
        
        // Zoom in
        canvasOperations.zoomCanvas(1.1, 400, 300);
        
        // Verify scale increased
        verify(canvasOperations.canvasScale > initialScale, "Scale should increase after zooming in");
        
        // Zoom out
        const zoomedInScale = canvasOperations.canvasScale;
        canvasOperations.zoomCanvas(0.9, 400, 300);
        
        // Verify scale decreased
        verify(canvasOperations.canvasScale < zoomedInScale, "Scale should decrease after zooming out");
    }

    // Test reset canvas transform
    function test_resetCanvasTransform() {
        // Zoom in and pan
        canvasOperations.zoomCanvas(1.5, 400, 300);
        canvasOperations.canvasOffsetX = 100;
        canvasOperations.canvasOffsetY = 100;
        canvasOperations.updateCanvasTransform();
        
        // Reset transform
        canvasOperations.resetCanvasTransform();
        
        // Verify transform is reset
        compare(canvasOperations.canvasScale, 1.0, "Scale should be reset to 1.0");
        compare(canvasOperations.canvasOffsetX, 0, "OffsetX should be reset to 0");
        compare(canvasOperations.canvasOffsetY, 0, "OffsetY should be reset to 0");
    }

    // Test fit canvas to view
    function test_fitCanvasToView() {
        // Create test items
        const item1 = Qt.createQmlObject('import QtQuick 2.15; Rectangle { x: 100; y: 100; width: 100; height: 100; color: "red"; }', testCanvas);
        const item2 = Qt.createQmlObject('import QtQuick 2.15; Rectangle { x: 600; y: 400; width: 100; height: 100; color: "blue"; }', testCanvas);
        
        // Fit canvas to view
        canvasOperations.fitCanvasToView();
        
        // Verify canvas is scaled appropriately
        verify(canvasOperations.canvasScale > 0, "Scale should be positive");
        verify(canvasOperations.canvasScale <= 1.0, "Scale should be <= 1.0 to fit all items");
        
        // Cleanup
        item1.destroy();
        item2.destroy();
    }

    // Test grid operations
    function test_gridOperations() {
        // Test grid size
        canvasOperations.setGridSize(20);
        compare(canvasOperations.gridSize, 20, "Grid size should be set to 20");
        
        // Test grid visibility
        const initialGridVisible = canvasOperations.showGrid;
        canvasOperations.toggleGridVisibility();
        compare(canvasOperations.showGrid, !initialGridVisible, "Grid visibility should toggle");
        
        // Toggle back
        canvasOperations.toggleGridVisibility();
        compare(canvasOperations.showGrid, initialGridVisible, "Grid visibility should toggle back");
    }

    // Test getters
    function test_getters() {
        // Test get grid size
        canvasOperations.setGridSize(15);
        compare(canvasOperations.getGridSize(), 15, "getGridSize should return current grid size");
        
        // Test get grid visibility
        const gridVisible = canvasOperations.showGrid;
        compare(canvasOperations.isGridVisible(), gridVisible, "isGridVisible should return current grid visibility");
    }

    // Test canvas offset
    function test_canvasOffset() {
        // Set offset
        canvasOperations.canvasOffsetX = 50;
        canvasOperations.canvasOffsetY = 30;
        canvasOperations.updateCanvasTransform();
        
        // Verify offset is applied
        compare(testCanvas.x, 50, "Canvas x should be set to offsetX");
        compare(testCanvas.y, 30, "Canvas y should be set to offsetY");
    }
}
