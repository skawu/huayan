import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import BasicComponents 1.0
import IndustrialComponents 1.0
import ControlComponents 1.0
import ChartComponents 1.0
import ThreeDComponents 1.0

// 组件项组件
Component {
    id: componentItem
    
    Item {
        id: root
        property string name: ""
        property string type: ""
        
        width: 80
        height: 100
        
        Rectangle {
            id: preview
            width: root.width - 10
            height: root.width - 10
            anchors.centerIn: parent
            anchors.topMargin: 5
            color: "#F0F0F0"
            border.color: "#CCCCCC"
            border.width: 1
            
            // 组件预览
            Loader {
                anchors.fill: parent
                anchors.margins: 5
                sourceComponent: Qt.createQmlObject('import QtQuick 2.15; import ' + type.split('.')[0] + ' 1.0; ' + type.split('.')[1] + ' {}', preview)
            }
        }
        
        Text {
            text: name
            anchors.top: preview.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 5
            font.pixelSize: 12
        }
        
        // 拖放功能
        MouseArea {
            anchors.fill: parent
            drag.target: root
            drag.axis: Drag.XAndY
            
            onPressed: {
                // 开始拖动
            }
            
            onReleased: {
                // 结束拖动，放置到画布
            }
        }
    }
}

// 组件项别名
Item {
    id: ComponentItem
    visible: false
}

Window {
    width: 1440
    height: 900
    visible: true
    title: "Huayan 工业组态软件"
    
    // 主布局
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // 菜单栏
        MenuBar {
            Menu {
                title: "文件"
                MenuItem { text: "新建项目" }
                MenuItem { text: "打开项目" }
                MenuItem { text: "保存项目" }
                MenuItem { text: "另存为" }
                MenuSeparator { }
                MenuItem { text: "导出项目" }
                MenuItem { text: "导入项目" }
                MenuSeparator { }
                MenuItem { text: "退出" }
            }
            Menu {
                title: "编辑"
                MenuItem { text: "撤销" }
                MenuItem { text: "重做" }
                MenuSeparator { }
                MenuItem { text: "剪切" }
                MenuItem { text: "复制" }
                MenuItem { text: "粘贴" }
                MenuSeparator { }
                MenuItem { text: "删除" }
                MenuItem { text: "全选" }
            }
            Menu {
                title: "视图"
                MenuItem { text: "工具栏" }
                MenuItem { text: "项目浏览器" }
                MenuItem { text: "属性面板" }
                MenuItem { text: "状态栏" }
                MenuSeparator { }
                MenuItem { text: "网格显示" }
                MenuItem { text: "对齐辅助线" }
            }
            Menu {
                title: "工具"
                MenuItem { text: "组件库" }
                MenuItem { text: "布局模板" }
                MenuItem { text: "主题设置" }
                MenuItem { text: "选项" }
            }
            Menu {
                title: "帮助"
                MenuItem { text: "用户手册" }
                MenuItem { text: "关于" }
            }
        }
        
        // 工具栏
        ToolBar {
            RowLayout {
                spacing: 5
                
                ToolButton { text: "新建" }
                ToolButton { text: "打开" }
                ToolButton { text: "保存" }
                ToolSeparator { }
                ToolButton { text: "撤销" }
                ToolButton { text: "重做" }
                ToolSeparator { }
                ToolButton { text: "剪切" }
                ToolButton { text: "复制" }
                ToolButton { text: "粘贴" }
                ToolSeparator { }
                ToolButton { text: "放大" }
                ToolButton { text: "缩小" }
                ToolButton { text: "适应窗口" }
            }
        }
        
        // 主工作区
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 1
            
            // 左侧项目浏览器
            Rectangle {
                width: 250
                Layout.fillHeight: true
                color: "#F5F5F5"
                border.color: "#CCCCCC"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    
                    Label {
                        text: "项目浏览器"
                        font.bold: true
                        padding: 5
                        background: Rectangle { color: "#E0E0E0" }
                    }
                    
                    // 项目结构和组件库
                    TabView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        Tab {
                            title: "项目"
                            
                            TreeView {
                                model: ListModel {
                                    ListElement { name: "项目"; type: "project" }
                                    ListElement { name: "页面 1"; type: "page" }
                                    ListElement { name: "页面 2"; type: "page" }
                                    ListElement { name: "数据点位"; type: "tags" }
                                    ListElement { name: "报警"; type: "alarms" }
                                }
                                
                                delegate: Item {
                                    width: parent.width
                                    height: 30
                                    Text {
                                        text: name
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                    }
                                }
                            }
                        }
                        
                        Tab {
                            title: "组件库"
                            
                            ColumnLayout {
                                spacing: 10
                                padding: 5
                                
                                // 组件分类
                                RowLayout {
                                    spacing: 5
                                    
                                    Button { text: "基础组件" }
                                    Button { text: "工业组件" }
                                    Button { text: "控制组件" }
                                    Button { text: "图表组件" }
                                    Button { text: "3D组件" }
                                }
                                
                                // 组件列表
                                GridLayout {
                                    columns: 2
                                    spacing: 10
                                    
                                    // 基础组件
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "Indicator"
                                            item.type = "BasicComponents.Indicator"
                                        }
                                    }
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "PushButton"
                                            item.type = "BasicComponents.PushButton"
                                        }
                                    }
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "TextLabel"
                                            item.type = "BasicComponents.TextLabel"
                                        }
                                    }
                                    
                                    // 工业组件
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "Valve"
                                            item.type = "IndustrialComponents.Valve"
                                        }
                                    }
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "Tank"
                                            item.type = "IndustrialComponents.Tank"
                                        }
                                    }
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "Motor"
                                            item.type = "IndustrialComponents.Motor"
                                        }
                                    }
                                    
                                    // 控制组件
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "Slider"
                                            item.type = "ControlComponents.Slider"
                                        }
                                    }
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "Knob"
                                            item.type = "ControlComponents.Knob"
                                        }
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
                color: "#FFFFFF"
                border.color: "#CCCCCC"
                border.width: 1
                
                // 画布容器
                Item {
                    id: canvasContainer
                    anchors.fill: parent
                    
                    // 网格背景
                    Rectangle {
                        anchors.fill: parent
                        color: "#F9F9F9"
                        
                        // 网格线
                        Repeater {
                            model: canvasContainer.width / 20
                            Rectangle {
                                width: 1
                                height: canvasContainer.height
                                x: index * 20
                                color: "#E0E0E0"
                            }
                        }
                        Repeater {
                            model: canvasContainer.height / 20
                            Rectangle {
                                width: canvasContainer.width
                                height: 1
                                y: index * 20
                                color: "#E0E0E0"
                            }
                        }
                    }
                    
                    // 画布内容
                    Item {
                        id: canvas
                        anchors.fill: parent
                        
                        // 示例组件
                        Rectangle {
                            x: 100
                            y: 100
                            width: 100
                            height: 100
                            color: "#2196F3"
                            border.color: "#1976D2"
                            border.width: 2
                            
                            MouseArea {
                                anchors.fill: parent
                                drag.target: parent
                            }
                        }
                        
                        Rectangle {
                            x: 300
                            y: 200
                            width: 150
                            height: 80
                            color: "#4CAF50"
                            border.color: "#388E3C"
                            border.width: 2
                            
                            MouseArea {
                                anchors.fill: parent
                                drag.target: parent
                            }
                        }
                    }
                }
            }
            
            // 右侧属性面板
            Rectangle {
                width: 300
                Layout.fillHeight: true
                color: "#F5F5F5"
                border.color: "#CCCCCC"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    
                    Label {
                        text: "属性面板"
                        font.bold: true
                        padding: 5
                        background: Rectangle { color: "#E0E0E0" }
                    }
                    
                    // 属性编辑器
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        ColumnLayout {
                            spacing: 10
                            padding: 10
                            
                            GroupBox {
                                title: "位置与大小"
                                
                                GridLayout {
                                    columns: 2
                                    spacing: 5
                                    
                                    Label { text: "X:" }
                                    SpinBox { value: 100 }
                                    Label { text: "Y:" }
                                    SpinBox { value: 100 }
                                    Label { text: "宽度:" }
                                    SpinBox { value: 100 }
                                    Label { text: "高度:" }
                                    SpinBox { value: 100 }
                                }
                            }
                            
                            GroupBox {
                                title: "外观"
                                
                                GridLayout {
                                    columns: 2
                                    spacing: 5
                                    
                                    Label { text: "填充色:" }
                                    ColorDialog { id: fillColorDialog }
                                    Label { text: "边框色:" }
                                    ColorDialog { id: borderColorDialog }
                                    Label { text: "边框宽度:" }
                                    SpinBox { value: 2 }
                                }
                            }
                            
                            GroupBox {
                                title: "数据绑定"
                                
                                GridLayout {
                                    columns: 2
                                    spacing: 5
                                    
                                    Label { text: "数据点位:" }
                                    ComboBox {
                                        model: ["选择点位", "tag1", "tag2", "tag3"]
                                    }
                                    Label { text: "绑定属性:" }
                                    ComboBox {
                                        model: ["填充色", "位置", "大小", "旋转"]
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // 状态栏
        StatusBar {
            RowLayout {
                spacing: 20
                
                Label { text: "就绪" }
                Label { text: "页面: 页面 1" }
                Label { text: "组件: 2" }
                Label { text: "缩放: 100%" }
            }
        }
    }
}
