import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: dragAndDropHelper
    visible: false

    // Drag properties
    property var draggedItem: null
    property int dragOffsetX: 0
    property int dragOffsetY: 0
    property bool isDragging: false
    property bool isResizing: false
    property string resizeHandle: ""
    property var selectedItems: []
    property real gridSize: 10

    // Component library model
    property var componentLibrary: [
        { name: "Indicator", type: "BasicComponents.Indicator", width: 50, height: 50 },
        { name: "PushButton", type: "BasicComponents.PushButton", width: 120, height: 40 },
        { name: "TextLabel", type: "BasicComponents.TextLabel", width: 200, height: 40 },
        { name: "Valve", type: "IndustrialComponents.Valve", width: 100, height: 100 },
        { name: "Tank", type: "IndustrialComponents.Tank", width: 120, height: 180 },
        { name: "Motor", type: "IndustrialComponents.Motor", width: 120, height: 120 },
        { name: "Pump", type: "IndustrialComponents.Pump", width: 120, height: 120 },
        { name: "TrendChart", type: "ChartComponents.TrendChart", width: 400, height: 300 },
        { name: "BarChart", type: "ChartComponents.BarChart", width: 400, height: 300 }
    ]

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
        const canvasMouseArea = Qt.createQmlObject('import QtQuick 2.15; MouseArea { anchors.fill: parent; hoverEnabled: true; }', canvas);
        if (canvasMouseArea) {
            // Clear selection when clicking on canvas background
            canvasMouseArea.pressed.connect(function() {
                clearSelection();
            });

            // Handle keyboard events for canvas
            canvasMouseArea.onWheel.connect(function(wheel) {
                // Zoom functionality could be implemented here
            });
        }
    }

    // Start drag from component library
    function startDragFromLibrary(componentType, mouseX, mouseY) {
        // Create new component
        const componentInfo = componentLibrary.find(item => item.type === componentType);
        if (!componentInfo || !canvas) return;

        // Create component dynamically
        const component = Qt.createQmlObject('import QtQuick 2.15; import ' + componentType.split('.')[0] + ' 1.0; ' + componentType.split('.')[1] + ' {}', canvas);
        if (component) {
            // Set initial properties
            component.width = componentInfo.width;
            component.height = componentInfo.height;
            component.x = snapToGrid(mouseX - canvas.x - component.width / 2);
            component.y = snapToGrid(mouseY - canvas.y - component.height / 2);

            // Set up drag handlers
            setupDragHandlers(component);

            // Add to canvas
            canvas.appendChild(component);

            // Select and start dragging
            selectItem(component);
            startDrag(component, mouseX, mouseY);
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
        draggedItem = null;
    }

    // Handle mouse move during drag
    function handleMouseMove(mouseX, mouseY) {
        if (!draggedItem || !canvas) return;

        if (isDragging) {
            // Calculate new position relative to canvas
            let newX = mouseX - canvas.x - dragOffsetX;
            let newY = mouseY - canvas.y - dragOffsetY;

            // Snap to grid
            newX = snapToGrid(newX);
            newY = snapToGrid(newY);

            // Update item position with bounds checking
            draggedItem.x = Math.max(0, Math.min(newX, canvas.width - draggedItem.width));
            draggedItem.y = Math.max(0, Math.min(newY, canvas.height - draggedItem.height));
        } else if (isResizing) {
            // Handle resizing
            switch (resizeHandle) {
                case "bottomRight":
                    draggedItem.width = Math.max(20, snapToGrid(mouseX - canvas.x - draggedItem.x));
                    draggedItem.height = Math.max(20, snapToGrid(mouseY - canvas.y - draggedItem.y));
                    break;
                case "bottomLeft":
                    const newWidthBL = Math.max(20, snapToGrid(draggedItem.x + draggedItem.width - (mouseX - canvas.x)));
                    draggedItem.x = Math.max(0, snapToGrid(mouseX - canvas.x));
                    draggedItem.width = newWidthBL;
                    draggedItem.height = Math.max(20, snapToGrid(mouseY - canvas.y - draggedItem.y));
                    break;
                case "topRight":
                    draggedItem.width = Math.max(20, snapToGrid(mouseX - canvas.x - draggedItem.x));
                    const newHeightTR = Math.max(20, snapToGrid(draggedItem.y + draggedItem.height - (mouseY - canvas.y)));
                    draggedItem.y = Math.max(0, snapToGrid(mouseY - canvas.y));
                    draggedItem.height = newHeightTR;
                    break;
                case "topLeft":
                    const newWidthTL = Math.max(20, snapToGrid(draggedItem.x + draggedItem.width - (mouseX - canvas.x)));
                    const newHeightTL = Math.max(20, snapToGrid(draggedItem.y + draggedItem.height - (mouseY - canvas.y)));
                    draggedItem.x = Math.max(0, snapToGrid(mouseX - canvas.x));
                    draggedItem.y = Math.max(0, snapToGrid(mouseY - canvas.y));
                    draggedItem.width = newWidthTL;
                    draggedItem.height = newHeightTL;
                    break;
                case "left":
                    const newWidthL = Math.max(20, snapToGrid(draggedItem.x + draggedItem.width - (mouseX - canvas.x)));
                    draggedItem.x = Math.max(0, snapToGrid(mouseX - canvas.x));
                    draggedItem.width = newWidthL;
                    break;
                case "right":
                    draggedItem.width = Math.max(20, snapToGrid(mouseX - canvas.x - draggedItem.x));
                    break;
                case "top":
                    const newHeightT = Math.max(20, snapToGrid(draggedItem.y + draggedItem.height - (mouseY - canvas.y)));
                    draggedItem.y = Math.max(0, snapToGrid(mouseY - canvas.y));
                    draggedItem.height = newHeightT;
                    break;
                case "bottom":
                    draggedItem.height = Math.max(20, snapToGrid(mouseY - canvas.y - draggedItem.y));
                    break;
            }
        }
    }

    // Snap value to grid
    function snapToGrid(value) {
        return Math.round(value / gridSize) * gridSize;
    }

    // Setup drag handlers for an item
    function setupDragHandlers(item) {
        // Add selection border
        addSelectionBorder(item);

        // Mouse area for dragging
        const mouseArea = Qt.createQmlObject('import QtQuick 2.15; MouseArea { anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.LeftButton | Qt.RightButton; }', item);
        if (mouseArea) {
            // Connect signals using JavaScript
            mouseArea.pressed.connect(function(mouse) {
                // Select item on left click
                if (mouse.button === Qt.LeftButton) {
                    // Check if Ctrl is pressed for multi-select
                    const multiSelect = (mouse.modifiers & Qt.ControlModifier) !== 0;
                    selectItem(item, multiSelect);
                    dragAndDropHelper.startDrag(item, mouse.x, mouse.y);
                } else if (mouse.button === Qt.RightButton) {
                    // Show context menu on right click
                    showContextMenu(item, mouse.x, mouse.y);
                }
            });
            
            mouseArea.released.connect(function() {
                dragAndDropHelper.endDrag();
            });
            
            mouseArea.mouseXChanged.connect(function() {
                if (dragAndDropHelper.isDragging || dragAndDropHelper.isResizing) {
                    dragAndDropHelper.handleMouseMove(mouseArea.mouseX, mouseArea.mouseY);
                }
            });
            
            mouseArea.mouseYChanged.connect(function() {
                if (dragAndDropHelper.isDragging || dragAndDropHelper.isResizing) {
                    dragAndDropHelper.handleMouseMove(mouseArea.mouseX, mouseArea.mouseY);
                }
            });

            // Hover effect
            mouseArea.entered.connect(function() {
                if (item.selectionBorder) {
                    item.selectionBorder.opacity = 0.5;
                }
            });

            mouseArea.exited.connect(function() {
                if (item.selectionBorder && !isItemSelected(item)) {
                    item.selectionBorder.opacity = 0;
                }
            });
        }

        // Add resize handles
        addResizeHandles(item);
    }

    // Add selection border to item
    function addSelectionBorder(item) {
        if (item.selectionBorder) return;

        item.selectionBorder = Qt.createQmlObject('import QtQuick 2.15; Rectangle { anchors.fill: parent; border.color: "#2196F3"; border.width: 2; color: "transparent"; opacity: 0; }', item);
    }

    // Add resize handles to item
    function addResizeHandles(item) {
        // Resize handle sizes
        const handleSize = 8;

        // Corner handles
        const corners = [
            { name: "bottomRight", anchor: "anchors.bottom: parent.bottom; anchors.right: parent.right;", cursor: Qt.SizeFDiagCursor },
            { name: "bottomLeft", anchor: "anchors.bottom: parent.bottom; anchors.left: parent.left;", cursor: Qt.SizeBDiagCursor },
            { name: "topRight", anchor: "anchors.top: parent.top; anchors.right: parent.right;", cursor: Qt.SizeBDiagCursor },
            { name: "topLeft", anchor: "anchors.top: parent.top; anchors.left: parent.left;", cursor: Qt.SizeFDiagCursor }
        ];

        // Edge handles
        const edges = [
            { name: "left", anchor: "anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter;", cursor: Qt.SizeHorCursor },
            { name: "right", anchor: "anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter;", cursor: Qt.SizeHorCursor },
            { name: "top", anchor: "anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter;", cursor: Qt.SizeVerCursor },
            { name: "bottom", anchor: "anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter;", cursor: Qt.SizeVerCursor }
        ];

        // Add corner handles
        corners.forEach(function(corner) {
            const handle = Qt.createQmlObject('import QtQuick 2.15; Rectangle { width: ' + handleSize + '; height: ' + handleSize + '; color: "#2196F3"; border.color: "#1976D2"; border.width: 1; ' + corner.anchor + ' anchors.margins: -' + (handleSize / 2) + '; opacity: 0; }', item);
            if (handle) {
                const handleMouseArea = Qt.createQmlObject('import QtQuick 2.15; MouseArea { anchors.fill: parent; cursorShape: ' + corner.cursor + '; }', handle);
                if (handleMouseArea) {
                    // Connect signals using JavaScript
                    handleMouseArea.pressed.connect(function() {
                        dragAndDropHelper.draggedItem = item;
                        dragAndDropHelper.isResizing = true;
                        dragAndDropHelper.resizeHandle = corner.name;
                    });
                    
                    handleMouseArea.released.connect(function() {
                        dragAndDropHelper.endDrag();
                    });
                }
            }
        });

        // Add edge handles
        edges.forEach(function(edge) {
            const handle = Qt.createQmlObject('import QtQuick 2.15; Rectangle { width: ' + handleSize + '; height: ' + handleSize + '; color: "#2196F3"; border.color: "#1976D2"; border.width: 1; ' + edge.anchor + ' anchors.margins: -' + (handleSize / 2) + '; opacity: 0; }', item);
            if (handle) {
                const handleMouseArea = Qt.createQmlObject('import QtQuick 2.15; MouseArea { anchors.fill: parent; cursorShape: ' + edge.cursor + '; }', handle);
                if (handleMouseArea) {
                    // Connect signals using JavaScript
                    handleMouseArea.pressed.connect(function() {
                        dragAndDropHelper.draggedItem = item;
                        dragAndDropHelper.isResizing = true;
                        dragAndDropHelper.resizeHandle = edge.name;
                    });
                    
                    handleMouseArea.released.connect(function() {
                        dragAndDropHelper.endDrag();
                    });
                }
            }
        });
    }

    // Select an item
    function selectItem(item, multiSelect) {
        // Clear previous selection if not multi-selecting
        if (!multiSelect) {
            clearSelection();
        }
        
        // Add to selected items if not already selected
        if (selectedItems.indexOf(item) === -1) {
            selectedItems.push(item);
        }
        
        // Show selection border and resize handles
        showItemSelection(item);
        
        // Update property panel
        updatePropertyPanel(item);
    }

    // Clear selection
    function clearSelection() {
        // Hide selection borders and resize handles
        selectedItems.forEach(function(item) {
            hideItemSelection(item);
        });
        
        // Clear selected items
        selectedItems = [];
        
        // Clear property panel
        if (propertyPanel) {
            propertyPanel.clear();
        }
    }

    // Show item selection
    function showItemSelection(item) {
        if (item.selectionBorder) {
            item.selectionBorder.opacity = 1;
        }
        
        // Show resize handles
        for (let i = 0; i < item.children.length; i++) {
            const child = item.children[i];
            if (child.color === "#2196F3") {
                child.opacity = 1;
            }
        }
    }

    // Hide item selection
    function hideItemSelection(item) {
        if (item.selectionBorder) {
            item.selectionBorder.opacity = 0;
        }
        
        // Hide resize handles
        for (let i = 0; i < item.children.length; i++) {
            const child = item.children[i];
            if (child.color === "#2196F3") {
                child.opacity = 0;
            }
        }
    }

    // Check if item is selected
    function isItemSelected(item) {
        return selectedItems.indexOf(item) !== -1;
    }

    // Show context menu
    function showContextMenu(item, x, y) {
        // Create context menu
        const menu = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; Menu { }', item);
        if (menu) {
            // Add menu items
            const deleteAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Delete" }', menu);
            if (deleteAction) {
                deleteAction.triggered.connect(function() {
                    deleteItem(item);
                });
            }

            const copyAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Copy" }', menu);
            if (copyAction) {
                copyAction.triggered.connect(function() {
                    copyItem(item);
                });
            }

            // Popup menu
            menu.popup(x, y);
        }
    }

    // Delete item
    function deleteItem(item) {
        if (item && canvas) {
            // Remove from selected items
            const index = selectedItems.indexOf(item);
            if (index !== -1) {
                selectedItems.splice(index, 1);
            }
            
            // Destroy item
            item.destroy();
            
            // Clear property panel
            if (propertyPanel) {
                propertyPanel.clear();
            }
        }
    }

    // Copy item
    function copyItem(item) {
        if (!item || !canvas) return;

        // Get item type
        const itemType = item.toString().split('QQuickItem_QML_')[1];
        if (!itemType) return;

        // Find component info
        const componentInfo = componentLibrary.find(comp => comp.type.endsWith('.' + itemType));
        if (!componentInfo) return;

        // Create new component
        const newItem = Qt.createQmlObject('import QtQuick 2.15; import ' + componentInfo.type.split('.')[0] + ' 1.0; ' + componentInfo.type.split('.')[1] + ' {}', canvas);
        if (newItem) {
            // Copy properties
            newItem.width = item.width;
            newItem.height = item.height;
            newItem.x = snapToGrid(item.x + 20);
            newItem.y = snapToGrid(item.y + 20);
            if (item.tagName) {
                newItem.tagName = item.tagName;
            }

            // Set up drag handlers
            setupDragHandlers(newItem);

            // Add to canvas
            canvas.appendChild(newItem);

            // Select new item
            selectItem(newItem);
        }
    }

    // Update property panel
    function updatePropertyPanel(item) {
        if (!propertyPanel || !item) return;

        // Update property panel with item properties
        propertyPanel.update(item);
    }

    // Save canvas layout
    function saveLayout() {
        if (!canvas) return [];

        const layout = [];
        for (let i = 0; i < canvas.children.length; i++) {
            const item = canvas.children[i];
            if (item !== draggedItem) {
                layout.push({
                    type: item.toString().split('QQuickItem_QML_')[1],
                    x: item.x,
                    y: item.y,
                    width: item.width,
                    height: item.height,
                    tagName: item.tagName || ""
                });
            }
        }
        return layout;
    }

    // Load canvas layout
    function loadLayout(layout) {
        if (!canvas) return;

        // Clear existing items
        for (let i = canvas.children.length - 1; i >= 0; i--) {
            canvas.children[i].destroy();
        }

        // Load items from layout
        for (const itemInfo of layout) {
            // Create component
            const component = Qt.createQmlObject('import QtQuick 2.15; ' + itemInfo.type + ' {}', canvas);
            if (component) {
                // Set properties
                component.x = itemInfo.x;
                component.y = itemInfo.y;
                component.width = itemInfo.width;
                component.height = itemInfo.height;
                if (itemInfo.tagName) {
                    component.tagName = itemInfo.tagName;
                }

                // Set up drag handlers
                setupDragHandlers(component);
            }
        }
    }

    // Delete all items from canvas
    function clearCanvas() {
        if (!canvas) return;

        // Clear selection
        clearSelection();

        // Delete all items
        for (let i = canvas.children.length - 1; i >= 0; i--) {
            canvas.children[i].destroy();
        }
    }

    // Align selected items
    function alignItems(alignment) {
        if (selectedItems.length < 2) return;

        const referenceItem = selectedItems[0];

        selectedItems.forEach(function(item) {
            if (item !== referenceItem) {
                switch (alignment) {
                    case "left":
                        item.x = referenceItem.x;
                        break;
                    case "right":
                        item.x = referenceItem.x + referenceItem.width - item.width;
                        break;
                    case "top":
                        item.y = referenceItem.y;
                        break;
                    case "bottom":
                        item.y = referenceItem.y + referenceItem.height - item.height;
                        break;
                    case "center":
                        item.x = referenceItem.x + (referenceItem.width - item.width) / 2;
                        break;
                    case "middle":
                        item.y = referenceItem.y + (referenceItem.height - item.height) / 2;
                        break;
                }
            }
        });
    }

    // Distribute selected items
    function distributeItems(direction) {
        if (selectedItems.length < 3) return;

        // Sort items by position
        selectedItems.sort(function(a, b) {
            return direction === "horizontal" ? a.x - b.x : a.y - b.y;
        });

        const firstItem = selectedItems[0];
        const lastItem = selectedItems[selectedItems.length - 1];
        const totalWidth = direction === "horizontal" ? lastItem.x + lastItem.width - firstItem.x : lastItem.y + lastItem.height - firstItem.y;
        const itemSize = direction === "horizontal" ? firstItem.width : firstItem.height;
        const spacing = (totalWidth - (selectedItems.length * itemSize)) / (selectedItems.length - 1);

        // Distribute items
        selectedItems.forEach(function(item, index) {
            if (direction === "horizontal") {
                item.x = firstItem.x + (index * (itemSize + spacing));
            } else {
                item.y = firstItem.y + (index * (itemSize + spacing));
            }
        });
    }
}

