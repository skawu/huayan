import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: canvasOperations
    visible: false

    // Canvas zoom and pan properties
    property real canvasScale: 1.0
    property real canvasScaleMin: 0.1
    property real canvasScaleMax: 5.0
    property real canvasOffsetX: 0
    property real canvasOffsetY: 0
    property bool isPanning: false
    property int panStartX: 0
    property int panStartY: 0
    property int panOffsetX: 0
    property int panOffsetY: 0
    
    // Grid properties
    property bool showGrid: true
    property var gridLines: []
    property real gridSize: 10

    // Canvas properties
    property Item canvas: null

    // Initialize canvas operations
    function init(canvasItem) {
        canvas = canvasItem;
        setupCanvasHandlers();
        createGrid();
    }

    // Setup canvas event handlers
    function setupCanvasHandlers() {
        if (!canvas) return;

        // Create mouse area for canvas
        const canvasMouseArea = Qt.createQmlObject('import QtQuick 2.15; MouseArea { anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton; }', canvas);
        if (canvasMouseArea) {
            // Handle pan start
            canvasMouseArea.pressed.connect(function(mouse) {
                if (mouse.button === Qt.MiddleButton || mouse.button === Qt.RightButton) {
                    // Start panning
                    canvasOperations.isPanning = true;
                    canvasOperations.panStartX = mouse.x;
                    canvasOperations.panStartY = mouse.y;
                    canvasOperations.panOffsetX = canvasOperations.canvasOffsetX;
                    canvasOperations.panOffsetY = canvasOperations.canvasOffsetY;
                }
            });

            // Handle pan end
            canvasMouseArea.released.connect(function(mouse) {
                if (mouse.button === Qt.MiddleButton || mouse.button === Qt.RightButton) {
                    // End panning
                    canvasOperations.isPanning = false;
                }
            });

            // Handle pan move
            canvasMouseArea.mouseXChanged.connect(function() {
                if (canvasOperations.isPanning) {
                    // Update canvas offset during pan
                    canvasOperations.canvasOffsetX = canvasOperations.panOffsetX + (canvasMouseArea.mouseX - canvasOperations.panStartX);
                    canvasOperations.canvasOffsetY = canvasOperations.panOffsetY + (canvasMouseArea.mouseY - canvasOperations.panStartY);
                    canvasOperations.updateCanvasTransform();
                }
            });

            canvasMouseArea.mouseYChanged.connect(function() {
                if (canvasOperations.isPanning) {
                    // Update canvas offset during pan
                    canvasOperations.canvasOffsetX = canvasOperations.panOffsetX + (canvasMouseArea.mouseX - canvasOperations.panStartX);
                    canvasOperations.canvasOffsetY = canvasOperations.panOffsetY + (canvasMouseArea.mouseY - canvasOperations.panStartY);
                    canvasOperations.updateCanvasTransform();
                }
            });

            // Handle keyboard events for canvas
            canvasMouseArea.onWheel.connect(function(wheel) {
                // Zoom functionality
                const zoomFactor = wheel.angleDelta.y > 0 ? 1.1 : 0.9;
                canvasOperations.zoomCanvas(zoomFactor, wheel.x, wheel.y);
            });
        }
    }

    // Update canvas transform (scale and offset)
    function updateCanvasTransform() {
        if (!canvas) return;
        
        // Apply scale and offset to canvas
        canvas.transformOrigin = Item.TopLeft;
        canvas.scale = canvasScale;
        canvas.x = canvasOffsetX;
        canvas.y = canvasOffsetY;
    }
    
    // Zoom canvas around a point
    function zoomCanvas(factor, mouseX, mouseY) {
        if (!canvas) return;
        
        // Calculate new scale
        const newScale = Math.max(canvasScaleMin, Math.min(canvasScaleMax, canvasScale * factor));
        
        if (newScale !== canvasScale) {
            // Calculate zoom factor
            const scaleFactor = newScale / canvasScale;
            
            // Adjust offset to zoom around mouse position
            const mousePosX = mouseX - canvasOffsetX;
            const mousePosY = mouseY - canvasOffsetY;
            
            canvasOffsetX = mouseX - mousePosX * scaleFactor;
            canvasOffsetY = mouseY - mousePosY * scaleFactor;
            canvasScale = newScale;
            
            // Update canvas transform
            updateCanvasTransform();
        }
    }
    
    // Reset canvas transform
    function resetCanvasTransform() {
        canvasScale = 1.0;
        canvasOffsetX = 0;
        canvasOffsetY = 0;
        updateCanvasTransform();
    }
    
    // Fit canvas to view
    function fitCanvasToView() {
        if (!canvas) return;
        
        // Calculate bounding box of all items
        let minX = Infinity, minY = Infinity;
        let maxX = -Infinity, maxY = -Infinity;
        
        for (let i = 0; i < canvas.children.length; i++) {
            const item = canvas.children[i];
            minX = Math.min(minX, item.x);
            minY = Math.min(minY, item.y);
            maxX = Math.max(maxX, item.x + item.width);
            maxY = Math.max(maxY, item.y + item.height);
        }
        
        // If no items, reset transform
        if (minX === Infinity) {
            resetCanvasTransform();
            return;
        }
        
        // Calculate content size
        const contentWidth = maxX - minX;
        const contentHeight = maxY - minY;
        
        // Calculate container size
        const containerWidth = canvas.parent.width;
        const containerHeight = canvas.parent.height;
        
        // Calculate scale to fit
        const scaleX = (containerWidth * 0.9) / contentWidth;
        const scaleY = (containerHeight * 0.9) / contentHeight;
        const newScale = Math.min(scaleX, scaleY, canvasScaleMax);
        
        // Calculate offset to center content
        const centerX = (minX + maxX) / 2;
        const centerY = (minY + maxY) / 2;
        const containerCenterX = containerWidth / 2;
        const containerCenterY = containerHeight / 2;
        
        canvasScale = newScale;
        canvasOffsetX = containerCenterX - (centerX * newScale);
        canvasOffsetY = containerCenterY - (centerY * newScale);
        
        // Update canvas transform
        updateCanvasTransform();
    }

    // Create grid lines
    function createGrid() {
        if (!canvas || !showGrid) return;
        
        // Clear existing grid lines
        gridLines.forEach(function(line) {
            if (line) {
                line.destroy();
            }
        });
        gridLines = [];
        
        const canvasWidth = canvas.width;
        const canvasHeight = canvas.height;
        
        // Create vertical grid lines
        for (let x = 0; x <= canvasWidth; x += gridSize) {
            const line = Qt.createQmlObject('import QtQuick 2.15; Rectangle { width: 1; color: "rgba(200, 200, 200, 0.3)"; }', canvas);
            if (line) {
                line.x = x;
                line.y = 0;
                line.height = canvasHeight;
                line.z = -1;
                gridLines.push(line);
            }
        }
        
        // Create horizontal grid lines
        for (let y = 0; y <= canvasHeight; y += gridSize) {
            const line = Qt.createQmlObject('import QtQuick 2.15; Rectangle { height: 1; color: "rgba(200, 200, 200, 0.3)"; }', canvas);
            if (line) {
                line.x = 0;
                line.y = y;
                line.width = canvasWidth;
                line.z = -1;
                gridLines.push(line);
            }
        }
    }
    
    // Update grid when grid size changes
    function updateGrid() {
        createGrid();
    }
    
    // Set grid size
    function setGridSize(size) {
        if (size > 0) {
            gridSize = size;
            updateGrid();
        }
    }
    
    // Toggle grid visibility
    function toggleGridVisibility() {
        showGrid = !showGrid;
        if (showGrid) {
            createGrid();
        } else {
            // Clear grid lines
            gridLines.forEach(function(line) {
                if (line) {
                    line.destroy();
                }
            });
            gridLines = [];
        }
    }
    
    // Get grid size
    function getGridSize() {
        return gridSize;
    }
    
    // Get grid visibility
    function isGridVisible() {
        return showGrid;
    }
}
