import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: componentLibraryManager
    visible: false

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

    // Component cache for frequently used components
    property var componentCache: {}

    // Canvas properties
    property Item canvas: null

    // Initialize component library manager
    function init(canvasItem) {
        canvas = canvasItem;
    }

    // Get all component categories
    function getComponentCategories() {
        const categories = new Set();
        componentLibrary.forEach(function(component) {
            categories.add(component.category);
        });
        return Array.from(categories);
    }

    // Get components by category
    function getComponentsByCategory(category) {
        return componentLibrary.filter(function(component) {
            return component.category === category;
        });
    }

    // Search components by name or type
    function searchComponents(query) {
        if (!query || query.trim() === "") {
            return componentLibrary;
        }
        
        const lowerQuery = query.toLowerCase().trim();
        return componentLibrary.filter(function(component) {
            return component.name.toLowerCase().includes(lowerQuery) ||
                   component.type.toLowerCase().includes(lowerQuery) ||
                   component.category.toLowerCase().includes(lowerQuery);
        });
    }

    // Start drag from component library
    function startDragFromLibrary(componentType, mouseX, mouseY) {
        // Create new component
        const componentInfo = componentLibrary.find(item => item.type === componentType);
        if (!componentInfo || !canvas) return;

        // Create component dynamically with lazy loading
        const component = createComponentWithLazyLoading(componentType, componentInfo, mouseX, mouseY);
        if (component) {
            // Add to canvas
            canvas.appendChild(component);
            return component;
        }
        return null;
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
        placeholder.x = mouseX - canvas.x - componentInfo.width / 2;
        placeholder.y = mouseY - canvas.y - componentInfo.height / 2;
        
        // Create loader for lazy loading
        const loader = Qt.createQmlObject('import QtQuick 2.15; Loader { anchors.fill: parent; asynchronous: true; }', placeholder);
        if (loader) {
            // Set source component
            const [importName, componentName] = componentType.split('.');
            loader.sourceComponent = getComponentFromCache(componentType);
            
            // When component is loaded, transfer properties and remove placeholder
            loader.onLoaded.connect(function() {
                const actualComponent = loader.item;
                if (actualComponent) {
                    // Transfer properties to actual component
                    actualComponent.width = placeholder.width;
                    actualComponent.height = placeholder.height;
                    actualComponent.x = placeholder.x;
                    actualComponent.y = placeholder.y;
                    
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

    // Add custom component to library
    function addCustomComponent(name, type, width, height, category) {
        const component = {
            name: name,
            type: type,
            width: width || 100,
            height: height || 100,
            category: category || "Custom"
        };
        componentLibrary.push(component);
        return component;
    }

    // Remove component from library
    function removeComponent(componentType) {
        const index = componentLibrary.findIndex(item => item.type === componentType);
        if (index >= 0) {
            componentLibrary.splice(index, 1);
            return true;
        }
        return false;
    }

    // Get component info by type
    function getComponentInfo(componentType) {
        return componentLibrary.find(item => item.type === componentType);
    }
}
