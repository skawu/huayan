import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../shared/components"

/**
 * @brief SCADA运行时监控界面
 * 
 * 提供工业监控的运行时显示界面：
 * - 实时数据显示
 * - 状态监控面板
 * - 告警信息显示
 * - 系统状态概览
 */
ApplicationWindow {
    id: runtimeMonitor
    visible: true
    width: 1024
    height: 768
    title: "SCADA运行时监控系统"
    
    // ==================== 属性定义 ====================
    property bool isConnected: false
    property var systemStatus: "正常运行"
    property var currentTime: new Date()
    
    // ==================== 定时器 ====================
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            currentTime = new Date()
        }
    }
    
    // ==================== 主要布局 ====================
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // 顶部状态栏
        Rectangle {
            Layout.preferredHeight: 40
            color: "#2c3e50"
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                
                // 系统标题
                Text {
                    text: "工业监控系统"
                    font.pixelSize: 18
                    font.bold: true
                    color: "white"
                }
                
                Item { Layout.fillWidth: true }  // 弹簧元素
                
                // 连接状态
                Row {
                    spacing: 8
                    
                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: isConnected ? "#27ae60" : "#e74c3c"
                    }
                    
                    Text {
                        text: isConnected ? "已连接" : "未连接"
                        color: "white"
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                // 系统时间
                Text {
                    text: Qt.formatDateTime(currentTime, "yyyy-MM-dd hh:mm:ss")
                    color: "white"
                    font.family: "monospace"
                }
            }
        }
        
        // 主要内容区域
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            
            // 左侧监控面板
            Rectangle {
                Layout.preferredWidth: 300
                Layout.fillHeight: true
                color: "#ecf0f1"
                border.color: "#bdc3c7"
                border.width: 1
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 20
                    
                    // 系统概览
                    GroupBox {
                        title: "系统概览"
                        width: parent.width
                        
                        Column {
                            width: parent.width
                            spacing: 10
                            
                            Row {
                                width: parent.width
                                spacing: 10
                                
                                Text { 
                                    text: "运行状态:"
                                    width: 80
                                }
                                Text {
                                    text: systemStatus
                                    color: systemStatus === "正常运行" ? "#27ae60" : "#e74c3c"
                                    font.bold: true
                                }
                            }
                            
                            Row {
                                width: parent.width
                                spacing: 10
                                
                                Text { 
                                    text: "设备数量:"
                                    width: 80
                                }
                                Text {
                                    text: "12"
                                    color: "#3498db"
                                }
                            }
                            
                            Row {
                                width: parent.width
                                spacing: 10
                                
                                Text { 
                                    text: "在线设备:"
                                    width: 80
                                }
                                Text {
                                    text: "10"
                                    color: "#27ae60"
                                }
                            }
                        }
                    }
                    
                    // 告警信息
                    GroupBox {
                        title: "最新告警"
                        width: parent.width
                        
                        Column {
                            width: parent.width
                            spacing: 8
                            
                            Repeater {
                                model: [
                                    { level: "警告", message: "温度传感器#3 超过阈值", time: "14:32:15" },
                                    { level: "信息", message: "设备#7 启动完成", time: "14:28:42" },
                                    { level: "警告", message: "压力传感器#1 波动较大", time: "14:25:33" }
                                ]
                                
                                Rectangle {
                                    width: parent.width
                                    height: 60
                                    color: index % 2 === 0 ? "#ffffff" : "#f8f9fa"
                                    border.color: "#dee2e6"
                                    border.width: 1
                                    radius: 4
                                    
                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 4
                                        
                                        Row {
                                            spacing: 8
                                            
                                            Rectangle {
                                                width: 8
                                                height: 8
                                                radius: 4
                                                color: modelData.level === "警告" ? "#f39c12" : "#3498db"
                                            }
                                            
                                            Text {
                                                text: modelData.level
                                                font.bold: true
                                                color: modelData.level === "警告" ? "#f39c12" : "#3498db"
                                            }
                                            
                                            Item { Layout.fillWidth: true }
                                            
                                            Text {
                                                text: modelData.time
                                                color: "#7f8c8d"
                                                font.pixelSize: 10
                                            }
                                        }
                                        
                                        Text {
                                            text: modelData.message
                                            color: "#2c3e50"
                                            font.pixelSize: 12
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // 中央主显示屏
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#2c3e50"
                
                // 模拟的工艺流程图
                Item {
                    anchors.fill: parent
                    anchors.margins: 20
                    
                    // 标题
                    Text {
                        id: mainScreenTitle
                        text: "主工艺流程监控"
                        color: "white"
                        font.pixelSize: 24
                        font.bold: true
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    // 温度显示器
                    DraggableIndustrialComponent {
                        id: temperatureDisplay
                        x: 100
                        y: 100
                        width: 150
                        height: 100
                        componentName: "反应釜温度"
                        backgroundColor: "#34495e"
                        currentValue: (Math.sin(Date.now() / 2000) * 50 + 150).toFixed(1)
                        boundTag: "temperature"
                    }
                    
                    // 压力显示器
                    DraggableIndustrialComponent {
                        id: pressureDisplay
                        x: 300
                        y: 100
                        width: 150
                        height: 100
                        componentName: "系统压力"
                        backgroundColor: "#34495e"
                        currentValue: (Math.cos(Date.now() / 3000) * 3 + 10).toFixed(2)
                        boundTag: "pressure"
                    }
                    
                    // 电机状态
                    DraggableIndustrialComponent {
                        id: motorStatus
                        x: 100
                        y: 250
                        width: 120
                        height: 80
                        componentName: "主电机"
                        backgroundColor: "#34495e"
                        currentValue: Math.random() > 0.3 ? "运行" : "停止"
                        boundTag: "motor_status"
                    }
                    
                    // 阀门位置
                    DraggableIndustrialComponent {
                        id: valvePosition
                        x: 300
                        y: 250
                        width: 120
                        height: 80
                        componentName: "调节阀"
                        backgroundColor: "#34495e"
                        currentValue: (Math.random() * 100).toFixed(0) + "%"
                        boundTag: "valve_position"
                    }
                }
            }
            
            // 右侧详细信息面板
            Rectangle {
                Layout.preferredWidth: 250
                Layout.fillHeight: true
                color: "#ecf0f1"
                border.color: "#bdc3c7"
                border.width: 1
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 20
                    
                    // 实时数据
                    GroupBox {
                        title: "关键参数"
                        width: parent.width
                        
                        Column {
                            width: parent.width
                            spacing: 15
                            
                            Repeater {
                                model: [
                                    { name: "入口温度", value: "145°C", trend: "上升" },
                                    { name: "出口压力", value: "2.3MPa", trend: "稳定" },
                                    { name: "流量计读数", value: "1250m³/h", trend: "下降" },
                                    { name: "能耗统计", value: "285kWh", trend: "上升" }
                                ]
                                
                                Column {
                                    width: parent.width
                                    spacing: 5
                                    
                                    Text {
                                        text: modelData.name
                                        font.bold: true
                                        color: "#2c3e50"
                                    }
                                    
                                    Row {
                                        spacing: 10
                                        
                                        Text {
                                            text: modelData.value
                                            color: "#3498db"
                                            font.pixelSize: 16
                                        }
                                        
                                        Text {
                                            text: modelData.trend
                                            color: modelData.trend === "上升" ? "#e74c3c" : 
                                                   modelData.trend === "下降" ? "#27ae60" : "#f39c12"
                                            font.pixelSize: 12
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // 控制按钮
                    GroupBox {
                        title: "系统控制"
                        width: parent.width
                        
                        Column {
                            width: parent.width
                            spacing: 10
                            
                            Button {
                                text: "紧急停机"
                                width: parent.width
                                height: 40
                                background: Rectangle {
                                    color: "#e74c3c"
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            
                            Button {
                                text: "系统重启"
                                width: parent.width
                                height: 40
                                background: Rectangle {
                                    color: "#f39c12"
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            
                            Button {
                                text: "数据导出"
                                width: parent.width
                                height: 40
                                background: Rectangle {
                                    color: "#3498db"
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // ==================== 初始化 ====================
    Component.onCompleted: {
        // 模拟连接过程
        Timer {
            interval: 2000
            running: true
            onTriggered: {
                isConnected = true
                systemStatus = "正常运行"
            }
        }
        
        console.log("SCADA运行时监控系统启动")
    }
}