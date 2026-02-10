import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: visualFeedback
    visible: false

    // Visual feedback properties
    property var dragPreview: null
    property var alignmentGuides: []
    property bool showAlignmentGuides: true

    // Canvas properties
    property Item canvas: null

    // Initialize visual feedback
    function init(canvasItem) {
        canvas = canvasItem;
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
    
    // Clear drag preview
    function clearDragPreview() {
        if (dragPreview) {
            dragPreview.destroy();
            dragPreview = null;
        }
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
            if (otherItem !== item && otherItem !== dragPreview) {
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

    // Clear all visual feedback
    function clearAll() {
        clearDragPreview();
        clearAlignmentGuides();
    }

    // Toggle alignment guides visibility
    function toggleAlignmentGuides() {
        showAlignmentGuides = !showAlignmentGuides;
        if (!showAlignmentGuides) {
            clearAlignmentGuides();
        }
    }

    // Get alignment guides visibility
    function isAlignmentGuidesVisible() {
        return showAlignmentGuides;
    }
}
