import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: propertyPanelManager
    visible: false

    // Properties
    property var currentItem: null
    property var selectedItems: []
    property var propertyCategories: [
        { name: "Basic", title: "基本属性" },
        { name: "Style", title: "样式属性" },
        { name: "DataBinding", title: "数据绑定" },
        { name: "Behavior", title: "行为属性" }
    ]

    // Initialize property panel manager
    function init() {
        // Initialization code if needed
    }

    // Set current item for property editing
    function setCurrentItem(item) {
        currentItem = item;
        selectedItems = item ? [item] : [];
        updateProperties();
    }

    // Set selected items for batch editing
    function setSelectedItems(items) {
        selectedItems = items || [];
        currentItem = items && items.length > 0 ? items[0] : null;
        updateProperties();
    }

    // Update properties based on current selection
    function updateProperties() {
        if (!currentItem) {
            clearProperties();
            return;
        }

        // Generate property model based on current item
        const properties = generatePropertyModel(currentItem);
        return properties;
    }

    // Generate property model for an item
    function generatePropertyModel(item) {
        const properties = [];

        // Basic properties
        properties.push({
            category: "Basic",
            name: "x",
            title: "X坐标",
            type: "number",
            value: item.x,
            min: 0,
            max: 10000,
            step: 1
        });

        properties.push({
            category: "Basic",
            name: "y",
            title: "Y坐标",
            type: "number",
            value: item.y,
            min: 0,
            max: 10000,
            step: 1
        });

        properties.push({
            category: "Basic",
            name: "width",
            title: "宽度",
            type: "number",
            value: item.width,
            min: 10,
            max: 5000,
            step: 1
        });

        properties.push({
            category: "Basic",
            name: "height",
            title: "高度",
            type: "number",
            value: item.height,
            min: 10,
            max: 5000,
            step: 1
        });

        // Style properties (if applicable)
        if (item.hasOwnProperty("color")) {
            properties.push({
                category: "Style",
                name: "color",
                title: "颜色",
                type: "color",
                value: item.color
            });
        }

        if (item.hasOwnProperty("opacity")) {
            properties.push({
                category: "Style",
                name: "opacity",
                title: "透明度",
                type: "number",
                value: item.opacity,
                min: 0,
                max: 1,
                step: 0.1
            });
        }

        // Text properties (if applicable)
        if (item.hasOwnProperty("text")) {
            properties.push({
                category: "Basic",
                name: "text",
                title: "文本",
                type: "string",
                value: item.text
            });
        }

        // Rotation property
        if (item.hasOwnProperty("rotation")) {
            properties.push({
                category: "Basic",
                name: "rotation",
                title: "旋转角度",
                type: "number",
                value: item.rotation,
                min: 0,
                max: 360,
                step: 1
            });
        }

        // Data binding properties
        if (item.hasOwnProperty("tagName")) {
            properties.push({
                category: "DataBinding",
                name: "tagName",
                title: "标签名称",
                type: "string",
                value: item.tagName
            });
        }

        return properties;
    }

    // Update property value
    function updateProperty(propertyName, value) {
        if (!currentItem) return;

        // Update current item
        if (currentItem.hasOwnProperty(propertyName)) {
            currentItem[propertyName] = value;
        }

        // Update all selected items for batch editing
        if (selectedItems.length > 1) {
            selectedItems.forEach(function(item) {
                if (item.hasOwnProperty(propertyName)) {
                    item[propertyName] = value;
                }
            });
        }
    }

    // Clear properties
    function clearProperties() {
        // Clear property model
        return [];
    }

    // Get property categories
    function getPropertyCategories() {
        return propertyCategories;
    }

    // Get properties by category
    function getPropertiesByCategory(category) {
        const properties = updateProperties();
        return properties.filter(function(property) {
            return property.category === category;
        });
    }

    // Check if property is editable
    function isPropertyEditable(propertyName) {
        // Some properties might be read-only
        const readOnlyProperties = ["id", "objectName"];
        return !readOnlyProperties.includes(propertyName);
    }

    // Validate property value
    function validateProperty(propertyName, value) {
        // Basic validation
        if (propertyName === "width" || propertyName === "height") {
            return value >= 10;
        }
        if (propertyName === "opacity") {
            return value >= 0 && value <= 1;
        }
        return true;
    }

    // Get property display value
    function getPropertyDisplayValue(propertyName, value) {
        // Format value for display
        if (typeof value === "number") {
            return value.toFixed(2);
        }
        return value;
    }
}
