import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import "./themes"

/**
 * @brief 拖拽布局编辑器主界面
 * 
 * 提供完整的可视化布局编辑功能：
 * - 左侧组件库面板
 * - 中央画布区域
 * - 右侧属性编辑面板
 * - 顶部工具栏
 * - 支持组件的拖拽、选择、编辑
 */
ApplicationWindow {
    id: layoutEditor
    visible: true
    width: 1200
    height: 800
    title: "SCADA布局编辑器"
    
    // ==================== 属性定义 ====================
    property var placedComponents: []  // 已放置的组件列表
    property var selectedComponent: null  // 当前选中的组件
    property bool showGrid: true  // 是否显示网格
    property int gridSize: 20  // 网格大小
    
    // 主题
    property var theme: IndustrialTheme {}
    
    // ==================== 信号定义 ====================
    signal componentAdded(string componentType, point position)
    signal componentSelected(var component)
    signal componentMoved(var component, point newPosition)
    
    // ==================== 顶部工具栏 ====================
    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            spacing: 10
            
            ToolButton {
                text: "新建"
                icon.source: "qrc:/icons/new.png"
                onClicked: newProject()
            }
            
            ToolButton {
                text: "打开"
                icon.source: "qrc:/icons/open.png"
                onClicked: openProject()
            }
            
            ToolButton {
                text: "保存"
                icon.source: "qrc:/icons/save.png"
                onClicked: saveProject()
            }
            
            Item { Layout.fillWidth: true }  // 弹簧元素
            
            ToolButton {
                text: "网格"
                checkable: true
                checked: showGrid
                onClicked: showGrid = !showGrid
            }
            
            ToolButton {
                text: "预览"
                icon.source: "qrc:/icons/preview.png"
                onClicked: previewMode()
            }
        }
    }
    
    // ==================== 主要布局 ====================
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // 左侧组件库面板
        ComponentLibraryPanel {
            id: libraryPanel
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            
            onComponentSelected: {
                // 开始拖拽创建新组件
                var componentInfo = getComponentInfo(componentType)
                if (componentInfo) {
                    createNewComponent(componentType, position)
                }
            }
        }
        
        // 中央分割线
        Rectangle {
            width: 1
            color: "#dee2e6"
            Layout.fillHeight: true
        }
        
        // 中央画布区域
        Rectangle {
            id: canvasArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#fafafa"
            
            // 网格背景
            Repeater {
                model: showGrid ? ((canvasArea.width / gridSize) * (canvasArea.height / gridSize)) : 0
                
                Rectangle {
                    x: (index % Math.floor(canvasArea.width / gridSize)) * gridSize
                    y: Math.floor(index / Math.floor(canvasArea.width / gridSize)) * gridSize
                    width: 1
                    height: 1
                    color: "#e9ecef"
                    visible: showGrid
                }
            }
            
            // 组件放置区域
            DropArea {
                anchors.fill: parent
                keys: ["component"]
                
                onDropped: {
                    // 处理组件放置
                    var dropX = drop.x - 60  // 调整为中心点
                    var dropY = drop.y - 40
                    createComponentAt(drop.drag.source.componentType, dropX, dropY)
                }
                
                // 已放置的组件
                Repeater {
                    model: placedComponents
                    
                    DraggableIndustrialComponent {
                        id: placedComponent
                        x: modelData.x
                        y: modelData.y
                        width: modelData.width
                        height: modelData.height
                        componentName: modelData.name
                        componentType: modelData.type
                        boundTag: modelData.boundTag || ""
                        
                        onSelectedChanged: {
                            if (isSelected) {
                                layoutEditor.selectedComponent = placedComponent
                                componentSelected(placedComponent)
                            }
                        }
                        
                        onMoved: {
                            // 更新组件位置
                            modelData.x = newX
                            modelData.y = newY
                            componentMoved(placedComponent, Qt.point(newX, newY))
                        }
                        
                        onDoubleClicked: {
                            // 双击编辑组件属性
                            editComponentProperties(placedComponent)
                        }
                    }
                }
            }
            
            // 画布标题
            Text {
                anchors.centerIn: parent
                text: "拖拽组件到此处进行布局设计"
                color: "#adb5bd"
                font.pixelSize: 16
                visible: placedComponents.length === 0
            }
        }
        
        // 右侧分割线
        Rectangle {
            width: 1
            color: "#dee2e6"
            Layout.fillHeight: true
        }
        
        // 右侧属性面板
        Rectangle {
            id: propertyPanel
            Layout.preferredWidth: 280
            Layout.fillHeight: true
            color: "#f8f9fa"
            border.color: "#dee2e6"
            border.width: 1
            
            // 属性面板标题
            Rectangle {
                id: propertyHeader
                height: 40
                color: "#e9ecef"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                
                Text {
                    anchors.centerIn: parent
                    text: selectedComponent ? selectedComponent.componentName : "属性面板"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#495057"
                }
            }
            
            // 属性内容区域
            ScrollView {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: propertyHeader.bottom
                anchors.bottom: parent.bottom
                anchors.margins: 10
                
                Column {
                    width: parent.width
                    spacing: 15
                    
                    // 位置属性
                    GroupBox {
                        title: "位置和尺寸"
                        width: parent.width
                        
                        GridLayout {
                            columns: 2
                            rowSpacing: 10
                            columnSpacing: 10
                            
                            Label { text: "X坐标:" }
                            SpinBox {
                                value: selectedComponent ? selectedComponent.x : 0
                                onValueChanged: if (selectedComponent) selectedComponent.moveTo(value, selectedComponent.y)
                            }
                            
                            Label { text: "Y坐标:" }
                            SpinBox {
                                value: selectedComponent ? selectedComponent.y : 0
                                onValueChanged: if (selectedComponent) selectedComponent.moveTo(selectedComponent.x, value)
                            }
                            
                            Label { text: "宽度:" }
                            SpinBox {
                                value: selectedComponent ? selectedComponent.width : 120
                                onValueChanged: if (selectedComponent) selectedComponent.resize(value, selectedComponent.height)
                            }
                            
                            Label { text: "高度:" }
                            SpinBox {
                                value: selectedComponent ? selectedComponent.height : 80
                                onValueChanged: if (selectedComponent) selectedComponent.resize(selectedComponent.width, value)
                            }
                        }
                    }
                    
                    // 数据绑定属性
                    GroupBox {
                        title: "数据绑定"
                        width: parent.width
                        visible: selectedComponent !== null
                        
                        Column {
                            width: parent.width
                            spacing: 10
                            
                            Label { 
                                text: "绑定标签:"
                                font.bold: true
                            }
                            
                            ComboBox {
                                model: ["temperature", "pressure", "flow_rate", "motor_status", "valve_position"]
                                width: parent.width
                                onActivated: {
                                    if (selectedComponent) {
                                        selectedComponent.boundTag = currentText
                                    }
                                }
                            }
                        }
                    }
                    
                    // 组件信息
                    GroupBox {
                        title: "组件信息"
                        width: parent.width
                        visible: selectedComponent !== null
                        
                        GridLayout {
                            columns: 2
                            rowSpacing: 8
                            columnSpacing: 10
                            
                            Label { text: "ID:" }
                            Label { 
                                text: selectedComponent ? selectedComponent.componentId : ""
                                color: "#6c757d"
                            }
                            
                            Label { text: "类型:" }
                            Label { 
                                text: selectedComponent ? selectedComponent.componentType : ""
                                color: "#6c757d"
                            }
                        }
                    }
                }
            }
        }
    }
    
    // ==================== 方法实现 ====================
    
    /**
     * @brief 创建新组件
     */
    function createNewComponent(componentType, startPosition) {
        var componentInfo = libraryPanel.getComponentInfo(componentType)
        if (componentInfo) {
            var newComponent = {
                "id": "comp_" + Date.now(),
                "name": componentInfo.name,
                "type": componentType,
                "x": startPosition.x,
                "y": startPosition.y,
                "width": 120,
                "height": 80,
                "boundTag": ""
            }
            
            placedComponents.push(newComponent)
            componentAdded(componentType, startPosition)
            console.log("创建新组件:", componentInfo.name)
        }
    }
    
    /**
     * @brief 在指定位置创建组件
     */
    function createComponentAt(componentType, x, y) {
        var componentInfo = libraryPanel.getComponentInfo(componentType)
        if (componentInfo) {
            var newComponent = {
                "id": "comp_" + Date.now(),
                "name": componentInfo.name,
                "type": componentType,
                "x": x,
                "y": y,
                "width": 120,
                "height": 80,
                "boundTag": ""
            }
            
            placedComponents.push(newComponent)
            componentAdded(componentType, Qt.point(x, y))
        }
    }
    
    /**
     * @brief 编辑组件属性
     */
    function editComponentProperties(component) {
        selectedComponent = component
        console.log("编辑组件属性:", component.componentName)
    }
    
    /**
     * @brief 新建项目
     */
    function newProject() {
        placedComponents = []
        selectedComponent = null
        console.log("新建项目")
    }
    
    /**
     * @brief 打开项目
     */
    function openProject() {
        console.log("打开项目")
        // TODO: 实现项目文件加载
    }
    
    /**
     * @brief 保存项目
     */
    function saveProject() {
        console.log("保存项目")
        // TODO: 实现项目文件保存
    }
    
    /**
     * @brief 预览模式
     */
    function previewMode() {
        console.log("进入预览模式")
        // TODO: 实现预览功能
    }
}