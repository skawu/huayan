import QtQuick 2.15
import QtQuick.Controls 2.15
import "modules/helpers"

Item {
    id: dragAndDropHelper
    visible: false

    // Submodules
    DragDropCore {
        id: dragDropCore
    }

    CanvasOperations {
        id: canvasOperations
    }

    VisualFeedback {
        id: visualFeedback
    }

    ComponentLibraryManager {
        id: componentLibraryManager
    }

    LayoutTemplateManager {
        id: layoutTemplateManager
    }

    // Initialize all modules
    function init(canvasItem) {
        dragDropCore.init(canvasItem);
        canvasOperations.init(canvasItem);
        visualFeedback.init(canvasItem);
        componentLibraryManager.init(canvasItem);
        layoutTemplateManager.init(canvasItem);
    }

    // Drag and drop operations
    function startDrag(item, mouseX, mouseY) {
        dragDropCore.startDrag(item, mouseX, mouseY);
        visualFeedback.createDragPreview(item);
    }

    function endDrag() {
        dragDropCore.endDrag();
        visualFeedback.clearAll();
    }

    function handleMouseMove(mouseX, mouseY) {
        dragDropCore.handleMouseMove(mouseX, mouseY);
        if (dragDropCore.isDragging && dragDropCore.draggedItem) {
            const newX = dragDropCore.draggedItem.x;
            const newY = dragDropCore.draggedItem.y;
            visualFeedback.updateDragPreview(newX, newY);
            visualFeedback.showAlignmentGuides(dragDropCore.draggedItem, newX, newY);
        }
    }

    // Canvas operations
    function zoomCanvas(factor, mouseX, mouseY) {
        canvasOperations.zoomCanvas(factor, mouseX, mouseY);
    }

    function resetCanvasTransform() {
        canvasOperations.resetCanvasTransform();
    }

    function fitCanvasToView() {
        canvasOperations.fitCanvasToView();
    }

    function setGridSize(size) {
        canvasOperations.setGridSize(size);
    }

    function toggleGridVisibility() {
        canvasOperations.toggleGridVisibility();
    }

    // Component library operations
    function startDragFromLibrary(componentType, mouseX, mouseY) {
        return componentLibraryManager.startDragFromLibrary(componentType, mouseX, mouseY);
    }

    function getComponentCategories() {
        return componentLibraryManager.getComponentCategories();
    }

    function getComponentsByCategory(category) {
        return componentLibraryManager.getComponentsByCategory(category);
    }

    function searchComponents(query) {
        return componentLibraryManager.searchComponents(query);
    }

    // Layout template operations
    function getLayoutTemplates() {
        return layoutTemplateManager.getLayoutTemplates();
    }

    function applyLayoutTemplate(index) {
        layoutTemplateManager.applyLayoutTemplate(index);
    }

    function applyLayoutTemplateByName(name) {
        layoutTemplateManager.applyLayoutTemplateByName(name);
    }

    function saveCurrentLayoutAsTemplate(name, description) {
        return layoutTemplateManager.saveCurrentLayoutAsTemplate(name, description);
    }

    // Selection operations
    function selectItem(item) {
        dragDropCore.selectItem(item);
    }

    function clearSelection() {
        dragDropCore.clearSelection();
    }

    function getSelectedItems() {
        return dragDropCore.selectedItems;
    }

    // Layer operations
    function moveItemUp(item) {
        dragDropCore.moveItemUp(item);
    }

    function moveItemDown(item) {
        dragDropCore.moveItemDown(item);
    }

    function moveItemToTop(item) {
        dragDropCore.moveItemToTop(item);
    }

    function moveItemToBottom(item) {
        dragDropCore.moveItemToBottom(item);
    }

    function moveSelectedItemsUp() {
        dragDropCore.moveSelectedItemsUp();
    }

    function moveSelectedItemsDown() {
        dragDropCore.moveSelectedItemsDown();
    }

    function moveSelectedItemsToTop() {
        dragDropCore.moveSelectedItemsToTop();
    }

    function moveSelectedItemsToBottom() {
        dragDropCore.moveSelectedItemsToBottom();
    }

    // Batch operations
    function batchUpdateProperties(properties) {
        dragDropCore.batchUpdateProperties(properties);
    }

    // Visual feedback operations
    function toggleAlignmentGuides() {
        visualFeedback.toggleAlignmentGuides();
    }

    function isAlignmentGuidesVisible() {
        return visualFeedback.isAlignmentGuidesVisible();
    }

    // Getters
    function getGridSize() {
        return canvasOperations.getGridSize();
    }

    function isGridVisible() {
        return canvasOperations.isGridVisible();
    }

    // Setup drag handlers for item
    function setupDragHandlers(item) {
        dragDropCore.setupDragHandlers(item);
    }
}
