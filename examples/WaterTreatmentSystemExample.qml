import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import HYIndustrialComponents 1.0
import HYBasicComponents 1.0
import HYChartComponents 1.0

/**
 * @brief 水处理系统示例
 * 
 * 展示一个完整的水处理系统监控界面，包括：
 * 1. 水泵、阀门、储罐等设备的状态监控
 * 2. 实时数据图表显示
 * 3. 报警系统
 * 4. 设备控制界面
 * 5. 工业告警弹窗
 * 6. 历史数据回溯
 */
Rectangle {
    width: 1000
    height: 800
    color: "#f0f0f0"
    
    // 系统状态数据
    property bool mainPumpRunning: true
    property bool backupPumpRunning: false
    property bool inletValveOpen: true
    property bool outletValveOpen: true
    property real waterLevel: 75
    property real pressure: 3.5
    property real temperature: 22.5
    property bool filterDirty: false
    
    // 报警状态
    property bool levelAlarm: false
    property bool pressureAlarm: false
    property bool temperatureAlarm: false
    property bool alarmActive: false
    property string alarmMessage: ""
    property int alarmCount: 0
    
    // 历史数据
    property var historicalData: {
        "waterLevel": [],
        "pressure": [],
        "temperature": []
    }
    property int historyMaxPoints: 100
    property bool showingHistory: false
    
    // 主布局
    Grid {
        anchors.fill: parent
        rows: 2
        columns: 2
        spacing: 10
        
        // 设备监控区域
        Rectangle {
            row: 0
            column: 0
            width: parent.width / 2 - 5
            height: parent.height / 2 - 5
            color: "#ffffff"
            radius: 5
            border.color: "#dddddd"
            border.width: 1
            
            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                
                Text {
                    text: "设备监控"
                    font.pointSize: 18
                    font.bold: true
                    color: "#333333"
                }
                
                Grid {
                    rows: 2
                    columns: 2
                    spacing: 20
                    
                    // 主水泵
                    Column {
                        spacing: 5
                        
                        Text {
                            text: "主水泵"
                            font.pointSize: 14
                            font.bold: true
                        }
                        
                        HYPump {
                    width: 100
                    height: 100
                    running: mainPumpRunning
                    runningColor: "#4CAF50"
                    stoppedColor: "#F44336"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                        
                        Row {
                            spacing: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Button {
                                text: mainPumpRunning ? "停止" : "启动"
                                onClicked: mainPumpRunning = !mainPumpRunning
                                background: Rectangle {
                                    color: mainPumpRunning ? "#F44336" : "#4CAF50"
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    font.pointSize: 12
                                    font.bold: true
                                }
                            }
                        }
                    }
                    
                    // 备用水泵
                    Column {
                        spacing: 5
                        
                        Text {
                            text: "备用水泵"
                            font.pointSize: 14
                            font.bold: true
                        }
                        
                        HYPump {
                    width: 100
                    height: 100
                    running: backupPumpRunning
                    runningColor: "#4CAF50"
                    stoppedColor: "#F44336"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                        
                        Row {
                            spacing: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Button {
                                text: backupPumpRunning ? "停止" : "启动"
                                onClicked: backupPumpRunning = !backupPumpRunning
                                background: Rectangle {
                                    color: backupPumpRunning ? "#F44336" : "#4CAF50"
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    font.pointSize: 12
                                    font.bold: true
                                }
                            }
                        }
                    }
                    
                    // 进水阀门
                    Column {
                        spacing: 5
                        
                        Text {
                            text: "进水阀门"
                            font.pointSize: 14
                            font.bold: true
                        }
                        
                        HYValve {
                    width: 100
                    height: 100
                    open: inletValveOpen
                    openColor: "#4CAF50"
                    closedColor: "#F44336"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                        
                        Row {
                            spacing: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Button {
                                text: inletValveOpen ? "关闭" : "打开"
                                onClicked: inletValveOpen = !inletValveOpen
                                background: Rectangle {
                                    color: inletValveOpen ? "#F44336" : "#4CAF50"
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    font.pointSize: 12
                                    font.bold: true
                                }
                            }
                        }
                    }
                    
                    // 出水阀门
                    Column {
                        spacing: 5
                        
                        Text {
                            text: "出水阀门"
                            font.pointSize: 14
                            font.bold: true
                        }
                        
                        HYValve {
                    width: 100
                    height: 100
                    open: outletValveOpen
                    openColor: "#4CAF50"
                    closedColor: "#F44336"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                        
                        Row {
                            spacing: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Button {
                                text: outletValveOpen ? "关闭" : "打开"
                                onClicked: outletValveOpen = !outletValveOpen
                                background: Rectangle {
                                    color: outletValveOpen ? "#F44336" : "#4CAF50"
                                    radius: 4
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    font.pointSize: 12
                                    font.bold: true
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // 储罐和传感器数据区域
        Rectangle {
            row: 0
            column: 1
            width: parent.width / 2 - 5
            height: parent.height / 2 - 5
            color: "#ffffff"
            radius: 5
            border.color: "#dddddd"
            border.width: 1
            
            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                
                Text {
                    text: "储罐和传感器数据"
                    font.pointSize: 18
                    font.bold: true
                    color: "#333333"
                }
                
                Row {
                    spacing: 40
                    
                    // 储罐
                    Column {
                        spacing: 5
                        
                        Text {
                            text: "清水储罐"
                            font.pointSize: 14
                            font.bold: true
                        }
                        
                        HYTank {
                    width: 150
                    height: 250
                    level: waterLevel
                    fillColor: "#2196F3"
                    showLevelText: true
                    unit: "%"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                        
                        Text {
                            text: "液位: " + waterLevel.toFixed(1) + "%"
                            font.pointSize: 12
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                    
                    // 传感器数据
                    Column {
                        spacing: 20
                        
                        Text {
                            text: "传感器数据"
                            font.pointSize: 14
                            font.bold: true
                        }
                        
                        // 压力传感器
                        Column {
                            spacing: 5
                            
                            Row {
                                Text {
                                    text: "压力: "
                                    font.pointSize: 14
                                }
                                Text {
                                    text: pressure.toFixed(1) + " bar"
                                    font.pointSize: 14
                                    font.bold: true
                                    color: pressureAlarm ? "#F44336" : "#333333"
                                }
                            }
                            
                            HYGauge {
                    width: 120
                    height: 120
                    value: pressure * 10
                    minValue: 0
                    maxValue: 100
                    unit: "%"
                    fillColor: pressureAlarm ? "#F44336" : "#4CAF50"
                }
                        }
                        
                        // 温度传感器
                        Column {
                            spacing: 5
                            
                            Row {
                                Text {
                                    text: "温度: "
                                    font.pointSize: 14
                                }
                                Text {
                                    text: temperature.toFixed(1) + " °C"
                                    font.pointSize: 14
                                    font.bold: true
                                    color: temperatureAlarm ? "#F44336" : "#333333"
                                }
                            }
                            
                            HYGauge {
                    width: 120
                    height: 120
                    value: temperature
                    minValue: 0
                    maxValue: 50
                    unit: "°C"
                    fillColor: temperatureAlarm ? "#F44336" : "#2196F3"
                }
                        }
                        
                        // 过滤器状态
                        Row {
                            spacing: 5
                            
                            Text {
                                text: "过滤器: "
                                font.pointSize: 14
                            }
                            Text {
                                text: filterDirty ? "需要清洗" : "正常"
                                font.pointSize: 14
                                font.bold: true
                                color: filterDirty ? "#FF9800" : "#4CAF50"
                            }
                        }
                    }
                }
            }
        }
        
        // 数据图表区域
        Rectangle {
            row: 1
            column: 0
            width: parent.width / 2 - 5
            height: parent.height / 2 - 5
            color: "#ffffff"
            radius: 5
            border.color: "#dddddd"
            border.width: 1
            
            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                
                Row {
                    spacing: 10
                    
                    Text {
                        text: showingHistory ? "历史数据图表" : "实时数据图表"
                        font.pointSize: 18
                        font.bold: true
                        color: "#333333"
                    }
                    
                    Button {
                        text: showingHistory ? "查看实时数据" : "查看历史数据"
                        onClicked: {
                            showingHistory = !showingHistory
                        }
                        background: Rectangle {
                            color: "#2196F3"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font.pointSize: 12
                            font.bold: true
                        }
                    }
                }
                
                Row {
                    spacing: 10
                    
                    // 液位趋势图
                    Column {
                        spacing: 5
                        
                        Text {
                            text: "液位趋势"
                            font.pointSize: 12
                            font.bold: true
                        }
                        
                        HYTrendChart {
                    width: 220
                    height: 150
                    title: "液位 (%)"
                    color: "#2196F3"
                }
                    }
                    
                    // 压力趋势图
                    Column {
                        spacing: 5
                        
                        Text {
                            text: "压力趋势"
                            font.pointSize: 12
                            font.bold: true
                        }
                        
                        HYTrendChart {
                    width: 220
                    height: 150
                    title: "压力 (bar)"
                    color: "#4CAF50"
                }
                    }
                    
                    // 温度趋势图
                    Column {
                        spacing: 5
                        
                        Text {
                            text: "温度趋势"
                            font.pointSize: 12
                            font.bold: true
                        }
                        
                        HYTrendChart {
                    width: 220
                    height: 150
                    title: "温度 (°C)"
                    color: "#FF9800"
                }
                    }
                }
                
                // 历史数据控制
                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: showingHistory
                    
                    Button {
                        text: "刷新历史数据"
                        onClicked: {
                            // 模拟刷新历史数据
                            console.log("刷新历史数据")
                        }
                        background: Rectangle {
                            color: "#4CAF50"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font.pointSize: 12
                            font.bold: true
                        }
                    }
                    
                    Button {
                        text: "导出历史数据"
                        onClicked: {
                            // 模拟导出历史数据
                            console.log("导出历史数据")
                        }
                        background: Rectangle {
                            color: "#9C27B0"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font.pointSize: 12
                            font.bold: true
                        }
                    }
                }
            }
        }
        
        // 报警和系统状态区域
        Rectangle {
            row: 1
            column: 1
            width: parent.width / 2 - 5
            height: parent.height / 2 - 5
            color: "#ffffff"
            radius: 5
            border.color: "#dddddd"
            border.width: 1
            
            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                
                Text {
                    text: "系统状态和报警"
                    font.pointSize: 18
                    font.bold: true
                    color: "#333333"
                }
                
                // 系统状态
                Column {
                    spacing: 5
                    
                    Text {
                        text: "系统状态"
                        font.pointSize: 14
                        font.bold: true
                    }
                    
                    Grid {
                        rows: 2
                        columns: 2
                        spacing: 10
                        
                        Row {
                            spacing: 5
                            
                            Text {
                                text: "主系统: "
                                font.pointSize: 12
                            }
                            Text {
                                text: mainPumpRunning ? "运行中" : "停止"
                                font.pointSize: 12
                                font.bold: true
                                color: mainPumpRunning ? "#4CAF50" : "#F44336"
                            }
                        }
                        
                        Row {
                            spacing: 5
                            
                            Text {
                                text: "备用系统: "
                                font.pointSize: 12
                            }
                            Text {
                                text: backupPumpRunning ? "运行中" : "待机"
                                font.pointSize: 12
                                font.bold: true
                                color: backupPumpRunning ? "#4CAF50" : "#FF9800"
                            }
                        }
                        
                        Row {
                            spacing: 5
                            
                            Text {
                                text: "进水: "
                                font.pointSize: 12
                            }
                            Text {
                                text: inletValveOpen ? "打开" : "关闭"
                                font.pointSize: 12
                                font.bold: true
                                color: inletValveOpen ? "#4CAF50" : "#F44336"
                            }
                        }
                        
                        Row {
                            spacing: 5
                            
                            Text {
                                text: "出水: "
                                font.pointSize: 12
                            }
                            Text {
                                text: outletValveOpen ? "打开" : "关闭"
                                font.pointSize: 12
                                font.bold: true
                                color: outletValveOpen ? "#4CAF50" : "#F44336"
                            }
                        }
                    }
                }
                
                // 报警状态
                Column {
                    spacing: 5
                    
                    Text {
                        text: "报警状态"
                        font.pointSize: 14
                        font.bold: true
                    }
                    
                    Grid {
                        rows: 2
                        columns: 2
                        spacing: 10
                        
                        Row {
                            spacing: 5
                            
                            Text {
                                text: "液位报警: "
                                font.pointSize: 12
                            }
                            Text {
                                text: levelAlarm ? "触发" : "正常"
                                font.pointSize: 12
                                font.bold: true
                                color: levelAlarm ? "#F44336" : "#4CAF50"
                            }
                        }
                        
                        Row {
                            spacing: 5
                            
                            Text {
                                text: "压力报警: "
                                font.pointSize: 12
                            }
                            Text {
                                text: pressureAlarm ? "触发" : "正常"
                                font.pointSize: 12
                                font.bold: true
                                color: pressureAlarm ? "#F44336" : "#4CAF50"
                            }
                        }
                        
                        Row {
                            spacing: 5
                            
                            Text {
                                text: "温度报警: "
                                font.pointSize: 12
                            }
                            Text {
                                text: temperatureAlarm ? "触发" : "正常"
                                font.pointSize: 12
                                font.bold: true
                                color: temperatureAlarm ? "#F44336" : "#4CAF50"
                            }
                        }
                        
                        Row {
                            spacing: 5
                            
                            Text {
                                text: "过滤器状态: "
                                font.pointSize: 12
                            }
                            Text {
                                text: filterDirty ? "需要清洗" : "正常"
                                font.pointSize: 12
                                font.bold: true
                                color: filterDirty ? "#FF9800" : "#4CAF50"
                            }
                        }
                    }
                }
                
                // 系统控制按钮
                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Button {
                        text: "系统重置"
                        onClicked: {
                            mainPumpRunning = true
                            backupPumpRunning = false
                            inletValveOpen = true
                            outletValveOpen = true
                            waterLevel = 75
                            pressure = 3.5
                            temperature = 22.5
                            filterDirty = false
                            levelAlarm = false
                            pressureAlarm = false
                            temperatureAlarm = false
                            alarmActive = false
                            alarmMessage = ""
                        }
                        background: Rectangle {
                            color: "#9C27B0"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font.pointSize: 12
                            font.bold: true
                        }
                    }
                    
                    Button {
                        text: "测试报警"
                        onClicked: {
                            levelAlarm = true
                            pressureAlarm = true
                            temperatureAlarm = true
                            showAlarm("测试报警", "系统测试报警功能")
                        }
                        background: Rectangle {
                            color: "#FF9800"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font.pointSize: 12
                            font.bold: true
                        }
                    }
                }
            }
        }
    }
    
    // 工业告警弹窗
    Rectangle {
        id: alarmDialog
        width: 400
        height: 200
        color: "#ffffff"
        radius: 8
        border.color: "#F44336"
        border.width: 2
        anchors.centerIn: parent
        visible: alarmActive
        z: 100
        
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            Row {
                spacing: 10
                
                Rectangle {
                    width: 40
                    height: 40
                    color: "#F44336"
                    radius: 20
                    
                    Text {
                        anchors.centerIn: parent
                        text: "!"
                        color: "#ffffff"
                        font.pointSize: 24
                        font.bold: true
                    }
                }
                
                Text {
                    text: alarmMessage
                    font.pointSize: 16
                    font.bold: true
                    color: "#333333"
                    wrapMode: Text.WordWrap
                }
            }
            
            Text {
                text: "请及时处理告警，确保系统正常运行。"
                font.pointSize: 14
                color: "#666666"
                wrapMode: Text.WordWrap
            }
            
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                
                Button {
                    text: "确认"
                    onClicked: {
                        alarmActive = false
                        alarmMessage = ""
                    }
                    background: Rectangle {
                        color: "#4CAF50"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        font.pointSize: 12
                        font.bold: true
                    }
                }
                
                Button {
                    text: "忽略"
                    onClicked: {
                        alarmActive = false
                        alarmMessage = ""
                    }
                    background: Rectangle {
                        color: "#9E9E9E"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        font.pointSize: 12
                        font.bold: true
                    }
                }
            }
        }
    }
    
    // 模拟数据更新
    Timer {
        interval: 1000
        running: true
        repeat: true
        
        onTriggered: {
            // 模拟液位变化
            if (mainPumpRunning) {
                waterLevel = Math.max(0, Math.min(100, waterLevel + (Math.random() * 2 - 1)))
            }
            
            // 模拟压力变化
            pressure = Math.max(0, Math.min(10, pressure + (Math.random() * 0.2 - 0.1)))
            
            // 模拟温度变化
            temperature = Math.max(0, Math.min(50, temperature + (Math.random() * 0.2 - 0.1)))
            
            // 检查报警条件
            bool oldLevelAlarm = levelAlarm
            bool oldPressureAlarm = pressureAlarm
            bool oldTemperatureAlarm = temperatureAlarm
            
            levelAlarm = (waterLevel < 10 || waterLevel > 90)
            pressureAlarm = (pressure < 1 || pressure > 8)
            temperatureAlarm = (temperature < 5 || temperature > 40)
            
            // 模拟过滤器脏污
            if (Math.random() > 0.995) {
                filterDirty = !filterDirty
            }
            
            // 记录历史数据
            recordHistoricalData()
            
            // 显示告警
            if (levelAlarm && !oldLevelAlarm) {
                showAlarm("液位告警", waterLevel < 10 ? "液位过低，请检查进水系统" : "液位过高，请检查出水系统")
            }
            
            if (pressureAlarm && !oldPressureAlarm) {
                showAlarm("压力告警", pressure < 1 ? "压力过低，请检查水泵" : "压力过高，请检查管道")
            }
            
            if (temperatureAlarm && !oldTemperatureAlarm) {
                showAlarm("温度告警", temperature < 5 ? "温度过低，请检查加热系统" : "温度过高，请检查冷却系统")
            }
        }
    }
    
    // 显示告警
    function showAlarm(title, message) {
        alarmMessage = title + "\n" + message
        alarmActive = true
        alarmCount++
    }
    
    // 记录历史数据
    function recordHistoricalData() {
        var now = new Date().getTime()
        
        // 记录液位数据
        historicalData.waterLevel.push({time: now, value: waterLevel})
        if (historicalData.waterLevel.length > historyMaxPoints) {
            historicalData.waterLevel.shift()
        }
        
        // 记录压力数据
        historicalData.pressure.push({time: now, value: pressure})
        if (historicalData.pressure.length > historyMaxPoints) {
            historicalData.pressure.shift()
        }
        
        // 记录温度数据
        historicalData.temperature.push({time: now, value: temperature})
        if (historicalData.temperature.length > historyMaxPoints) {
            historicalData.temperature.shift()
        }
    }
}
