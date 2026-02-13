import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: appCore
    
    // 应用状态
    property string currentProjectName: "未命名项目"
    property int currentPageIndex: 0
    property real canvasScale: 1.0
    property real canvasOffsetX: 0
    property real canvasOffsetY: 0
    
    // 初始化
    function initialize() {
        console.log("AppCore initialized")
        // 初始化各个模块
        pageManager.initialize()
        dataBindingHelper.initialize()
        alarmManager.initialize()
        trendManager.initialize()
    }
    
    // 项目管理
    function newProject() {
        console.log("New project")
        pageManager.resetPages()
    }
    
    function openProject() {
        console.log("Open project")
    }
    
    function saveProject() {
        console.log("Save project")
        pageManager.saveAllPages()
    }
    
    function exportProject() {
        console.log("Export project")
    }
    
    function importProject() {
        console.log("Import project")
    }
    
    // 画布操作
    function zoomCanvas(factor, mouseX, mouseY) {
        console.log("Zoom canvas:", factor)
    }
    
    function panCanvas(deltaX, deltaY) {
        console.log("Pan canvas:", deltaX, deltaY)
    }
    
    // 组件操作
    function selectComponent(component) {
        console.log("Select component:", component)
    }
    
    function deselectComponent(component) {
        console.log("Deselect component:", component)
    }
    
    function deleteComponent(component) {
        console.log("Delete component:", component)
    }
}