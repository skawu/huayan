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
    property bool isRotating: false
    property string resizeHandle: ""
    property var selectedItems: []
    property real gridSize: 10
    property real rotationStep: 15
    property real rotationStartAngle: 0
    
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
    
    // Visual feedback properties
    property var dragPreview: null
    property var alignmentGuides: []
    property bool showAlignmentGuides: true
    property bool showGrid: true
    property var gridLines: []

    // Component library model with categories
    property var componentLibrary: [
        { name: "Indicator", type: "BasicComponents.Indicator", width: 50, height: 50, category: "Basic" },
        { name: "PushButton", type: "BasicComponents.PushButton", width: 120, height: 40, category: "Basic" },
        { name: "TextLabel", type: "BasicComponents.TextLabel", width: 200, height: 40, category: "Basic" },
        { name: "Valve", type: "IndustrialComponents.Valve", width: 100, height: 100, category: "Industrial" },
        { name: "Tank", type: "IndustrialComponents.Tank", width: 120, height: 180, category: "Industrial" },
        { name: "Motor", type: "IndustrialComponents.Motor", width: 120, height: 120, category: "Industrial" },
        { name: "Pump", type: "IndustrialComponents.Pump", width: 120, height: 120, category: "Industrial" },
        { name: "Gauge", type: "IndustrialComponents.Gauge", width: 200, height: 200, category: "Industrial" },
        { name: "IndustrialButton", type: "IndustrialComponents.IndustrialButton", width: 120, height: 60, category: "Industrial" },
        { name: "IndustrialIndicator", type: "IndustrialComponents.IndustrialIndicator", width: 60, height: 60, category: "Industrial" },
        { name: "TrendChart", type: "ChartComponents.TrendChart", width: 400, height: 300, category: "Charts" },
        { name: "BarChart", type: "ChartComponents.BarChart", width: 400, height: 300, category: "Charts" },
        { name: "Slider", type: "ControlComponents.Slider", width: 200, height: 60, category: "Controls" },
        { name: "Knob", type: "ControlComponents.Knob", width: 120, height: 150, category: "Controls" },
        { name: "ThreeDScene", type: "ThreeDComponents.ThreeDScene", width: 400, height: 300, category: "3D" },
        { name: "ModelLoader", type: "ThreeDComponents.ModelLoader", width: 400, height: 300, category: "3D" },
        { name: "CameraController", type: "ThreeDComponents.CameraController", width: 400, height: 300, category: "3D" }
    ]
    
    // Layout templates for common industrial interfaces
    property var layoutTemplates: [
        {
            name: "Basic Control Panel",
            description: "Simple control panel with indicators and buttons",
            items: [
                { type: "BasicComponents.TextLabel", x: 20, y: 20, width: 200, height: 40, text: "Control Panel" },
                { type: "IndustrialComponents.Indicator", x: 50, y: 80, width: 60, height: 60, tagName: "status1" },
                { type: "BasicComponents.TextLabel", x: 120, y: 80, width: 100, height: 40, text: "Status 1" },
                { type: "IndustrialComponents.Indicator", x: 50, y: 160, width: 60, height: 60, tagName: "status2" },
                { type: "BasicComponents.TextLabel", x: 120, y: 160, width: 100, height: 40, text: "Status 2" },
                { type: "IndustrialComponents.IndustrialButton", x: 50, y: 240, width: 120, height: 60, text: "Start", tagName: "startBtn" },
                { type: "IndustrialComponents.IndustrialButton", x: 190, y: 240, width: 120, height: 60, text: "Stop", tagName: "stopBtn" }
            ]
        },
        {
            name: "Process Monitoring",
            description: "Process monitoring dashboard with gauges and charts",
            items: [
                { type: "BasicComponents.TextLabel", x: 20, y: 20, width: 200, height: 40, text: "Process Monitoring" },
                { type: "IndustrialComponents.Gauge", x: 50, y: 80, width: 200, height: 200, tagName: "pressure" },
                { type: "BasicComponents.TextLabel", x: 100, y: 300, width: 100, height: 40, text: "Pressure" },
                { type: "IndustrialComponents.Gauge", x: 280, y: 80, width: 200, height: 200, tagName: "temperature" },
                { type: "BasicComponents.TextLabel", x: 330, y: 300, width: 100, height: 40, text: "Temperature" },
                { type: "ChartComponents.TrendChart", x: 50, y: 360, width: 430, height: 300, tagName: "trendData" }
            ]
        },
        {
            name: "Industrial Automation",
            description: "Industrial automation layout with pumps, valves and tanks",
            items: [
                { type: "BasicComponents.TextLabel", x: 20, y: 20, width: 200, height: 40, text: "Industrial Automation" },
                { type: "IndustrialComponents.Tank", x: 50, y: 80, width: 120, height: 180, tagName: "tank1" },
                { type: "BasicComponents.TextLabel", x: 80, y: 270, width: 80, height: 40, text: "Tank 1" },
                { type: "IndustrialComponents.Pump", x: 200, y: 120, width: 120, height: 120, tagName: "pump1" },
                { type: "BasicComponents.TextLabel", x: 220, y: 250, width: 80, height: 40, text: "Pump 1" },
                { type: "IndustrialComponents.Valve", x: 350, y: 120, width: 100, height: 100, tagName: "valve1" },
                { type: "BasicComponents.TextLabel", x: 360, y: 230, width: 80, height: 40, text: "Valve 1" },
                { type: "IndustrialComponents.Tank", x: 480, y: 80, width: 120, height: 180, tagName: "tank2" },
                { type: "BasicComponents.TextLabel", x: 510, y: 270, width: 80, height: 40, text: "Tank 2" }
            ]
        },
        {
            name: "Energy Management",
            description: "Energy management dashboard with consumption charts",
            items: [
                { type: "BasicComponents.TextLabel", x: 20, y: 20, width: 200, height: 40, text: "Energy Management" },
                { type: "ChartComponents.BarChart", x: 50, y: 80, width: 400, height: 300, tagName: "energyConsumption" },
                { type: "BasicComponents.TextLabel", x: 50, y: 400, width: 150, height: 40, text: "Consumption" },
                { type: "IndustrialComponents.Indicator", x: 100, y: 460, width: 60, height: 60, tagName: "powerStatus" },
                { type: "BasicComponents.TextLabel", x: 170, y: 460, width: 100, height: 40, text: "Power Status" },
                { type: "ChartComponents.TrendChart", x: 50, y: 520, width: 400, height: 300, tagName: "powerTrend" },
                { type: "BasicComponents.TextLabel", x: 50, y: 830, width: 150, height: 40, text: "Power Trend" }
            ]
        }
    ]

    // Canvas properties
    property Item canvas: null
    property var propertyPanel: null
    
    // Multi-page properties
    property var pages: []
    property int currentPageIndex: -1
    property string currentPageName: ""
    
    // Version control properties
    property var versionHistory: []
    property int maxVersionHistory: 50
    property int currentVersionIndex: -1
    
    // Theme properties
    property var themes: [
        {
            name: "Default",
            description: "Default industrial theme",
            colors: {
                primary: "#2196F3",
                secondary: "#FF9800",
                background: "#FFFFFF",
                text: "#000000",
                border: "#E0E0E0",
                selection: "#E3F2FD",
                success: "#4CAF50",
                warning: "#FFC107",
                error: "#F44336",
                info: "#2196F3"
            },
            fonts: {
                family: "Arial",
                size: 14,
                weight: "normal"
            }
        },
        {
            name: "Dark",
            description: "Dark theme for low-light environments",
            colors: {
                primary: "#2196F3",
                secondary: "#FF9800",
                background: "#121212",
                text: "#FFFFFF",
                border: "#333333",
                selection: "#1E3A5F",
                success: "#4CAF50",
                warning: "#FFC107",
                error: "#F44336",
                info: "#2196F3"
            },
            fonts: {
                family: "Arial",
                size: 14,
                weight: "normal"
            }
        },
        {
            name: "High Contrast",
            description: "High contrast theme for better visibility",
            colors: {
                primary: "#0000FF",
                secondary: "#FF0000",
                background: "#FFFFFF",
                text: "#000000",
                border: "#000000",
                selection: "#FFFF00",
                success: "#008000",
                warning: "#FFA500",
                error: "#FF0000",
                info: "#0000FF"
            },
            fonts: {
                family: "Arial",
                size: 16,
                weight: "bold"
            }
        }
    ]
    property string currentTheme: "Default"
    
    // Project templates
    property var projectTemplates: [
        {
            name: "Empty Project",
            description: "Blank project with no pre-defined components",
            pages: [
                {
                    name: "Main Page",
                    layout: []
                }
            ],
            theme: "Default"
        },
        {
            name: "Control Room Dashboard",
            description: "Complete control room dashboard with multiple pages",
            pages: [
                {
                    name: "Main Overview",
                    layout: [
                        { type: "BasicComponents.TextLabel", x: 20, y: 20, width: 200, height: 40, text: "Control Room Dashboard" },
                        { type: "ChartComponents.TrendChart", x: 50, y: 80, width: 400, height: 300, tagName: "mainTrend" },
                        { type: "IndustrialComponents.Gauge", x: 480, y: 80, width: 200, height: 200, tagName: "pressure" },
                        { type: "IndustrialComponents.Gauge", x: 480, y: 300, width: 200, height: 200, tagName: "temperature" }
                    ]
                },
                {
                    name: "Process Control",
                    layout: [
                        { type: "BasicComponents.TextLabel", x: 20, y: 20, width: 200, height: 40, text: "Process Control" },
                        { type: "IndustrialComponents.Tank", x: 50, y: 80, width: 120, height: 180, tagName: "tank1" },
                        { type: "IndustrialComponents.Pump", x: 200, y: 120, width: 120, height: 120, tagName: "pump1" },
                        { type: "IndustrialComponents.Valve", x: 350, y: 120, width: 100, height: 100, tagName: "valve1" },
                        { type: "IndustrialComponents.IndustrialButton", x: 50, y: 280, width: 120, height: 60, text: "Start", tagName: "startBtn" },
                        { type: "IndustrialComponents.IndustrialButton", x: 190, y: 280, width: 120, height: 60, text: "Stop", tagName: "stopBtn" }
                    ]
                },
                {
                    name: "Alarm Monitoring",
                    layout: [
                        { type: "BasicComponents.TextLabel", x: 20, y: 20, width: 200, height: 40, text: "Alarm Monitoring" },
                        { type: "IndustrialComponents.Indicator", x: 50, y: 80, width: 60, height: 60, tagName: "alarm1" },
                        { type: "BasicComponents.TextLabel", x: 120, y: 80, width: 200, height: 40, text: "High Pressure" },
                        { type: "IndustrialComponents.Indicator", x: 50, y: 160, width: 60, height: 60, tagName: "alarm2" },
                        { type: "BasicComponents.TextLabel", x: 120, y: 160, width: 200, height: 40, text: "High Temperature" },
                        { type: "IndustrialComponents.Indicator", x: 50, y: 240, width: 60, height: 60, tagName: "alarm3" },
                        { type: "BasicComponents.TextLabel", x: 120, y: 240, width: 200, height: 40, text: "Low Level" }
                    ]
                }
            ],
            theme: "Default"
        },
        {
            name: "Energy Management System",
            description: "Energy management system with consumption tracking",
            pages: [
                {
                    name: "Energy Dashboard",
                    layout: [
                        { type: "BasicComponents.TextLabel", x: 20, y: 20, width: 200, height: 40, text: "Energy Management" },
                        { type: "ChartComponents.BarChart", x: 50, y: 80, width: 400, height: 300, tagName: "energyConsumption" },
                        { type: "IndustrialComponents.Indicator", x: 480, y: 80, width: 60, height: 60, tagName: "powerStatus" },
                        { type: "BasicComponents.TextLabel", x: 550, y: 80, width: 100, height: 40, text: "Power Status" },
                        { type: "ChartComponents.TrendChart", x: 50, y: 400, width: 550, height: 300, tagName: "powerTrend" }
                    ]
                }
            ],
            theme: "Default"
        }
    ]

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
                } else if (mouse.button === Qt.MiddleButton || mouse.button === Qt.RightButton) {
                    // Start panning
                    dragAndDropHelper.isPanning = true;
                    dragAndDropHelper.panStartX = mouse.x;
                    dragAndDropHelper.panStartY = mouse.y;
                    dragAndDropHelper.panOffsetX = dragAndDropHelper.canvasOffsetX;
                    dragAndDropHelper.panOffsetY = dragAndDropHelper.canvasOffsetY;
                }
            });

            canvasMouseArea.released.connect(function(mouse) {
                if (mouse.button === Qt.MiddleButton || mouse.button === Qt.RightButton) {
                    // End panning
                    dragAndDropHelper.isPanning = false;
                }
            });

            canvasMouseArea.mouseXChanged.connect(function() {
                if (dragAndDropHelper.isPanning) {
                    // Update canvas offset during pan
                    dragAndDropHelper.canvasOffsetX = dragAndDropHelper.panOffsetX + (canvasMouseArea.mouseX - dragAndDropHelper.panStartX);
                    dragAndDropHelper.canvasOffsetY = dragAndDropHelper.panOffsetY + (canvasMouseArea.mouseY - dragAndDropHelper.panStartY);
                    dragAndDropHelper.updateCanvasTransform();
                }
            });

            canvasMouseArea.mouseYChanged.connect(function() {
                if (dragAndDropHelper.isPanning) {
                    // Update canvas offset during pan
                    dragAndDropHelper.canvasOffsetX = dragAndDropHelper.panOffsetX + (canvasMouseArea.mouseX - dragAndDropHelper.panStartX);
                    dragAndDropHelper.canvasOffsetY = dragAndDropHelper.panOffsetY + (canvasMouseArea.mouseY - dragAndDropHelper.panStartY);
                    dragAndDropHelper.updateCanvasTransform();
                }
            });

            // Handle keyboard events for canvas
            canvasMouseArea.onWheel.connect(function(wheel) {
                // Zoom functionality
                const zoomFactor = wheel.angleDelta.y > 0 ? 1.1 : 0.9;
                dragAndDropHelper.zoomCanvas(zoomFactor, wheel.x, wheel.y);
            });
        }
    }

    // Start drag from component library
    function startDragFromLibrary(componentType, mouseX, mouseY) {
        // Create new component
        const componentInfo = componentLibrary.find(item => item.type === componentType);
        if (!componentInfo || !canvas) return;

        // Create component dynamically with lazy loading
        const component = createComponentWithLazyLoading(componentType, componentInfo, mouseX, mouseY);
        if (component) {
            // Set up drag handlers
            setupDragHandlers(component);

            // Add to canvas
            canvas.appendChild(component);

            // Select and start dragging
            selectItem(component);
            startDrag(component, mouseX, mouseY);
        }
    }
    
    // Create component with lazy loading
    function createComponentWithLazyLoading(componentType, componentInfo, mouseX, mouseY) {
        if (!canvas) return null;
        
        // Create a placeholder item first
        const placeholder = Qt.createQmlObject('import QtQuick 2.15; Item { }', canvas);
        if (!placeholder) return null;
        
        // Set initial properties
        placeholder.width = componentInfo.width;
        placeholder.height = componentInfo.height;
        placeholder.x = snapToGrid(mouseX - canvas.x - componentInfo.width / 2);
        placeholder.y = snapToGrid(mouseY - canvas.y - componentInfo.height / 2);
        
        // Create loader for lazy loading
        const loader = Qt.createQmlObject('import QtQuick 2.15; Loader { anchors.fill: parent; asynchronous: true; }', placeholder);
        if (loader) {
            // Set source component
            const [importName, componentName] = componentType.split('.');
            loader.sourceComponent = Qt.createQmlObject('import QtQuick 2.15; import ' + importName + ' 1.0; Component { ' + componentName + ' {} }', placeholder);
            
            // When component is loaded, transfer properties and remove placeholder
            loader.onLoaded.connect(function() {
                const actualComponent = loader.item;
                if (actualComponent) {
                    // Transfer properties to actual component
                    actualComponent.width = placeholder.width;
                    actualComponent.height = placeholder.height;
                    actualComponent.x = placeholder.x;
                    actualComponent.y = placeholder.y;
                    
                    // Set up drag handlers for actual component
                    setupDragHandlers(actualComponent);
                    
                    // Replace placeholder with actual component
                    const parent = placeholder.parent;
                    if (parent) {
                        parent.insertBefore(actualComponent, placeholder);
                        placeholder.destroy();
                    }
                }
            });
        }
        
        return placeholder;
    }
    
    // Component cache for frequently used components
    property var componentCache: {}
    
    // Get component from cache or create new one
    function getComponentFromCache(componentType) {
        if (!componentCache[componentType]) {
            // Create component definition and cache it
            const [importName, componentName] = componentType.split('.');
            componentCache[componentType] = Qt.createQmlObject('import QtQuick 2.15; import ' + importName + ' 1.0; Component { ' + componentName + ' {} }', canvas);
        }
        return componentCache[componentType];
    }
    
    // Clear component cache
    function clearComponentCache() {
        for (const key in componentCache) {
            if (componentCache[key]) {
                componentCache[key].destroy();
            }
        }
        componentCache = {};
    }

    // Start drag of existing item
    function startDrag(item, mouseX, mouseY) {
        draggedItem = item;
        dragOffsetX = mouseX - item.x;
        dragOffsetY = mouseY - item.y;
        isDragging = true;
        
        // Create drag preview
        createDragPreview(item);
        
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
        
        // Clean up drag preview
        if (dragPreview) {
            dragPreview.destroy();
            dragPreview = null;
        }
        
        // Clean up alignment guides
        clearAlignmentGuides();
        
        draggedItem = null;
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
    
    // Create drag preview
    function createDragPreview(item) {
        if (!canvas || !item) return;
        
        // Remove existing preview
        if (dragPreview) {
            dragPreview.destroy();
            dragPreview = null;
        }
        
        // Create semi-transparent preview
        dragPreview = Qt.createQmlObject('import QtQuick 2.15; Rectangle { border.color: "#2196F3"; border.width: 2; color: "rgba(33, 150, 243, 0.2)"; }', canvas);
        if (dragPreview) {
            dragPreview.width = item.width;
            dragPreview.height = item.height;
            dragPreview.x = item.x;
            dragPreview.y = item.y;
            dragPreview.z = canvas.children.length + 1;
        }
    }
    
    // Update drag preview position
    function updateDragPreview(x, y) {
        if (!dragPreview) return;
        
        dragPreview.x = x;
        dragPreview.y = y;
    }
    
    // Clear alignment guides
    function clearAlignmentGuides() {
        alignmentGuides.forEach(function(guide) {
            if (guide) {
                guide.destroy();
            }
        });
        alignmentGuides = [];
    }
    
    // Show alignment guides
    function showAlignmentGuides(item, x, y) {
        if (!canvas || !showAlignmentGuides) return;
        
        // Clear existing guides
        clearAlignmentGuides();
        
        const tolerance = 5;
        const itemCenterX = x + item.width / 2;
        const itemCenterY = y + item.height / 2;
        
        // Check all other items for alignment
        for (let i = 0; i < canvas.children.length; i++) {
            const otherItem = canvas.children[i];
            if (otherItem !== item && otherItem !== draggedItem && otherItem !== dragPreview) {
                // Check horizontal alignment
                if (Math.abs(x - otherItem.x) < tolerance) {
                    // Left edge alignment
                    const guide = Qt.createQmlObject('import QtQuick 2.15; Rectangle { width: 1; color: "#FF9800"; z: 9999; }', canvas);
                    if (guide) {
                        guide.x = x;
                        guide.y = Math.min(y, otherItem.y);
                        guide.height = Math.max(y + item.height, otherItem.y + otherItem.height) - guide.y;
                        alignmentGuides.push(guide);
                    }
                }
                
                if (Math.abs(x + item.width - (otherItem.x + otherItem.width)) < tolerance) {
                    // Right edge alignment
                    const guide = Qt.createQmlObject('import QtQuick 2.15; Rectangle { width: 1; color: "#FF9800"; z: 9999; }', canvas);
                    if (guide) {
                        guide.x = x + item.width;
                        guide.y = Math.min(y, otherItem.y);
                        guide.height = Math.max(y + item.height, otherItem.y + otherItem.height) - guide.y;
                        alignmentGuides.push(guide);
                    }
                }
                
                if (Math.abs(itemCenterX - (otherItem.x + otherItem.width / 2)) < tolerance) {
                    // Center alignment
                    const guide = Qt.createQmlObject('import QtQuick 2.15; Rectangle { width: 1; color: "#FFC107"; z: 9999; }', canvas);
                    if (guide) {
                        guide.x = itemCenterX;
                        guide.y = Math.min(y, otherItem.y);
                        guide.height = Math.max(y + item.height, otherItem.y + otherItem.height) - guide.y;
                        alignmentGuides.push(guide);
                    }
                }
                
                // Check vertical alignment
                if (Math.abs(y - otherItem.y) < tolerance) {
                    // Top edge alignment
                    const guide = Qt.createQmlObject('import QtQuick 2.15; Rectangle { height: 1; color: "#FF9800"; z: 9999; }', canvas);
                    if (guide) {
                        guide.y = y;
                        guide.x = Math.min(x, otherItem.x);
                        guide.width = Math.max(x + item.width, otherItem.x + otherItem.width) - guide.x;
                        alignmentGuides.push(guide);
                    }
                }
                
                if (Math.abs(y + item.height - (otherItem.y + otherItem.height)) < tolerance) {
                    // Bottom edge alignment
                    const guide = Qt.createQmlObject('import QtQuick 2.15; Rectangle { height: 1; color: "#FF9800"; z: 9999; }', canvas);
                    if (guide) {
                        guide.y = y + item.height;
                        guide.x = Math.min(x, otherItem.x);
                        guide.width = Math.max(x + item.width, otherItem.x + otherItem.width) - guide.x;
                        alignmentGuides.push(guide);
                    }
                }
                
                if (Math.abs(itemCenterY - (otherItem.y + otherItem.height / 2)) < tolerance) {
                    // Center alignment
                    const guide = Qt.createQmlObject('import QtQuick 2.15; Rectangle { height: 1; color: "#FFC107"; z: 9999; }', canvas);
                    if (guide) {
                        guide.y = itemCenterY;
                        guide.x = Math.min(x, otherItem.x);
                        guide.width = Math.max(x + item.width, otherItem.x + otherItem.width) - guide.x;
                        alignmentGuides.push(guide);
                    }
                }
            }
        }
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

            // Update drag preview
            updateDragPreview(newX, newY);
            
            // Show alignment guides
            showAlignmentGuides(draggedItem, newX, newY);

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
    
    // Get all layout templates
    function getLayoutTemplates() {
        return layoutTemplates;
    }
    
    // Apply layout template by index
    function applyLayoutTemplate(index) {
        if (!canvas || index < 0 || index >= layoutTemplates.length) return;
        
        const template = layoutTemplates[index];
        applyTemplate(template);
    }
    
    // Apply layout template by name
    function applyLayoutTemplateByName(name) {
        if (!canvas) return;
        
        const template = layoutTemplates.find(t => t.name === name);
        if (template) {
            applyTemplate(template);
        }
    }
    
    // Apply template to canvas
    function applyTemplate(template) {
        if (!canvas || !template) return;
        
        // Clear existing items
        for (let i = canvas.children.length - 1; i >= 0; i--) {
            canvas.children[i].destroy();
        }
        
        // Apply template items
        template.items.forEach(function(itemInfo) {
            // Create component
            const [importName, componentName] = itemInfo.type.split('.');
            const component = Qt.createQmlObject('import QtQuick 2.15; import ' + importName + ' 1.0; ' + componentName + ' {}', canvas);
            if (component) {
                // Set properties
                component.x = itemInfo.x;
                component.y = itemInfo.y;
                component.width = itemInfo.width;
                component.height = itemInfo.height;
                if (itemInfo.text) {
                    component.text = itemInfo.text;
                }
                if (itemInfo.tagName) {
                    component.tagName = itemInfo.tagName;
                }
                
                // Set up drag handlers
                setupDragHandlers(component);
            }
        });
    }
    
    // Save current layout as template
    function saveCurrentLayoutAsTemplate(name, description) {
        const currentLayout = saveLayout();
        if (currentLayout.length === 0) return false;
        
        // Create template object
        const template = {
            name: name,
            description: description,
            items: currentLayout.map(item => ({
                type: item.type,
                x: item.x,
                y: item.y,
                width: item.width,
                height: item.height,
                tagName: item.tagName || ""
            }))
        };
        
        // Add to templates
        layoutTemplates.push(template);
        return true;
    }
    
    // Create a new page
    function createPage(pageName) {
        if (!canvas || !pageName) return null;
        
        // Save current page layout if it exists
        if (currentPageIndex >= 0 && pages[currentPageIndex]) {
            pages[currentPageIndex].layout = saveLayout();
        }
        
        // Create new page object
        const newPage = {
            name: pageName,
            layout: [],
            canvas: canvas
        };
        
        // Add to pages array
        pages.push(newPage);
        
        // Switch to new page
        switchPage(pages.length - 1);
        
        return newPage;
    }
    
    // Switch to page by index
    function switchPage(index) {
        if (!canvas || index < 0 || index >= pages.length) return false;
        
        // Save current page layout if it exists
        if (currentPageIndex >= 0 && pages[currentPageIndex]) {
            pages[currentPageIndex].layout = saveLayout();
        }
        
        // Switch to new page
        currentPageIndex = index;
        const page = pages[index];
        currentPageName = page.name;
        
        // Clear current canvas
        for (let i = canvas.children.length - 1; i >= 0; i--) {
            canvas.children[i].destroy();
        }
        
        // Load page layout
        if (page.layout && page.layout.length > 0) {
            loadLayout(page.layout);
        }
        
        return true;
    }
    
    // Switch to page by name
    function switchPageByName(name) {
        if (!canvas) return false;
        
        const index = pages.findIndex(p => p.name === name);
        if (index >= 0) {
            return switchPage(index);
        }
        return false;
    }
    
    // Rename page
    function renamePage(index, newName) {
        if (!canvas || index < 0 || index >= pages.length || !newName) return false;
        
        pages[index].name = newName;
        if (index === currentPageIndex) {
            currentPageName = newName;
        }
        return true;
    }
    
    // Delete page
    function deletePage(index) {
        if (!canvas || index < 0 || index >= pages.length) return false;
        
        // Remove page
        pages.splice(index, 1);
        
        // Adjust current page index
        if (currentPageIndex >= index) {
            currentPageIndex = Math.max(0, currentPageIndex - 1);
        }
        
        // Switch to appropriate page
        if (pages.length > 0) {
            switchPage(currentPageIndex);
        } else {
            // No pages left, clear canvas
            for (let i = canvas.children.length - 1; i >= 0; i--) {
                canvas.children[i].destroy();
            }
            currentPageIndex = -1;
            currentPageName = "";
        }
        
        return true;
    }
    
    // Get all pages
    function getPages() {
        return pages;
    }
    
    // Get current page
    function getCurrentPage() {
        if (currentPageIndex >= 0 && currentPageIndex < pages.length) {
            return pages[currentPageIndex];
        }
        return null;
    }
    
    // Duplicate current page
    function duplicateCurrentPage(newName) {
        if (!canvas || currentPageIndex < 0) return null;
        
        const currentPage = pages[currentPageIndex];
        const duplicatedPage = {
            name: newName,
            layout: JSON.parse(JSON.stringify(currentPage.layout)),
            canvas: canvas
        };
        
        pages.push(duplicatedPage);
        switchPage(pages.length - 1);
        
        return duplicatedPage;
    }

    // Delete selected items
    function deleteSelectedItems() {
        const itemsToDelete = [...selectedItems];
        itemsToDelete.forEach(function(item) {
            deleteItem(item);
        });
    }

    // Group selected items
    function groupSelectedItems() {
        if (selectedItems.length < 2) return;
        
        // Calculate bounding box
        let minX = Infinity, minY = Infinity;
        let maxX = -Infinity, maxY = -Infinity;
        
        selectedItems.forEach(function(item) {
            minX = Math.min(minX, item.x);
            minY = Math.min(minY, item.y);
            maxX = Math.max(maxX, item.x + item.width);
            maxY = Math.max(maxY, item.y + item.height);
        });
        
        // Create group container
        const group = Qt.createQmlObject('import QtQuick 2.15; Item { }', canvas);
        if (group) {
            group.x = minX;
            group.y = minY;
            group.width = maxX - minX;
            group.height = maxY - minY;
            
            // Move selected items to group
            selectedItems.forEach(function(item) {
                item.x -= minX;
                item.y -= minY;
                group.appendChild(item);
            });
            
            // Set up drag handlers for group
            setupDragHandlers(group);
            
            // Clear selection and select group
            clearSelection();
            selectItem(group);
        }
    }

    // Ungroup selected group
    function ungroupSelectedItem() {
        if (selectedItems.length !== 1) return;
        
        const group = selectedItems[0];
        if (group.children.length < 2) return;
        
        // Move children back to canvas
        const children = [...group.children];
        children.forEach(function(child) {
            child.x += group.x;
            child.y += group.y;
            canvas.appendChild(child);
        });
        
        // Delete group
        deleteItem(group);
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
                if (dragAndDropHelper.isDragging || dragAndDropHelper.isResizing || dragAndDropHelper.isRotating) {
                    dragAndDropHelper.handleMouseMove(mouseArea.mouseX, mouseArea.mouseY);
                }
            });
            
            mouseArea.mouseYChanged.connect(function() {
                if (dragAndDropHelper.isDragging || dragAndDropHelper.isResizing || dragAndDropHelper.isRotating) {
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
        
        // Add rotation handle
        const rotationHandle = Qt.createQmlObject('import QtQuick 2.15; Rectangle { width: ' + handleSize + '; height: ' + handleSize + '; color: "#FF9800"; border.color: "#F57C00"; border.width: 1; anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter; anchors.margins: -' + (handleSize / 2 + 15) + '; opacity: 0; }', item);
        if (rotationHandle) {
            const rotationHandleMouseArea = Qt.createQmlObject('import QtQuick 2.15; MouseArea { anchors.fill: parent; cursorShape: Qt.SizeAllCursor; }', rotationHandle);
            if (rotationHandleMouseArea) {
                // Connect signals using JavaScript
                rotationHandleMouseArea.pressed.connect(function() {
                    dragAndDropHelper.draggedItem = item;
                    dragAndDropHelper.isRotating = true;
                });
                
                rotationHandleMouseArea.released.connect(function() {
                    dragAndDropHelper.endDrag();
                });
            }
        }
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
        
        // Show resize handles and rotation handle
        for (let i = 0; i < item.children.length; i++) {
            const child = item.children[i];
            if (child.color === "#2196F3" || child.color === "#FF9800") {
                child.opacity = 1;
            }
        }
    }
    
    // Hide item selection
    function hideItemSelection(item) {
        if (item.selectionBorder) {
            item.selectionBorder.opacity = 0;
        }
        
        // Hide resize handles and rotation handle
        for (let i = 0; i < item.children.length; i++) {
            const child = item.children[i];
            if (child.color === "#2196F3" || child.color === "#FF9800") {
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

            // Add separator
            Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuSeparator { }', menu);

            // Add batch operations for multiple selection
            if (selectedItems.length > 1) {
                const deleteSelectedAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Delete Selected" }', menu);
                if (deleteSelectedAction) {
                    deleteSelectedAction.triggered.connect(function() {
                        deleteSelectedItems();
                    });
                }

                const groupAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Group" }', menu);
                if (groupAction) {
                    groupAction.triggered.connect(function() {
                        groupSelectedItems();
                    });
                }
            }

            // Add ungroup action if item is a group
            if (item.children && item.children.length > 0) {
                const ungroupAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Ungroup" }', menu);
                if (ungroupAction) {
                    ungroupAction.triggered.connect(function() {
                        ungroupSelectedItem();
                    });
                }
            }

            // Add separator
            Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuSeparator { }', menu);

            // Add layer options
            const layerMenu = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; Menu { title: "Layer" }', menu);
            if (layerMenu) {
                const bringToFrontAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Bring to Front" }', layerMenu);
                if (bringToFrontAction) {
                    bringToFrontAction.triggered.connect(function() {
                        dragAndDropHelper.moveSelectedItemsToTop();
                    });
                }

                const bringForwardAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Bring Forward" }', layerMenu);
                if (bringForwardAction) {
                    bringForwardAction.triggered.connect(function() {
                        dragAndDropHelper.moveSelectedItemsUp();
                    });
                }

                const sendBackwardAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Send Backward" }', layerMenu);
                if (sendBackwardAction) {
                    sendBackwardAction.triggered.connect(function() {
                        dragAndDropHelper.moveSelectedItemsDown();
                    });
                }

                const sendToBackAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Send to Back" }', layerMenu);
                if (sendToBackAction) {
                    sendToBackAction.triggered.connect(function() {
                        dragAndDropHelper.moveSelectedItemsToBottom();
                    });
                }
            }

            // Add template options
            const templateMenu = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; Menu { title: "Templates" }', menu);
            if (templateMenu) {
                dragAndDropHelper.getLayoutTemplates().forEach(function(template, index) {
                    const templateAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "' + template.name + '" }', templateMenu);
                    if (templateAction) {
                        templateAction.triggered.connect(function() {
                            dragAndDropHelper.applyLayoutTemplate(index);
                        });
                    }
                });
            }

            // Add page management options
            const pageMenu = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; Menu { title: "Pages" }', menu);
            if (pageMenu) {
                // Create new page
                const newPageAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "New Page" }', pageMenu);
                if (newPageAction) {
                    newPageAction.triggered.connect(function() {
                        const pageName = "Page " + (dragAndDropHelper.getPages().length + 1);
                        dragAndDropHelper.createPage(pageName);
                    });
                }

                // Duplicate current page
                const duplicatePageAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Duplicate Page" }', pageMenu);
                if (duplicatePageAction) {
                    duplicatePageAction.triggered.connect(function() {
                        const currentPage = dragAndDropHelper.getCurrentPage();
                        if (currentPage) {
                            const newPageName = currentPage.name + " (Copy)";
                            dragAndDropHelper.duplicateCurrentPage(newPageName);
                        }
                    });
                }

                // Add separator
                Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuSeparator { }', pageMenu);

                // Switch between pages
                const pages = dragAndDropHelper.getPages();
                pages.forEach(function(page, index) {
                    const pageAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "' + page.name + '" }', pageMenu);
                    if (pageAction) {
                        pageAction.triggered.connect(function() {
                            dragAndDropHelper.switchPage(index);
                        });
                    }
                });
            }

            // Add version control options
            const versionMenu = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; Menu { title: "Version Control" }', menu);
            if (versionMenu) {
                // Create snapshot
                const createSnapshotAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Create Snapshot" }', versionMenu);
                if (createSnapshotAction) {
                    createSnapshotAction.triggered.connect(function() {
                        dragAndDropHelper.createVersionSnapshot("Manual snapshot");
                    });
                }

                // Roll back one version
                const rollbackAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Undo" }', versionMenu);
                if (rollbackAction) {
                    rollbackAction.triggered.connect(function() {
                        dragAndDropHelper.rollbackOneVersion();
                    });
                }

                // Roll forward one version
                const rollforwardAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Redo" }', versionMenu);
                if (rollforwardAction) {
                    rollforwardAction.triggered.connect(function() {
                        dragAndDropHelper.rollforwardOneVersion();
                    });
                }

                // Add separator
                Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuSeparator { }', versionMenu);

                // View version history
                const historyAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "View History" }', versionMenu);
                if (historyAction) {
                    historyAction.triggered.connect(function() {
                        // In a real implementation, this would open a dialog showing version history
                        console.log("Version history:", dragAndDropHelper.getVersionHistory());
                    });
                }

                // Clear version history
                const clearHistoryAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Clear History" }', versionMenu);
                if (clearHistoryAction) {
                    clearHistoryAction.triggered.connect(function() {
                        dragAndDropHelper.clearVersionHistory();
                    });
                }
            }

            // Add theme options
            const themeMenu = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; Menu { title: "Themes" }', menu);
            if (themeMenu) {
                // Theme selection
                const themes = dragAndDropHelper.getThemes();
                themes.forEach(function(theme) {
                    const themeAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "' + theme.name + '" }', themeMenu);
                    if (themeAction) {
                        themeAction.triggered.connect(function() {
                            dragAndDropHelper.applyTheme(theme.name);
                        });
                    }
                });

                // Add separator
                Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuSeparator { }', themeMenu);

                // Create custom theme
                const createThemeAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Create Custom Theme" }', themeMenu);
                if (createThemeAction) {
                    createThemeAction.triggered.connect(function() {
                        // In a real implementation, this would open a dialog to create a custom theme
                        console.log("Create custom theme");
                    });
                }

                // Export current theme
                const exportThemeAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Export Current Theme" }', themeMenu);
                if (exportThemeAction) {
                    exportThemeAction.triggered.connect(function() {
                        const themeJson = dragAndDropHelper.exportTheme(dragAndDropHelper.getCurrentTheme().name);
                        if (themeJson) {
                            console.log("Theme exported:", themeJson);
                        }
                    });
                }
            }

            // Add project template options
            const projectTemplateMenu = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; Menu { title: "Project Templates" }', menu);
            if (projectTemplateMenu) {
                // Create project from template
                const templates = dragAndDropHelper.getProjectTemplates();
                templates.forEach(function(template) {
                    const templateAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "' + template.name + '" }', projectTemplateMenu);
                    if (templateAction) {
                        templateAction.triggered.connect(function() {
                            dragAndDropHelper.createProjectFromTemplate(template.name);
                        });
                    }
                });

                // Add separator
                Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuSeparator { }', projectTemplateMenu);

                // Save current project as template
                const saveAsTemplateAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Save Current Project as Template" }', projectTemplateMenu);
                if (saveAsTemplateAction) {
                    saveAsTemplateAction.triggered.connect(function() {
                        // In a real implementation, this would open a dialog to save as template
                        const templateName = "Custom Template " + (dragAndDropHelper.getProjectTemplates().length + 1);
                        dragAndDropHelper.saveCurrentProjectAsTemplate(templateName, "Custom project template");
                    });
                }

                // Export current project as template
                const exportTemplateAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Export Current Project as Template" }', projectTemplateMenu);
                if (exportTemplateAction) {
                    exportTemplateAction.triggered.connect(function() {
                        // In a real implementation, this would open a save dialog
                        const templateName = "Exported Template";
                        dragAndDropHelper.saveCurrentProjectAsTemplate(templateName, "Exported project template");
                        const templateJson = dragAndDropHelper.exportProjectTemplate(templateName);
                        if (templateJson) {
                            console.log("Project template exported:", templateJson);
                        }
                    });
                }
            }

            // Add separator
            Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuSeparator { }', menu);

            // Add alignment options
            const alignMenu = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; Menu { title: "Align" }', menu);
            if (alignMenu) {
                const alignLeftAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Left" }', alignMenu);
                if (alignLeftAction) {
                    alignLeftAction.triggered.connect(function() {
                        alignItems("left");
                    });
                }

                const alignRightAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Right" }', alignMenu);
                if (alignRightAction) {
                    alignRightAction.triggered.connect(function() {
                        alignItems("right");
                    });
                }

                const alignTopAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Top" }', alignMenu);
                if (alignTopAction) {
                    alignTopAction.triggered.connect(function() {
                        alignItems("top");
                    });
                }

                const alignBottomAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Bottom" }', alignMenu);
                if (alignBottomAction) {
                    alignBottomAction.triggered.connect(function() {
                        alignItems("bottom");
                    });
                }

                const alignCenterAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Center" }', alignMenu);
                if (alignCenterAction) {
                    alignCenterAction.triggered.connect(function() {
                        alignItems("center");
                    });
                }

                const alignMiddleAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Middle" }', alignMenu);
                if (alignMiddleAction) {
                    alignMiddleAction.triggered.connect(function() {
                        alignItems("middle");
                    });
                }
            }

            // Add distribution options
            if (selectedItems.length > 2) {
                const distributeMenu = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; Menu { title: "Distribute" }', menu);
                if (distributeMenu) {
                    const distributeHorizontalAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Horizontal" }', distributeMenu);
                    if (distributeHorizontalAction) {
                        distributeHorizontalAction.triggered.connect(function() {
                            distributeItems("horizontal");
                        });
                    }

                    const distributeVerticalAction = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; MenuItem { text: "Vertical" }', distributeMenu);
                    if (distributeVerticalAction) {
                        distributeVerticalAction.triggered.connect(function() {
                            distributeItems("vertical");
                        });
                    }
                }
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
                    rotation: item.rotation || 0,
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
            const [importName, componentName] = itemInfo.type.split('.');
            const component = Qt.createQmlObject('import QtQuick 2.15; import ' + importName + ' 1.0; ' + componentName + ' {}', canvas);
            if (component) {
                // Set properties
                component.x = itemInfo.x;
                component.y = itemInfo.y;
                component.width = itemInfo.width;
                component.height = itemInfo.height;
                component.rotation = itemInfo.rotation || 0;
                if (itemInfo.tagName) {
                    component.tagName = itemInfo.tagName;
                }

                // Set up drag handlers
                setupDragHandlers(component);
            }
        }
    }
    
    // Save all pages
    function saveAllPages() {
        // Save current page layout if it exists
        if (currentPageIndex >= 0 && pages[currentPageIndex]) {
            pages[currentPageIndex].layout = saveLayout();
        }
        
        // Return pages data
        return {
            pages: pages.map(page => ({
                name: page.name,
                layout: page.layout
            })),
            currentPageIndex: currentPageIndex
        };
    }
    
    // Load all pages
    function loadAllPages(pageData) {
        if (!canvas || !pageData || !pageData.pages) return;
        
        // Clear existing pages
        pages = [];
        
        // Load pages
        pageData.pages.forEach(function(pageInfo) {
            const page = {
                name: pageInfo.name,
                layout: pageInfo.layout,
                canvas: canvas
            };
            pages.push(page);
        });
        
        // Switch to current page
        if (pageData.currentPageIndex !== undefined && pageData.currentPageIndex >= 0 && pageData.currentPageIndex < pages.length) {
            switchPage(pageData.currentPageIndex);
        } else if (pages.length > 0) {
            switchPage(0);
        }
    }
    
    // Create version snapshot
    function createVersionSnapshot(description) {
        if (!canvas) return null;
        
        // Save current state
        const snapshot = {
            timestamp: new Date().toISOString(),
            description: description || "Auto snapshot",
            data: {
                pages: saveAllPages(),
                canvasScale: canvasScale,
                canvasOffsetX: canvasOffsetX,
                canvasOffsetY: canvasOffsetY,
                gridSize: gridSize,
                showGrid: showGrid
            }
        };
        
        // Remove versions after current index if we're not at the latest version
        if (currentVersionIndex < versionHistory.length - 1) {
            versionHistory = versionHistory.slice(0, currentVersionIndex + 1);
        }
        
        // Add new snapshot
        versionHistory.push(snapshot);
        
        // Limit history size
        if (versionHistory.length > maxVersionHistory) {
            versionHistory.shift();
            currentVersionIndex = Math.max(0, currentVersionIndex - 1);
        } else {
            currentVersionIndex = versionHistory.length - 1;
        }
        
        return snapshot;
    }
    
    // Roll back to previous version
    function rollbackToVersion(index) {
        if (!canvas || index < 0 || index >= versionHistory.length) return false;
        
        const version = versionHistory[index];
        if (!version || !version.data) return false;
        
        // Load version data
        if (version.data.pages) {
            loadAllPages(version.data.pages);
        }
        
        // Restore canvas properties
        if (version.data.canvasScale !== undefined) {
            canvasScale = version.data.canvasScale;
        }
        if (version.data.canvasOffsetX !== undefined) {
            canvasOffsetX = version.data.canvasOffsetX;
        }
        if (version.data.canvasOffsetY !== undefined) {
            canvasOffsetY = version.data.canvasOffsetY;
        }
        if (version.data.gridSize !== undefined) {
            gridSize = version.data.gridSize;
        }
        if (version.data.showGrid !== undefined) {
            showGrid = version.data.showGrid;
        }
        
        // Update canvas transform
        updateCanvasTransform();
        
        // Update grid
        updateGrid();
        
        // Update current version index
        currentVersionIndex = index;
        
        return true;
    }
    
    // Get version history
    function getVersionHistory() {
        return versionHistory;
    }
    
    // Clear version history
    function clearVersionHistory() {
        versionHistory = [];
        currentVersionIndex = -1;
    }
    
    // Get current version
    function getCurrentVersion() {
        if (currentVersionIndex >= 0 && currentVersionIndex < versionHistory.length) {
            return versionHistory[currentVersionIndex];
        }
        return null;
    }
    
    // Roll back to previous version (one step back)
    function rollbackOneVersion() {
        if (currentVersionIndex > 0) {
            return rollbackToVersion(currentVersionIndex - 1);
        }
        return false;
    }
    
    // Roll forward to next version (one step forward)
    function rollforwardOneVersion() {
        if (currentVersionIndex < versionHistory.length - 1) {
            return rollbackToVersion(currentVersionIndex + 1);
        }
        return false;
    }
    
    // Get all component categories
    function getComponentCategories() {
        const categories = new Set();
        componentLibrary.forEach(function(component) {
            if (component.category) {
                categories.add(component.category);
            }
        });
        return Array.from(categories);
    }
    
    // Get components by category
    function getComponentsByCategory(category) {
        if (!category) return componentLibrary;
        return componentLibrary.filter(function(component) {
            return component.category === category;
        });
    }
    
    // Search components by name or type
    function searchComponents(query) {
        if (!query) return componentLibrary;
        
        const lowerQuery = query.toLowerCase();
        return componentLibrary.filter(function(component) {
            return (
                component.name.toLowerCase().includes(lowerQuery) ||
                component.type.toLowerCase().includes(lowerQuery) ||
                (component.category && component.category.toLowerCase().includes(lowerQuery))
            );
        });
    }
    
    // Get component by type
    function getComponentByType(type) {
        return componentLibrary.find(function(component) {
            return component.type === type;
        });
    }
    
    // Add custom component to library
    function addCustomComponent(component) {
        if (!component || !component.name || !component.type) return false;
        
        // Check if component already exists
        const existingComponent = componentLibrary.find(function(c) {
            return c.type === component.type;
        });
        
        if (existingComponent) {
            // Update existing component
            Object.assign(existingComponent, component);
        } else {
            // Add new component
            componentLibrary.push(component);
        }
        
        return true;
    }
    
    // Remove component from library
    function removeComponent(type) {
        const index = componentLibrary.findIndex(function(component) {
            return component.type === type;
        });
        
        if (index >= 0) {
            componentLibrary.splice(index, 1);
            return true;
        }
        return false;
    }
    
    // Get all themes
    function getThemes() {
        return themes;
    }
    
    // Get current theme
    function getCurrentTheme() {
        return themes.find(function(theme) {
            return theme.name === currentTheme;
        }) || themes[0];
    }
    
    // Apply theme by name
    function applyTheme(themeName) {
        const theme = themes.find(function(t) {
            return t.name === themeName;
        });
        
        if (!theme) return false;
        
        currentTheme = themeName;
        updateComponentStyles(theme);
        return true;
    }
    
    // Update component styles based on theme
    function updateComponentStyles(theme) {
        if (!canvas || !theme) return;
        
        // Update all components on canvas
        for (let i = 0; i < canvas.children.length; i++) {
            const item = canvas.children[i];
            updateComponentStyle(item, theme);
        }
    }
    
    // Update individual component style
    function updateComponentStyle(component, theme) {
        if (!component || !theme) return;
        
        // Update colors based on component type
        if (component.hasOwnProperty('color')) {
            component.color = theme.colors.primary;
        }
        
        if (component.hasOwnProperty('borderColor')) {
            component.borderColor = theme.colors.border;
        }
        
        if (component.hasOwnProperty('backgroundColor')) {
            component.backgroundColor = theme.colors.background;
        }
        
        if (component.hasOwnProperty('textColor')) {
            component.textColor = theme.colors.text;
        }
        
        // Update fonts
        if (component.hasOwnProperty('font')) {
            component.font = {
                family: theme.fonts.family,
                pointSize: theme.fonts.size,
                weight: theme.fonts.weight === 'bold' ? Font.Bold : Font.Normal
            };
        }
    }
    
    // Create custom theme
    function createCustomTheme(name, description, colors, fonts) {
        const theme = {
            name: name,
            description: description || "Custom theme",
            colors: colors || getCurrentTheme().colors,
            fonts: fonts || getCurrentTheme().fonts
        };
        
        // Check if theme already exists
        const existingIndex = themes.findIndex(function(t) {
            return t.name === name;
        });
        
        if (existingIndex >= 0) {
            // Update existing theme
            themes[existingIndex] = theme;
        } else {
            // Add new theme
            themes.push(theme);
        }
        
        // Apply new theme
        applyTheme(name);
        return theme;
    }
    
    // Remove theme
    function removeTheme(name) {
        if (name === "Default") return false; // Cannot remove default theme
        
        const index = themes.findIndex(function(theme) {
            return theme.name === name;
        });
        
        if (index >= 0) {
            themes.splice(index, 1);
            
            // If current theme was removed, switch to default
            if (currentTheme === name) {
                applyTheme("Default");
            }
            
            return true;
        }
        
        return false;
    }
    
    // Export theme as JSON
    function exportTheme(name) {
        const theme = themes.find(function(t) {
            return t.name === name;
        });
        
        if (theme) {
            return JSON.stringify(theme, null, 2);
        }
        return null;
    }
    
    // Import theme from JSON
    function importTheme(themeJson) {
        try {
            const theme = JSON.parse(themeJson);
            if (!theme.name) return false;
            
            createCustomTheme(theme.name, theme.description, theme.colors, theme.fonts);
            return true;
        } catch (error) {
            return false;
        }
    }
    
    // Get all project templates
    function getProjectTemplates() {
        return projectTemplates;
    }
    
    // Create project from template
    function createProjectFromTemplate(templateName) {
        if (!canvas) return false;
        
        const template = projectTemplates.find(function(t) {
            return t.name === templateName;
        });
        
        if (!template) return false;
        
        // Clear existing pages
        pages = [];
        
        // Load template pages
        template.pages.forEach(function(pageInfo) {
            const page = {
                name: pageInfo.name,
                layout: pageInfo.layout,
                canvas: canvas
            };
            pages.push(page);
        });
        
        // Apply template theme
        if (template.theme) {
            applyTheme(template.theme);
        }
        
        // Switch to first page
        if (pages.length > 0) {
            switchPage(0);
        }
        
        return true;
    }
    
    // Save current project as template
    function saveCurrentProjectAsTemplate(templateName, description) {
        if (!canvas) return false;
        
        // Save current page layout
        if (currentPageIndex >= 0 && pages[currentPageIndex]) {
            pages[currentPageIndex].layout = saveLayout();
        }
        
        // Create template object
        const template = {
            name: templateName,
            description: description || "Custom project template",
            pages: pages.map(page => ({
                name: page.name,
                layout: page.layout
            })),
            theme: currentTheme
        };
        
        // Check if template already exists
        const existingIndex = projectTemplates.findIndex(function(t) {
            return t.name === templateName;
        });
        
        if (existingIndex >= 0) {
            // Update existing template
            projectTemplates[existingIndex] = template;
        } else {
            // Add new template
            projectTemplates.push(template);
        }
        
        return true;
    }
    
    // Delete project template
    function deleteProjectTemplate(templateName) {
        const index = projectTemplates.findIndex(function(template) {
            return template.name === templateName;
        });
        
        if (index >= 0) {
            projectTemplates.splice(index, 1);
            return true;
        }
        
        return false;
    }
    
    // Export project template as JSON
    function exportProjectTemplate(templateName) {
        const template = projectTemplates.find(function(t) {
            return t.name === templateName;
        });
        
        if (template) {
            return JSON.stringify(template, null, 2);
        }
        return null;
    }
    
    // Import project template from JSON
    function importProjectTemplate(templateJson) {
        try {
            const template = JSON.parse(templateJson);
            if (!template.name || !template.pages) return false;
            
            // Check if template already exists
            const existingIndex = projectTemplates.findIndex(function(t) {
                return t.name === template.name;
            });
            
            if (existingIndex >= 0) {
                // Update existing template
                projectTemplates[existingIndex] = template;
            } else {
                // Add new template
                projectTemplates.push(template);
            }
            
            return true;
        } catch (error) {
            return false;
        }
    }
    
    // Quick create project with common configurations
    function quickCreateProject(projectType) {
        switch (projectType) {
            case "controlRoom":
                return createProjectFromTemplate("Control Room Dashboard");
            case "energyManagement":
                return createProjectFromTemplate("Energy Management System");
            case "empty":
                return createProjectFromTemplate("Empty Project");
            default:
                return false;
        }
    }
    
    // Collect all project resources
    function collectProjectResources() {
        const resources = {
            images: [],
            models: [],
            fonts: [],
            other: []
        };
        
        // Collect resources from components
        pages.forEach(function(page) {
            if (page.layout) {
                page.layout.forEach(function(itemInfo) {
                    // Collect resources based on component type
                    if (itemInfo.type.includes("Image")) {
                        if (itemInfo.imagePath) {
                            resources.images.push(itemInfo.imagePath);
                        }
                    } else if (itemInfo.type.includes("Model")) {
                        if (itemInfo.modelPath) {
                            resources.models.push(itemInfo.modelPath);
                        }
                    }
                });
            }
        });
        
        return resources;
    }
    
    // Export project as package
    function exportProjectAsPackage(projectName) {
        if (!canvas) return null;
        
        // Save current project state
        if (currentPageIndex >= 0 && pages[currentPageIndex]) {
            pages[currentPageIndex].layout = saveLayout();
        }
        
        // Collect project data
        const projectData = {
            name: projectName || "Untitled Project",
            version: "1.0",
            exportDate: new Date().toISOString(),
            pages: pages.map(page => ({
                name: page.name,
                layout: page.layout
            })),
            currentPageIndex: currentPageIndex,
            theme: currentTheme,
            resources: collectProjectResources()
        };
        
        // In a real implementation, this would:
        // 1. Create a zip file
        // 2. Add project.json with projectData
        // 3. Add all dependent resources
        // 4. Return the zip file path
        
        console.log("Project exported as package:", projectData);
        return JSON.stringify(projectData, null, 2);
    }
    
    // Import project from package
    function importProjectFromPackage(packageData) {
        try {
            const projectData = JSON.parse(packageData);
            if (!projectData.pages) return false;
            
            // Clear existing pages
            pages = [];
            
            // Load project pages
            projectData.pages.forEach(function(pageInfo) {
                const page = {
                    name: pageInfo.name,
                    layout: pageInfo.layout,
                    canvas: canvas
                };
                pages.push(page);
            });
            
            // Apply project theme
            if (projectData.theme) {
                applyTheme(projectData.theme);
            }
            
            // Switch to current page
            if (projectData.currentPageIndex !== undefined && projectData.currentPageIndex >= 0 && projectData.currentPageIndex < pages.length) {
                switchPage(projectData.currentPageIndex);
            } else if (pages.length > 0) {
                switchPage(0);
            }
            
            // In a real implementation, this would:
            // 1. Extract resources from package
            // 2. Update resource paths in components
            // 3. Load external resources
            
            console.log("Project imported from package:", projectData.name);
            return true;
        } catch (error) {
            console.error("Error importing project:", error);
            return false;
        }
    }
    
    // Validate project package
    function validateProjectPackage(packageData) {
        try {
            const projectData = JSON.parse(packageData);
            
            // Check required fields
            if (!projectData.name || !projectData.pages || !Array.isArray(projectData.pages)) {
                return false;
            }
            
            // Check page structure
            for (const page of projectData.pages) {
                if (!page.name) {
                    return false;
                }
            }
            
            return true;
        } catch (error) {
            return false;
        }
    }
    
    // Get project summary
    function getProjectSummary() {
        return {
            name: "Current Project",
            pageCount: pages.length,
            currentPage: currentPageName,
            componentCount: pages.reduce(function(count, page) {
                return count + (page.layout ? page.layout.length : 0);
            }, 0),
            theme: currentTheme,
            resources: collectProjectResources()
        };
    }
    
    // Optimize 3D visualization performance
    function optimize3DVisualization() {
        // In a real implementation, this would:
        // 1. Enable frustum culling for 3D models
        // 2. Implement level of detail (LOD) for complex models
        // 3. Use proper材质 and shader optimization
        // 4. Implement efficient rendering pipelines
        
        console.log("3D visualization optimized");
        return true;
    }
    
    // Set 3D quality level
    function set3DQualityLevel(level) {
        // Levels: low, medium, high, ultra
        switch (level) {
            case "low":
                // Reduce polygon count, disable shadows, use simpler materials
                break;
            case "medium":
                // Balance between quality and performance
                break;
            case "high":
                // Enable higher quality features
                break;
            case "ultra":
                // Maximum quality, may impact performance
                break;
        }
        
        console.log("3D quality level set to:", level);
        return true;
    }
    
    // Optimize 3D model loading
    function optimize3DModelLoading(modelPath) {
        // In a real implementation, this would:
        // 1. Use asynchronous loading
        // 2. Implement model caching
        // 3. Use compressed model formats
        // 4. Preload commonly used models
        
        console.log("3D model loading optimized for:", modelPath);
        return true;
    }
    
    // Handle 3D camera controls
    function setup3DCameraControls(camera) {
        if (!camera) return false;
        
        // In a real implementation, this would:
        // 1. Set up orbit controls
        // 2. Configure zoom limits
        // 3. Set up pan and rotate sensitivity
        // 4. Add keyboard shortcuts
        
        console.log("3D camera controls set up");
        return true;
    }
    
    // Add 3D lighting
    function add3DLighting(scene) {
        if (!scene) return false;
        
        // In a real implementation, this would:
        // 1. Add ambient light
        // 2. Add directional light for shadows
        // 3. Add point lights for specific areas
        // 4. Configure light properties
        
        console.log("3D lighting added to scene");
        return true;
    }
    
    // Enable 3D shadows
    function enable3DShadows(scene, enable) {
        if (!scene) return false;
        
        // In a real implementation, this would:
        // 1. Enable/disable shadow mapping
        // 2. Configure shadow resolution
        // 3. Set shadow distance
        // 4. Optimize shadow calculations
        
        console.log("3D shadows " + (enable ? "enabled" : "disabled"));
        return true;
    }
    
    // Get 3D performance metrics
    function get3DPerformanceMetrics() {
        // In a real implementation, this would:
        // 1. Measure FPS
        // 2. Track draw calls
        // 3. Monitor memory usage
        // 4. Report model complexity
        
        return {
            fps: 60,
            drawCalls: 120,
            memoryUsage: "128 MB",
            modelCount: 5
        };
    }
    
    // Show success notification
    function showSuccessNotification(message, duration) {
        // In a real implementation, this would:
        // 1. Create a notification component
        // 2. Set success styling (green color, check icon)
        // 3. Display message
        // 4. Auto-dismiss after duration
        
        console.log("Success:", message);
        return true;
    }
    
    // Show error notification
    function showErrorNotification(message, duration) {
        // In a real implementation, this would:
        // 1. Create a notification component
        // 2. Set error styling (red color, error icon)
        // 3. Display message
        // 4. Auto-dismiss after duration
        
        console.log("Error:", message);
        return true;
    }
    
    // Show warning notification
    function showWarningNotification(message, duration) {
        // In a real implementation, this would:
        // 1. Create a notification component
        // 2. Set warning styling (yellow color, warning icon)
        // 3. Display message
        // 4. Auto-dismiss after duration
        
        console.log("Warning:", message);
        return true;
    }
    
    // Show info notification
    function showInfoNotification(message, duration) {
        // In a real implementation, this would:
        // 1. Create a notification component
        // 2. Set info styling (blue color, info icon)
        // 3. Display message
        // 4. Auto-dismiss after duration
        
        console.log("Info:", message);
        return true;
    }
    
    // Show confirmation dialog
    function showConfirmationDialog(title, message, onConfirm, onCancel) {
        // In a real implementation, this would:
        // 1. Create a dialog component
        // 2. Set title and message
        // 3. Add confirm and cancel buttons
        // 4. Call callbacks based on user action
        
        console.log("Confirmation dialog:", title, message);
        // Simulate user confirming
        if (onConfirm) {
            onConfirm();
        }
        return true;
    }
    
    // Show progress dialog
    function showProgressDialog(title, message) {
        // In a real implementation, this would:
        // 1. Create a dialog component
        // 2. Set title and message
        // 3. Show progress bar
        // 4. Allow updating progress
        
        console.log("Progress dialog:", title, message);
        return {
            update: function(progress) {
                console.log("Progress updated:", progress);
            },
            close: function() {
                console.log("Progress dialog closed");
            }
        };
    }
    
    // Show status bar message
    function showStatusBarMessage(message, duration) {
        // In a real implementation, this would:
        // 1. Update the status bar component
        // 2. Display message
        // 3. Auto-clear after duration
        
        console.log("Status bar:", message);
        return true;
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

