import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import "./themes"

ApplicationWindow {
    id: runtimeWindow
    visible: true
    width: 1024
    height: 768
    title: "Huayan SCADA Runtime"
    
    // 运行时状态
    property bool isFullscreen: false
    property string currentScreen: "dashboard"
    property var projectConfig: ({})
    
    // 主题
    property var theme: IndustrialTheme {}
    
    // 全屏切换快捷键
    Shortcut {
        sequence: "F11"
        onActivated: toggleFullscreen()
    }
    
    // ESC退出全屏
    Shortcut {
        sequence: "Escape"
        onActivated: {
            if (isFullscreen) {
                toggleFullscreen()
            }
        }
    }
    
    // 主布局
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // 顶部导航栏（非全屏时显示）
        Rectangle {
            Layout.fillWidth: true
            height: isFullscreen ? 0 : 60
            color: theme.primaryColor
            visible: !isFullscreen
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 20
                
                // Logo和系统名称
                RowLayout {
                    spacing: 10
                    
                    Text {
                        text: "🏭"
                        font.pixelSize: 24
                    }
                    
                    Text {
                        text: projectConfig.projectName || "Huayan SCADA"
                        font.pixelSize: 18
                        font.bold: true
                        color: theme.textLight
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // 导航按钮
                RowLayout {
                    spacing: 5
                    
                    Repeater {
                        model: ListModel {
                            ListElement { name: "仪表盘"; screen: "dashboard"; icon: "📊" }
                            ListElement { name: "监控"; screen: "monitor"; icon: "👁️" }
                            ListElement { name: "告警"; screen: "alarm"; icon: "⚠️" }
                            ListElement { name: "历史"; screen: "history"; icon: "🕒" }
                            ListElement { name: "报表"; screen: "report"; icon: "📋" }
                        }
                        
                        delegate: Button {
                            text: model.icon + "\n" + model.name
                            width: 80
                            height: 50
                            checkable: true
                            checked: currentScreen === model.screen
                            onClicked: currentScreen = model.screen
                            
                            background: Rectangle {
                                color: checked ? theme.secondaryColor : "transparent"
                                border.color: theme.textLight
                                border.width: 1
                                radius: 4
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: theme.textLight
                                font.pixelSize: 10
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // 系统状态
                RowLayout {
                    spacing: 15
                    
                    // 连接状态
                    Rectangle {
                        width: 120
                        height: 30
                        color: getConnectionStatusColor()
                        radius: 15
                        
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 5
                            
                            Rectangle {
                                width: 12
                                height: 12
                                color: "white"
                                radius: 6
                            }
                            
                            Text {
                                text: getConnectionStatusText()
                                color: "white"
                                font.pixelSize: 12
                            }
                        }
                    }
                    
                    // 时间显示
                    Text {
                        text: new Date().toLocaleString()
                        color: theme.textLight
                        font.pixelSize: 14
                    }
                    
                    // 全屏按钮
                    Button {
                        text: isFullscreen ? "❐" : "⛶"
                        onClicked: toggleFullscreen()
                        background: Rectangle {
                            color: "transparent"
                            border.color: theme.textLight
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: theme.textLight
                            font.pixelSize: 16
                        }
                    }
                }
            }
        }
        
        // 主内容区域
        StackLayout {
            id: contentStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: getScreenIndex(currentScreen)
            
            // 仪表盘页面
            Item {
                id: dashboardScreen
                
                // 背景渐变
                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#1a1a2e" }
                        GradientStop { position: 1.0; color: "#16213e" }
                    }
                }
                
                // 仪表盘网格布局
                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    columns: 3
                    rowSpacing: 20
                    columnSpacing: 20
                    
                    // 关键指标卡片
                    Repeater {
                        model: ListModel {
                            ListElement { 
                                title: "生产状态"; 
                                value: "正常运行"; 
                                unit: ""; 
                                color: "#4CAF50";
                                icon: "⚙️"
                            }
                            ListElement { 
                                title: "当前产量"; 
                                value: "1250"; 
                                unit: "吨/小时"; 
                                color: "#2196F3";
                                icon: "📊"
                            }
                            ListElement { 
                                title: "设备效率"; 
                                value: "94.5"; 
                                unit: "%"; 
                                color: "#FF9800";
                                icon: "⚡"
                            }
                            ListElement { 
                                title: "能耗水平"; 
                                value: "285"; 
                                unit: "kWh"; 
                                color: "#9C27B0";
                                icon: "💡"
                            }
                            ListElement { 
                                title: "质量指数"; 
                                value: "98.7"; 
                                unit: "%"; 
                                color: "#E91E63";
                                icon: "🎯"
                            }
                            ListElement { 
                                title: "安全状态"; 
                                value: "无告警"; 
                                unit: ""; 
                                color: "#4CAF50";
                                icon: "🛡️"
                            }
                        }
                        
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.minimumHeight: 150
                            color: theme.cardColor
                            border.color: theme.borderColor
                            border.width: 1
                            radius: 12
                            
                            // 阴影效果
                            layer.enabled: true
                            layer.effect: DropShadow {
                                horizontalOffset: 0
                                verticalOffset: 4
                                radius: 8
                                samples: 16
                                color: "#40000000"
                            }
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 15
                                
                                // 标题行
                                RowLayout {
                                    Layout.fillWidth: true
                                    
                                    Text {
                                        text: model.icon
                                        font.pixelSize: 20
                                    }
                                    
                                    Text {
                                        text: model.title
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: theme.textPrimary
                                        Layout.fillWidth: true
                                    }
                                }
                                
                                Item { Layout.fillHeight: true }
                                
                                // 数值显示
                                RowLayout {
                                    Layout.alignment: Qt.AlignHCenter
                                    
                                    Text {
                                        text: model.value
                                        font.pixelSize: 28
                                        font.bold: true
                                        color: model.color
                                    }
                                    
                                    Text {
                                        text: model.unit
                                        font.pixelSize: 14
                                        color: theme.textSecondary
                                        visible: model.unit !== ""
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // 监控页面
            Item {
                // 实时监控布局
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20
                    
                    Text {
                        text: "🏭 生产线实时监控"
                        font.pixelSize: 24
                        font.bold: true
                        color: theme.textPrimary
                    }
                    
                    // 监控画面网格
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 2
                        rowSpacing: 15
                        columnSpacing: 15
                        
                        // 高炉监控
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: theme.cardColor
                            border.color: theme.borderColor
                            border.width: 1
                            radius: 8
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                
                                Text {
                                    text: "🔥 高炉 #1"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: theme.textPrimary
                                }
                                
                                Item { Layout.fillHeight: true }
                                
                                // 模拟温度显示
                                RowLayout {
                                    Layout.alignment: Qt.AlignHCenter
                                    
                                    Text {
                                        text: "温度:"
                                        font.pixelSize: 14
                                        color: theme.textSecondary
                                    }
                                    
                                    Text {
                                        text: "1850°C"
                                        font.pixelSize: 20
                                        font.bold: true
                                        color: "#FF5722"
                                    }
                                }
                            }
                        }
                        
                        // 轧机监控
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: theme.cardColor
                            border.color: theme.borderColor
                            border.width: 1
                            radius: 8
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                
                                Text {
                                    text: "⚙️ 轧机 #1"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: theme.textPrimary
                                }
                                
                                Item { Layout.fillHeight: true }
                                
                                // 模拟状态显示
                                RowLayout {
                                    Layout.alignment: Qt.AlignHCenter
                                    
                                    Rectangle {
                                        width: 16
                                        height: 16
                                        color: "#4CAF50"
                                        radius: 8
                                    }
                                    
                                    Text {
                                        text: "运行中"
                                        font.pixelSize: 16
                                        color: "#4CAF50"
                                        font.bold: true
                                    }
                                }
                            }
                        }
                        
                        // 电力监控
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: theme.cardColor
                            border.color: theme.borderColor
                            border.width: 1
                            radius: 8
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                
                                Text {
                                    text: "⚡ 电力系统"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: theme.textPrimary
                                }
                                
                                Item { Layout.fillHeight: true }
                                
                                // 模拟功率显示
                                RowLayout {
                                    Layout.alignment: Qt.AlignHCenter
                                    
                                    Text {
                                        text: "功率:"
                                        font.pixelSize: 14
                                        color: theme.textSecondary
                                    }
                                    
                                    Text {
                                        text: "2.4 MW"
                                        font.pixelSize: 20
                                        font.bold: true
                                        color: "#2196F3"
                                    }
                                }
                            }
                        }
                        
                        // 环保监控
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: theme.cardColor
                            border.color: theme.borderColor
                            border.width: 1
                            radius: 8
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                
                                Text {
                                    text: "🌍 环保监测"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: theme.textPrimary
                                }
                                
                                Item { Layout.fillHeight: true }
                                
                                // 模拟排放显示
                                RowLayout {
                                    Layout.alignment: Qt.AlignHCenter
                                    
                                    Text {
                                        text: "排放:"
                                        font.pixelSize: 14
                                        color: theme.textSecondary
                                    }
                                    
                                    Text {
                                        text: "达标"
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#4CAF50"
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // 告警页面
            Item {
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    
                    Text {
                        text: "⚠️ 实时告警"
                        font.pixelSize: 24
                        font.bold: true
                        color: theme.textPrimary
                    }
                    
                    // 告警列表
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        model: ListModel {
                            ListElement { 
                                level: "紧急"; 
                                message: "高炉温度过高"; 
                                time: "14:32:15"; 
                                color: "#F44336" 
                            }
                            ListElement { 
                                level: "警告"; 
                                message: "轧机轴承温度偏高"; 
                                time: "14:28:33"; 
                                color: "#FF9800" 
                            }
                            ListElement { 
                                level: "提示"; 
                                message: "设备维护周期到期"; 
                                time: "14:15:47"; 
                                color: "#2196F3" 
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 60
                            color: index % 2 === 0 ? theme.cardColor : theme.surfaceColor
                            border.color: model.color
                            border.width: 2
                            radius: 8
                            margin: 5
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                
                                Rectangle {
                                    width: 12
                                    height: 12
                                    color: model.color
                                    radius: 6
                                }
                                
                                Text {
                                    text: model.level
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: model.color
                                    Layout.preferredWidth: 60
                                }
                                
                                Text {
                                    text: model.message
                                    font.pixelSize: 14
                                    color: theme.textPrimary
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: model.time
                                    font.pixelSize: 12
                                    color: theme.textSecondary
                                }
                            }
                        }
                    }
                }
            }
            
            // 历史数据页面和其他页面...
            Item {
                Text {
                    anchors.centerIn: parent
                    text: "历史数据页面正在开发中..."
                    font.pixelSize: 18
                    color: theme.textSecondary
                }
            }
            
            Item {
                Text {
                    anchors.centerIn: parent
                    text: "报表页面正在开发中..."
                    font.pixelSize: 18
                    color: theme.textSecondary
                }
            }
        }
    }
    
    // 工具函数
    function toggleFullscreen() {
        isFullscreen = !isFullscreen
        if (isFullscreen) {
            showFullScreen()
        } else {
            showNormal()
        }
    }
    
    function getScreenIndex(screenName) {
        switch(screenName) {
            case "dashboard": return 0
            case "monitor": return 1
            case "alarm": return 2
            case "history": return 3
            case "report": return 4
            default: return 0
        }
    }
    
    function getConnectionStatusColor() {
        // 模拟连接状态
        return "#4CAF50" // 绿色表示连接正常
    }
    
    function getConnectionStatusText() {
        return "连接正常"
    }
    
    // 初始化项目配置
    Component.onCompleted: {
        // 加载项目配置
        loadProjectConfig()
        
        // 启动定时器更新时间
        timeUpdater.start()
    }
    
    // 时间更新器
    Timer {
        id: timeUpdater
        interval: 1000
        repeat: true
        onTriggered: {
            // 时间会自动更新
        }
    }
    
    // 加载项目配置
    function loadProjectConfig() {
        // 这里应该从项目文件加载配置
        projectConfig = {
            projectName: "钢铁厂监控系统",
            version: "1.0.0"
        }
    }
}