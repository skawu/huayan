import QtQuick 6.5
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: designerWindow
    visible: true
    width: 1000
    height: 700
    title: "华颜SCADA设计器 v2.0 - 工业监控系统开发平台"
    
    // 设计器状态
    property bool isDesignMode: true
    property string currentProject: "测试项目"
    property int selectedTool: 0  // 0:选择, 1:拖拽组件, 2:连线
    
    // 主题颜色定义
    readonly property color primaryColor: "#2c3e50"
    readonly property color secondaryColor: "#3498db"
    readonly property color accentColor: "#2ecc71"
    readonly property color backgroundColor: "#ecf0f1"
    readonly property color textColor: "#2c3e50"
    
    // 顶部标题栏
    Rectangle {
        id: headerBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: primaryColor
        
        Text {
            text: "华颜SCADA设计器 v2.0 - 工业监控系统开发平台"
            color: "white"
            font.pixelSize: 16
            anchors.centerIn: parent
        }
    
    // 主要工作区域
    SplitView {
        id: mainSplitView
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: statusBar.top
        orientation: Qt.Horizontal
        
        // 左侧组件库面板 - 使用Qt 6正确的SplitView约束
        Rectangle {
            id: componentPanel
            color: "#f8f9fa"
            border.color: "#dee2e6"
            border.width: 1
            
            // 使用SplitView附加属性设置尺寸
            SplitView.preferredWidth: 280
            SplitView.minimumWidth: 200
            SplitView.maximumWidth: 350
            
            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                
                Text {
                    text: "📊 组件库"
                    font.pixelSize: 18
                    font.bold: true
                    color: primaryColor
                    horizontalAlignment: Text.AlignHCenter
                }
                
                // 直接硬编码4个组件
                Rectangle {
                    width: parent.width
                    height: 70
                    color: mouseArea1.containsMouse ? "#e3f2fd" : "white"
                    border.color: mouseArea1.pressed ? secondaryColor : "#ddd"
                    border.width: 1
                    radius: 6
                    
                    MouseArea {
                        id: mouseArea1
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onPressed: {
                            console.log("点击温度显示器")
                            dragComponent.startDrag("TemperatureDisplay", "温度显示器", "🌡️")
                        }
                        
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                    }
                    
                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 12
                        
                        Text {
                            text: "🌡️"
                            font.pixelSize: 24
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        Column {
                            spacing: 2
                            
                            Text {
                                text: "温度显示器"
                                font.pixelSize: 13
                                font.bold: true
                                color: primaryColor
                            }
                            
                            Text {
                                text: "工业组件"
                                font.pixelSize: 10
                                color: "#666"
                            }
                        }
                    }
                }
                
                Rectangle {
                    width: parent.width
                    height: 70
                    color: mouseArea2.containsMouse ? "#e3f2fd" : "white"
                    border.color: mouseArea2.pressed ? secondaryColor : "#ddd"
                    border.width: 1
                    radius: 6
                    
                    MouseArea {
                        id: mouseArea2
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onPressed: {
                            console.log("点击压力仪表")
                            dragComponent.startDrag("PressureGauge", "压力仪表", "⚙️")
                        }
                        
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                    }
                    
                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 12
                        
                        Text {
                            text: "⚙️"
                            font.pixelSize: 24
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        Column {
                            spacing: 2
                            
                            Text {
                                text: "压力仪表"
                                font.pixelSize: 13
                                font.bold: true
                                color: primaryColor
                            }
                            
                            Text {
                                text: "工业组件"
                                font.pixelSize: 10
                                color: "#666"
                            }
                        }
                    }
                }
            }
        }
        
        // 中央画布区域
        Rectangle {
            id: canvasArea
            color: "white"
            border.color: "#ddd"
            border.width: 1
            
            Text {
                anchors.centerIn: parent
                text: "🎨 中央画布\n拖拽组件到这里"
                color: "#999"
                font.pixelSize: 16
            }
        }
        
        // 右侧属性面板
        Rectangle {
            id: propertyPanel
            color: "#f8f9fa"
            border.color: "#dee2e6"
            border.width: 1
            
            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 20
                
                Text {
                    text: "🔧 属性面板"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#2c3e50"
                    horizontalAlignment: Text.AlignHCenter
                }
                
                // 项目设置区域
                GroupBox {
                    title: "项目设置"
                    Layout.fillWidth: true
                    
                    ColumnLayout {
                        width: parent.width
                        spacing: 10
                        
                        Label {
                            text: "项目名称:"
                            font.bold: true
                        }
                        TextField {
                            text: "测试项目"
                            Layout.fillWidth: true
                        }
                        
                        Label {
                            text: "更新频率:"
                            font.bold: true
                        }
                        ComboBox {
                            model: ["1秒", "2秒", "5秒", "10秒"]
                            currentIndex: 0
                            Layout.fillWidth: true
                        }
                    }
                }
                
                // 实时数据监控区域
                GroupBox {
                    title: "实时数据"
                    Layout.fillWidth: true
                    
                    GridLayout {
                        columns: 2
                        rowSpacing: 8
                        columnSpacing: 10
                        
                        Label { text: "温度:" }
                        Text {
                            text: "93.0°C"
                            color: "#e74c3c"
                            font.bold: true
                        }
                        
                        Label { text: "压力:" }
                        Text {
                            text: "10.5MPa"
                            color: "#3498db"
                            font.bold: true
                        }
                        
                        Label { text: "流量:" }
                        Text {
                            text: "458m³/h"
                            color: "#2ecc71"
                            font.bold: true
                        }
                        
                        Label { text: "状态:" }
                        Text {
                            text: "运行"
                            color: "#27ae60"
                            font.bold: true
                        }
                    }
                }
                
                // 项目名称显示
                Text {
                    text: "项目名称: 测试项目"
                    font.bold: true
                    color: "#2c3e50"
                    horizontalAlignment: Text.AlignLeft
                }
            }
        }
    }
    
    // 底部状态栏
    Rectangle {
        id: statusBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 30
        color: primaryColor
        
        Row {
            anchors.fill: parent
            anchors.margins: 5
            
            Text {
                text: "就绪"
                color: "white"
                font.pixelSize: 12
            }
            
            Item {
                Layout.fillWidth: true
            }
            
            Text {
                text: "坐标: X:0 Y:0"
                color: "white"
                font.pixelSize: 12
            }
            
            Text {
                text: "中国标准时间 " + new Date().toLocaleTimeString()
                color: "white"
                font.pixelSize: 12
            }
        }
    }
    
    // 拖拽组件管理器
    Item {
        id: dragComponent
        
        function startDrag(componentType, componentName, icon) {
            console.log("开始拖拽:", componentType)
            // 这里可以实现真正的拖拽逻辑
        }
    }
    
    // 消息提示函数
    function showMessage(message) {
        var component = Qt.createComponent("InfoDialog.qml")
        if (component.status === Component.Ready) {
            var dialog = component.createObject(designerWindow, {
                "message": message
            })
            dialog.open()
        }
    }
    
    // 初始化完成提示
    Component.onCompleted: {
        console.log("=== SCADA设计器启动完成 ===")
        console.log("版本: 2.0.0")
        console.log("Qt版本:", Qt.version)
        console.log("组件库: 8个工业组件")
        console.log("功能: 拖拽布局、实时监控、双模式切换")
        console.log("============================")
        
        showMessage("🎉 SCADA设计器启动成功！\n\n您可以:\n• 从左侧拖拽组件到画布\n• 在右侧调整属性参数\n• 实时监控数据变化\n• 保存和运行项目")
    }
    
    // 当前选中组件
    property var selectedComponent: null
    property string currentComponentType: ""
    
    // 项目操作函数
    function newProject() {
        console.log("创建新项目")
        currentProject = "未命名项目"
        // 清空画布
        clearCanvas()
    }
    
    function openProject() {
        console.log("打开项目")
        // 实现文件选择对话框
    }
    
    function saveProject() {
        console.log("保存项目")
        // 实现项目保存逻辑
    }
    
    function exportProject() {
        console.log("导出项目")
        // 实现项目导出逻辑
    }
    
    function previewRuntime() {
        console.log("预览运行时")
        // 切换到运行时预览模式
    }
    
    function clearCanvas() {
        // 清空画布内容
        while(canvas.children.length > 0) {
            canvas.children[0].destroy()
        }
    }
}
}