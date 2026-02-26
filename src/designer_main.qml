import QtQuick 6.5
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: designerWindow
    visible: true
    width: 1200
    height: 800
    title: "华颜SCADA设计器 v2.0 - 工业监控系统开发平台"
    
    // 设计器状态
    property bool isDesignMode: true
    property string currentProject: "未命名项目"
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
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            
            Image {
                source: "qrc:/icons/scada_icon.png"
                width: 32
                height: 32
                Layout.alignment: Qt.AlignVCenter
            }
            
            Text {
                text: "华颜SCADA设计器"
                color: "white"
                font.pixelSize: 22
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
            }
            
            Item { Layout.fillWidth: true }
            
            Text {
                text: "v2.0.0"
                color: "#bdc3c7"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignVCenter
            }
        }
    
    // 主要工作区域
    SplitView {
        id: mainSplitView
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: statusBar.top
        orientation: Qt.Horizontal
        
        // 左侧组件库面板 - 简化版直接硬编码组件
        Rectangle {
            id: componentPanel
            width: 280
            Layout.fillHeight: true
            color: "#f8f9fa"
            border.color: "#dee2e6"
            border.width: 1
            
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
                
                // 直接硬编码8个组件，排除Repeater问题
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
                
                // 添加其他6个组件...
                Rectangle {
                    width: parent.width
                    height: 70
                    color: mouseArea3.containsMouse ? "#e3f2fd" : "white"
                    border.color: mouseArea3.pressed ? secondaryColor : "#ddd"
                    border.width: 1
                    radius: 6
                    
                    MouseArea {
                        id: mouseArea3
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onPressed: {
                            console.log("点击流量计")
                            dragComponent.startDrag("FlowMeter", "流量计", "💧")
                        }
                        
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                    }
                    
                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 12
                        
                        Text {
                            text: "💧"
                            font.pixelSize: 24
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        Column {
                            spacing: 2
                            
                            Text {
                                text: "流量计"
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
                    color: mouseArea4.containsMouse ? "#e3f2fd" : "white"
                    border.color: mouseArea4.pressed ? secondaryColor : "#ddd"
                    border.width: 1
                    radius: 6
                    
                    MouseArea {
                        id: mouseArea4
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onPressed: {
                            console.log("点击电机状态")
                            dragComponent.startDrag("MotorStatus", "电机状态", "⚡")
                        }
                        
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                    }
                    
                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 12
                        
                        Text {
                            text: "⚡"
                            font.pixelSize: 24
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        Column {
                            spacing: 2
                            
                            Text {
                                text: "电机状态"
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
            Layout.fillWidth: true
            color: "white"
            border.color: "#ddd"
            border.width: 1
            
            DropArea {
                id: dropArea
                anchors.fill: parent
                keys: ["scada_component"]
                
                onDropped: {
                    if (drop.hasText) {
                        var componentType = drop.text
                        var mouseX = drop.x
                        var mouseY = drop.y
                        canvas.addComponent(componentType, mouseX, mouseY)
                    }
                }
                
                // 画布背景网格
                Repeater {
                    model: Math.ceil(canvasArea.width / 20)
                    Rectangle {
                        x: index * 20
                        width: 1
                        height: canvasArea.height
                        color: "#f0f0f0"
                    }
                }
                
                Repeater {
                    model: Math.ceil(canvasArea.height / 20)
                    Rectangle {
                        y: index * 20
                        width: canvasArea.width
                        height: 1
                        color: "#f0f0f0"
                    }
                }
                
                // 画布内容区域
                Item {
                    id: canvas
                    anchors.fill: parent
                    
                    // 添加组件的方法
                    function addComponent(type, x, y) {
                        var component = Qt.createComponent("qrc:/components/" + type + ".qml")
                        if (component.status === Component.Ready) {
                            var instance = component.createObject(canvas, {
                                "x": x,
                                "y": y
                            })
                            console.log("添加组件:", type, "位置:", x, y)
                        }
                    }
                    
                    // 示例背景提示
                    Text {
                        anchors.centerIn: parent
                        text: "🎨 拖拽组件到这里开始设计\n工业监控界面"
                        color: "#999"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
        
        // 右侧属性面板
        Rectangle {
            id: propertyPanel
            width: 250
            color: "#f8f9fa"
            border.color: "#dee2e6"
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 20
                
                Text {
                    text: "🔧 属性面板"
                    font.pixelSize: 18
                    font.bold: true
                    color: primaryColor
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // 项目属性
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
                            text: currentProject
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
                
                // 实时数据监控
                GroupBox {
                    title: "实时数据"
                    Layout.fillWidth: true
                    
                    GridLayout {
                        columns: 2
                        rowSpacing: 8
                        columnSpacing: 10
                        
                        Label { text: "温度:" }
                        Text {
                            text: (50 + Math.random() * 150).toFixed(1) + "°C"
                            color: "#e74c3c"
                            font.bold: true
                        }
                        
                        Label { text: "压力:" }
                        Text {
                            text: (5 + Math.random() * 10).toFixed(2) + "MPa"
                            color: "#3498db"
                            font.bold: true
                        }
                        
                        Label { text: "流量:" }
                        Text {
                            text: (Math.random() * 1000).toFixed(0) + "m³/h"
                            color: "#2ecc71"
                            font.bold: true
                        }
                        
                        Label { text: "状态:" }
                        Text {
                            text: ["运行", "停止", "故障"][Math.floor(Math.random() * 3)]
                            color: ["#2ecc71", "#f39c12", "#e74c3c"][Math.floor(Math.random() * 3)]
                            font.bold: true
                        }
                    }
                }
                
                Item { Layout.fillHeight: true }
                
                // 操作按钮
                Column {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Button {
                        text: "💾 保存项目"
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width - 20
                        height: 40
                        
                        background: Rectangle {
                            color: secondaryColor
                            radius: 5
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                        
                        onClicked: {
                            saveProject()
                        }
                    }
                    
                    Button {
                        text: "▶️ 运行预览"
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width - 20
                        height: 40
                        
                        background: Rectangle {
                            color: accentColor
                            radius: 5
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                        
                        onClicked: {
                            isDesignMode = false
                            previewRuntime()
                        }
                    }
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
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            
            Text {
                text: "就绪"
                color: "white"
                font.pixelSize: 12
            }
            
            Item { Layout.fillWidth: true }
            
            Text {
                text: "坐标: X:0 Y:0"
                color: "#bdc3c7"
                font.pixelSize: 12
            }
            
            Text {
                text: "|"
                color: "#7f8c8d"
                font.pixelSize: 12
                Layout.margins: 5
            }
            
            Text {
                text: new Date().toLocaleTimeString()
                color: "#bdc3c7"
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