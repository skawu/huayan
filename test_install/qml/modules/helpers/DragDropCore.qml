import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: dragDropCore
    visible: false

    // Drag properties
    property var draggedItem: null
    property int dragOffsetX: 0
    property int dragOffsetY: 0
    property bool isDragging: false
    property bool isResizing: false
    property bool isRotating: false
    property string resizeHandle: ""
    property var selectedItems: []
    property real gridSize: 10
    property real rotationStep: 15
    property real rotationStartAngle: 0
    
    // Canvas properties
    property Item canvas: null
    property var propertyPanel: null

    // Initialize drag and drop
    function init(canvasItem) {
        canvas = canvasItem;
        setupCanvasHandlers();
    }

    // Setup canvas event handlers
    function setupCanvasHandlers() {
        if (!canvas) return;

        // Create mouse area for canvas
        const canvasMouseArea = Qt.createQmlObject('import QtQuick 2.15; MouseArea { anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton; }', canvas);
        if (canvasMouseArea) {
            // Clear selection when clicking on canvas background
            canvasMouseArea.pressed.connect(function(mouse) {
                if (mouse.button === Qt.LeftButton) {
                    clearSelection();
                }
            });
        }
    }

    // Start drag of existing item
    function startDrag(item, mouseX, mouseY) {
        draggedItem = item;
        dragOffsetX = mouseX - item.x;
        dragOffsetY = mouseY - item.y;
        isDragging = true;
        
        // Bring item to front
        if (canvas) {
            item.parent = canvas;
            item.z = canvas.children.length;
        }
    }

    // End drag
    function endDrag() {
        isDragging = false;
        isResizing = false;
        isRotating = false;
        draggedItem = null;
    }

    // Handle mouse move during drag
    function handleMouseMove(mouseX, mouseY) {
        if (!draggedItem || !canvas) return;

        // Calculate canvas offset once
        const canvasX = canvas.x;
        const canvasY = canvas.y;

        if (isDragging) {
            // Calculate new position relative to canvas
            let newX = mouseX - canvasX - dragOffsetX;
            let newY = mouseY - canvasY - dragOffsetY;

            // Snap to grid
            newX = snapToGrid(newX);
            newY = snapToGrid(newY);

            // Smart snap to other items (optimized)
            newX = optimizedSmartSnap(newX, "x", draggedItem);
            newY = optimizedSmartSnap(newY, "y", draggedItem);

            // Update item position with bounds checking
            const canvasWidth = canvas.width;
            const canvasHeight = canvas.height;
            const itemWidth = draggedItem.width;
            const itemHeight = draggedItem.height;
            
            draggedItem.x = Math.max(0, Math.min(newX, canvasWidth - itemWidth));
            draggedItem.y = Math.max(0, Math.min(newY, canvasHeight - itemHeight));

            // If multiple items are selected, move them together
            if (selectedItems.length > 1) {
                // Calculate delta once
                const deltaX = draggedItem.x - (mouseX - canvasX - dragOffsetX);
                const deltaY = draggedItem.y - (mouseY - canvasY - dragOffsetY);
                
                // Cache selected items length
                const selectedCount = selectedItems.length;
                
                // Batch update for better performance
                for (let i = 0; i < selectedCount; i++) {
                    const item = selectedItems[i];
                    if (item !== draggedItem) {
                        let itemX = item.x - deltaX;
                        let itemY = item.y - deltaY;
                        
                        // Snap to grid (skip smart snap for better performance)
                        itemX = snapToGrid(itemX);
                        itemY = snapToGrid(itemY);
                        
                        // Bounds checking
                        item.x = Math.max(0, Math.min(itemX, canvasWidth - item.width));
                        item.y = Math.max(0, Math.min(itemY, canvasHeight - item.height));
                    }
                }
            }
        } else if (isResizing) {
            // Handle resizing with optimized calculations
            const canvasX = canvas.x;
            const canvasY = canvas.y;
            const itemX = draggedItem.x;
            const itemY = draggedItem.y;
            const itemWidth = draggedItem.width;
            const itemHeight = draggedItem.height;
            
            switch (resizeHandle) {
                case "bottomRight":
                    draggedItem.width = Math.max(20, snapToGrid(mouseX - canvasX - itemX));
                    draggedItem.height = Math.max(20, snapToGrid(mouseY - canvasY - itemY));
                    break;
                case "bottomLeft":
                    const newWidthBL = Math.max(20, snapToGrid(itemX + itemWidth - (mouseX - canvasX)));
                    draggedItem.x = Math.max(0, snapToGrid(mouseX - canvasX));
                    draggedItem.width = newWidthBL;
                    draggedItem.height = Math.max(20, snapToGrid(mouseY - canvasY - itemY));
                    break;
                case "topRight":
                    draggedItem.width = Math.max(20, snapToGrid(mouseX - canvasX - itemX));
                    const newHeightTR = Math.max(20, snapToGrid(itemY + itemHeight - (mouseY - canvasY)));
                    draggedItem.y = Math.max(0, snapToGrid(mouseY - canvasY));
                    draggedItem.height = newHeightTR;
                    break;
                case "topLeft":
                    const newWidthTL = Math.max(20, snapToGrid(itemX + itemWidth - (mouseX - canvasX)));
                    const newHeightTL = Math.max(20, snapToGrid(itemY + itemHeight - (mouseY - canvasY)));
                    draggedItem.x = Math.max(0, snapToGrid(mouseX - canvasX));
                    draggedItem.y = Math.max(0, snapToGrid(mouseY - canvasY));
                    draggedItem.width = newWidthTL;
                    draggedItem.height = newHeightTL;
                    break;
                case "left":
                    const newWidthL = Math.max(20, snapToGrid(itemX + itemWidth - (mouseX - canvasX)));
                    draggedItem.x = Math.max(0, snapToGrid(mouseX - canvasX));
                    draggedItem.width = newWidthL;
                    break;
                case "right":
                    draggedItem.width = Math.max(20, snapToGrid(mouseX - canvasX - itemX));
                    break;
                case "top":
                    const newHeightT = Math.max(20, snapToGrid(itemY + itemHeight - (mouseY - canvasY)));
                    draggedItem.y = Math.max(0, snapToGrid(mouseY - canvasY));
                    draggedItem.height = newHeightT;
                    break;
                case "bottom":
                    draggedItem.height = Math.max(20, snapToGrid(mouseY - canvasY - itemY));
                    break;
            }
        } else if (isRotating) {
            // Handle rotation
            const canvasX = canvas.x;
            const canvasY = canvas.y;
            const itemCenterX = draggedItem.x + draggedItem.width / 2;
            const itemCenterY = draggedItem.y + draggedItem.height / 2;
            
            // Calculate angle from mouse position to item center
            const mouseXRelative = mouseX - canvasX;
            const mouseYRelative = mouseY - canvasY;
            const deltaX = mouseXRelative - itemCenterX;
            const deltaY = mouseYRelative - itemCenterY;
            
            // Calculate angle in degrees
            let angle = Math.atan2(deltaY, deltaX) * (180 / Math.PI);
            
            // Adjust to 0-360 range
            angle = (angle + 90 + 360) % 360;
            
            // Snap to rotation step
            angle = Math.round(angle / rotationStep) * rotationStep;
            
            // Set rotation origin to center
            draggedItem.transformOrigin = Item.Center;
            draggedItem.rotation = angle;
        }
    }

    // Snap value to grid
    function snapToGrid(value) {
        return Math.round(value / gridSize) * gridSize;
    }

    // Smart snap to other items
    function smartSnap(value, axis) {
        if (!canvas || selectedItems.length === 0) return value;
        
        const tolerance = 5; // Snap tolerance in pixels
        const item = selectedItems[0];
        
        // Check all other items on canvas
        for (let i = 0; i < canvas.children.length; i++) {
            const otherItem = canvas.children[i];
            if (otherItem !== item && otherItem !== draggedItem) {
                if (axis === "x") {
                    // Snap to left edge
                    if (Math.abs(value - otherItem.x) < tolerance) {
                        return otherItem.x;
                    }
                    // Snap to right edge
                    if (Math.abs(value - (otherItem.x + otherItem.width)) < tolerance) {
                        return otherItem.x + otherItem.width;
                    }
                    // Snap to center
                    if (Math.abs(value + item.width/2 - (otherItem.x + otherItem.width/2)) < tolerance) {
                        return otherItem.x + (otherItem.width - item.width)/2;
                    }
                } else if (axis === "y") {
                    // Snap to top edge
                    if (Math.abs(value - otherItem.y) < tolerance) {
                        return otherItem.y;
                    }
                    // Snap to bottom edge
                    if (Math.abs(value - (otherItem.y + otherItem.height)) < tolerance) {
                        return otherItem.y + otherItem.height;
                    }
                    // Snap to center
                    if (Math.abs(value + item.height/2 - (otherItem.y + otherItem.height/2)) < tolerance) {
                        return otherItem.y + (otherItem.height - item.height)/2;
                    }
                }
            }
        }
        
        return value;
    }
    
    // Optimized smart snap to other items
    function optimizedSmartSnap(value, axis, item) {
        if (!canvas) return value;
        
        const tolerance = 5; // Snap tolerance in pixels
        const itemWidth = item.width;
        const itemHeight = item.height;
        
        // Cache canvas children for faster access
        const canvasChildren = canvas.children;
        const childrenCount = canvasChildren.length;
        
        // Check only nearby items (spatial partitioning optimization)
        for (let i = 0; i < childrenCount; i++) {
            const otherItem = canvasChildren[i];
            if (otherItem !== item && otherItem !== draggedItem) {
                // Quick bounds check to skip far away items
                if (axis === "x") {
                    const otherX = otherItem.x;
                    const otherWidth = otherItem.width;
                    
                    // Skip items that are too far away
                    if (Math.abs(value - otherX) > 200 && Math.abs(value - (otherX + otherWidth)) > 200) {
                        continue;
                    }
                    
                    // Snap to left edge
                    if (Math.abs(value - otherX) < tolerance) {
                        return otherX;
                    }
                    // Snap to right edge
                    if (Math.abs(value - (otherX + otherWidth)) < tolerance) {
                        return otherX + otherWidth;
                    }
                    // Snap to center
                    if (Math.abs(value + itemWidth/2 - (otherX + otherWidth/2)) < tolerance) {
                        return otherX + (otherWidth - itemWidth)/2;
                    }
                } else if (axis === "y") {
                    const otherY = otherItem.y;
                    const otherHeight = otherItem.height;
                    
                    // Skip items that are too far away
                    if (Math.abs(value - otherY) > 200 && Math.abs(value - (otherY + otherHeight)) > 200) {
                        continue;
                    }
                    
                    // Snap to top edge
                    if (Math.abs(value - otherY) < tolerance) {
                        return otherY;
                    }
                    // Snap to bottom edge
                    if (Math.abs(value - (otherY + otherHeight)) < tolerance) {
                        return otherY + otherHeight;
                    }
                    // Snap to center
                    if (Math.abs(value + itemHeight/2 - (otherY + otherHeight/2)) < tolerance) {
                        return otherY + (otherHeight - itemHeight)/2;
                    }
                }
            }
        }
        
        return value;
    }

    // Batch update properties for selected items
    function batchUpdateProperties(properties) {
        selectedItems.forEach(function(item) {
            for (const [key, value] of Object.entries(properties)) {
                if (item.hasOwnProperty(key)) {
                    item[key] = value;
                }
            }
        });
    }
    
    // Move item up in z-order
    function moveItemUp(item) {
        if (!canvas || !item) return;
        
        const children = canvas.children;
        const currentIndex = children.indexOf(item);
        
        if (currentIndex < children.length - 1) {
            // Move item up by one position
            canvas.insertChild(children[currentIndex + 1], item);
        }
    }
    
    // Move item down in z-order
    function moveItemDown(item) {
        if (!canvas || !item) return;
        
        const children = canvas.children;
        const currentIndex = children.indexOf(item);
        
        if (currentIndex > 0) {
            // Move item down by one position
            canvas.insertChild(children[currentIndex - 1], item);
        }
    }
    
    // Move item to top of z-order
    function moveItemToTop(item) {
        if (!canvas || !item) return;
        
        // Remove and re-add to bring to top
        canvas.removeChild(item);
        canvas.appendChild(item);
    }
    
    // Move item to bottom of z-order
    function moveItemToBottom(item) {
        if (!canvas || !item) return;
        
        // Remove and insert at beginning
        canvas.removeChild(item);
        canvas.insertChild(canvas.children[0], item);
    }
    
    // Move selected items up
    function moveSelectedItemsUp() {
        selectedItems.forEach(function(item) {
            moveItemUp(item);
        });
    }
    
    // Move selected items down
    function moveSelectedItemsDown() {
        selectedItems.forEach(function(item) {
            moveItemDown(item);
        });
    }
    
    // Move selected items to top
    function moveSelectedItemsToTop() {
        selectedItems.forEach(function(item) {
            moveItemToTop(item);
        });
    }
    
    // Move selected items to bottom
    function moveSelectedItemsToBottom() {
        selectedItems.forEach(function(item) {
            moveItemToBottom(item);
        });
    }

    // Select item
    function selectItem(item) {
        if (!item) return;
        
        // Clear current selection
        clearSelection();
        
        // Add to selected items
        selectedItems.push(item);
        
        // Update property panel
        if (propertyPanel) {
            propertyPanel.currentItem = item;
        }
    }

    // Clear selection
    function clearSelection() {
        selectedItems = [];
        
        // Update property panel
        if (propertyPanel) {
            propertyPanel.currentItem = null;
        }
    }

    // Setup drag handlers for item
    function setupDragHandlers(item) {
        if (!item) return;
        
        // Create mouse area for item
        const mouseArea = Qt.createQmlObject('import QtQuick 2.15; MouseArea { anchors.fill: parent; hoverEnabled: true; }', item);
        if (mouseArea) {
            mouseArea.pressed.connect(function(mouse) {
                selectItem(item);
                startDrag(item, mouse.x + item.x, mouse.y + item.y);
            });
            
            mouseArea.released.connect(function() {
                endDrag();
            });
        }
    }
}
