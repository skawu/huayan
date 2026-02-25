import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import "./themes"

ApplicationWindow {
    id: designerWindow
    visible: true
    width: 1200
    height: 800
    title: "Huayan SCADA Designer"
    
    // 设计器状态
    property bool isDesignMode: true
    property string currentProject: ""
    property int selectedTool: 0  // 0:选择, 1:拖拽组件, 2:连线
    
    // 主题
    property var theme: IndustrialTheme {}
    
    // 工具栏
    header: Rectangle {
        height: 60
        color: theme.primaryColor
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 15
            
            // Logo和标题
            RowLayout {
                spacing: 10
                
                Text {
                    text: "🎨"
                    font.pixelSize: 24
                }
                
                Text {
                    text: "Huayan Designer"
                    font.pixelSize: 18
                    font.bold: true
                    color: theme.textLight
                }
            }
            
            Item { Layout.fillWidth: true }
            
            // 项目操作
            RowLayout {
                spacing: 5
                
                Button {
                    text: "📁 新建"
                    onClicked: newProject()
                }
                
                Button {
                    text: "📂 打开"
                    onClicked: openProject()
                }
                
                Button {
                    text: "💾 保存"
                    onClicked: saveProject()
                }
                
                Button {
                    text: "📤 导出"
                    onClicked: exportProject()
                }
            }
            
            // 运行模式切换
            Switch {
                text: "设计模式"
                checked: isDesignMode
                onCheckedChanged: {
                    isDesignMode = checked
                    if (!checked) {
                        // 切换到运行模式预览
                        previewRuntime()
                    }
                }
            }
        }
    }
    
    // 主工作区
    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        
        // 左侧组件库面板
        Rectangle {
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            color: theme.surfaceColor
            border.color: theme.borderColor
            border.width: 1
            radius: 8
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15
                
                // 组件分类标题
                Text {
                    text: "🧩 组件库"
                    font.pixelSize: 16
                    font.bold: true
                    color: theme.textPrimary
                }
                
                // 基础组件
                GroupBox {
                    title: "基础组件"
                    Layout.fillWidth: true
                    
                    Column {
                        spacing: 8
                        
                        Repeater {
                            model: ListModel {
                                ListElement { name: "指示灯"; type: "Indicator"; icon: "🔴" }
                                ListElement { name: "按钮"; type: "PushButton"; icon: "🔘" }
                                ListElement { name: "文本标签"; type: "TextLabel"; icon: "📝" }
                            }
                            
                            delegate: Button {
                                text: model.icon + " " + model.name
                                width: parent.width
                                onClicked: {
                                    selectedTool = 1
                                    currentComponentType = model.type
                                }
                            }
                        }
                    }
                }
                
                // 工业组件
                GroupBox {
                    title: "工业组件"
                    Layout.fillWidth: true
                    
                    Column {
                        spacing: 8
                        
                        Repeater {
                            model: ListModel {
                                ListElement { name: "阀门"; type: "Valve"; icon: "🔐" }
                                ListElement { name: "储罐"; type: "Tank"; icon: "📦" }
                                ListElement { name: "电机"; type: "Motor"; icon: "⚙️" }
                                ListElement { name: "泵"; type: "Pump"; icon: "🔄" }
                                ListElement { name: "仪表盘"; type: "Gauge"; icon: "📊" }
                            }
                            
                            delegate: Button {
                                text: model.icon + " " + model.name
                                width: parent.width
                                onClicked: {
                                    selectedTool = 1
                                    currentComponentType = model.type
                                }
                            }
                        }
                    }
                }
                
                // 图表组件
                GroupBox {
                    title: "图表组件"
                    Layout.fillWidth: true
                    
                    Column {
                        spacing: 8
                        
                        Repeater {
                            model: ListModel {
                                ListElement { name: "趋势图"; type: "TrendChart"; icon: "📈" }
                                ListElement { name: "柱状图"; type: "BarChart"; icon: "📊" }
                            }
                            
                            delegate: Button {
                                text: model.icon + " " + model.name
                                width: parent.width
                                onClicked: {
                                    selectedTool = 1
                                    currentComponentType = model.type
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // 中央画布区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#2d2d2d"
            border.color: theme.borderColor
            border.width: 1
            radius: 8
            
            // 网格背景
            Grid {
                id: grid
                anchors.fill: parent
                anchors.margins: 20
                rows: Math.floor((parent.height - 40) / 20)
                columns: Math.floor((parent.width - 40) / 20)
                spacing: 20
                
                Repeater {
                    model: grid.rows * grid.columns
                    
                    Rectangle {
                        width: 1
                        height: 1
                        color: "#444444"
                    }
                }
            }
            
            // 画布内容区域
            Item {
                id: canvas
                anchors.fill: parent
                anchors.margins: 20
                
                // 示例组件（后续会被动态创建的组件替换）
                Rectangle {
                    x: 100
                    y: 100
                    width: 120
                    height: 80
                    color: theme.cardColor
                    border.color: theme.primaryColor
                    border.width: 2
                    radius: 8
                    
                    Text {
                        anchors.centerIn: parent
                        text: "拖拽组件到这里\n开始设计"
                        color: theme.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
            
            // 画布工具栏
            Row {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 10
                spacing: 5
                
                Button {
                    text: "➕"
                    tooltip: "放大"
                    onClicked: {
                        // 放大画布
                    }
                }
                
                Button {
                    text: "➖"
                    tooltip: "缩小"
                    onClicked: {
                        // 缩小画布
                    }
                }
                
                Button {
                    text: "↺"
                    tooltip: "撤销"
                    onClicked: {
                        // 撤销操作
                    }
                }
                
                Button {
                    text: "↻"
                    tooltip: "重做"
                    onClicked: {
                        // 重做操作
                    }
                }
            }
        }
        
        // 右侧属性面板
        Rectangle {
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            color: theme.surfaceColor
            border.color: theme.borderColor
            border.width: 1
            radius: 8
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15
                
                Text {
                    text: "🔧 属性面板"
                    font.pixelSize: 16
                    font.bold: true
                    color: theme.textPrimary
                }
                
                // 项目属性
                GroupBox {
                    title: "项目设置"
                    Layout.fillWidth: true
                    
                    ColumnLayout {
                        spacing: 10
                        
                        Label {
                            text: "项目名称:"
                        }
                        
                        TextField {
                            Layout.fillWidth: true
                            text: currentProject || "未命名项目"
                        }
                        
                        Label {
                            text: "更新频率(ms):"
                        }
                        
                        SpinBox {
                            Layout.fillWidth: true
                            value: 500
                            from: 100
                            to: 5000
                            stepSize: 100
                        }
                    }
                }
                
                // 组件属性（当选中组件时显示）
                GroupBox {
                    title: "组件属性"
                    Layout.fillWidth: true
                    visible: selectedComponent !== null
                    
                    ColumnLayout {
                        spacing: 10
                        
                        Label {
                            text: "位置:"
                        }
                        
                        RowLayout {
                            Label { text: "X:" }
                            SpinBox { 
                                value: selectedComponent ? selectedComponent.x : 0
                                onValueChanged: if(selectedComponent) selectedComponent.x = value
                            }
                            Label { text: "Y:" }
                            SpinBox { 
                                value: selectedComponent ? selectedComponent.y : 0
                                onValueChanged: if(selectedComponent) selectedComponent.y = value
                            }
                        }
                        
                        Label {
                            text: "尺寸:"
                        }
                        
                        RowLayout {
                            Label { text: "宽:" }
                            SpinBox { 
                                value: selectedComponent ? selectedComponent.width : 100
                                onValueChanged: if(selectedComponent) selectedComponent.width = value
                            }
                            Label { text: "高:" }
                            SpinBox { 
                                value: selectedComponent ? selectedComponent.height : 100
                                onValueChanged: if(selectedComponent) selectedComponent.height = value
                            }
                        }
                    }
                }
                
                Item { Layout.fillHeight: true }
            }
        }
    }
    
    // 状态栏
    footer: Rectangle {
        height: 30
        color: theme.surfaceColor
        border.color: theme.borderColor
        border.width: 1
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 15
            
            Text {
                text: "就绪"
                color: theme.textSecondary
            }
            
            Item { Layout.fillWidth: true }
            
            Text {
                text: "坐标: X:" + (mouseArea.mouseX || 0) + " Y:" + (mouseArea.mouseY || 0)
                color: theme.textSecondary
            }
            
            Text {
                text: new Date().toLocaleTimeString()
                color: theme.textSecondary
            }
        }
    }
    
    // 鼠标区域用于坐标显示
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
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