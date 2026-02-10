import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: layoutTemplateManager
    visible: false

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

    // Initialize layout template manager
    function init(canvasItem) {
        canvas = canvasItem;
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

    // Save current layout
    function saveLayout() {
        if (!canvas) return [];
        
        const layout = [];
        for (let i = 0; i < canvas.children.length; i++) {
            const item = canvas.children[i];
            layout.push({
                type: item.toString().split('(')[0],
                x: item.x,
                y: item.y,
                width: item.width,
                height: item.height,
                tagName: item.tagName || ""
            });
        }
        return layout;
    }

    // Load layout
    function loadLayout(layout) {
        if (!canvas || !Array.isArray(layout)) return;
        
        // Clear existing items
        for (let i = canvas.children.length - 1; i >= 0; i--) {
            canvas.children[i].destroy();
        }
        
        // Load layout items
        layout.forEach(function(itemInfo) {
            // Create component
            const [importName, componentName] = itemInfo.type.split('.');
            const component = Qt.createQmlObject('import QtQuick 2.15; import ' + importName + ' 1.0; ' + componentName + ' {}', canvas);
            if (component) {
                // Set properties
                component.x = itemInfo.x;
                component.y = itemInfo.y;
                component.width = itemInfo.width;
                component.height = itemInfo.height;
                if (itemInfo.tagName) {
                    component.tagName = itemInfo.tagName;
                }
            }
        });
    }

    // Remove layout template
    function removeLayoutTemplate(index) {
        if (index >= 0 && index < layoutTemplates.length) {
            layoutTemplates.splice(index, 1);
            return true;
        }
        return false;
    }

    // Update layout template
    function updateLayoutTemplate(index, name, description) {
        if (!canvas || index < 0 || index >= layoutTemplates.length) return false;
        
        const currentLayout = saveLayout();
        if (currentLayout.length === 0) return false;
        
        layoutTemplates[index] = {
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
        return true;
    }
}
