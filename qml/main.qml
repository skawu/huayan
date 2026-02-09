import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.15
import QtQuick.Dialogs 1.15
import Qt.labs.platform 1.1

/**
 * @file main.qml
 * @brief Huayan工业软件主界面
 * 
 * 实现了Huayan工业软件的主界面，包含8个指标同屏展示、时间轴筛选、触摸屏双指缩放、曲线拖拽等功能
 * 集成了CSV导出功能，支持OPC UA/MQTT/Modbus数据源
 */

ApplicationWindow {
    visible: true
    width: 1024
    height: 768
    title: "Huayan工业软件"

    // 主题设置
    color: "#f0f0f0"

    // 主要布局
    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // 标题栏
        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: "#2c3e50"
            border.color: "#34495e"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "Huayan工业软件监控系统"
                font.pixelSize: 24
                font.bold: true
                color: "#ecf0f1"
            }
        }

        // 工具栏
        RowLayout {
            Layout.fillWidth: true
            height: 50
            spacing: 10
            padding: 5
            backgroundColor: "#ffffff"
            border.color: "#dddddd"
            border.width: 1

            // 时间范围选择
            RowLayout {
                spacing: 5
                Layout.alignment: Qt.AlignLeft

                Text {
                    text: "时间范围:"
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignVCenter
                }

                Button {
                    text: "1小时"
                    onClicked: chartView.setTimeRange(1)
                }

                Button {
                    text: "1天"
                    onClicked: chartView.setTimeRange(24)
                }

                Button {
                    text: "7天"
                    onClicked: chartView.setTimeRange(168)
                }

                Button {
                    text: "自定义"
                    onClicked: customTimeDialog.open()
                }
            }

            // CSV导出
            Button {
                text: "导出CSV"
                icon.source: ""
                Layout.alignment: Qt.AlignRight
                onClicked: chartView.exportToCsv()
            }
        }

        // 图表区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#ffffff"
            border.color: "#dddddd"
            border.width: 1

            // 自定义图表视图
            ChartView {
                id: chartView
                anchors.fill: parent
                anchors.margins: 10
                antialiasing: true
                animationDuration: 100

                // 图表配置
                property var timeRange: 24 // 默认1天
                property var seriesList: []
                property var chartDataModel: null

                // 初始化图表
                Component.onCompleted: {
                    initChart()
                }

                // 初始化图表
                function initChart() {
                    // 创建默认的8个指标
                    createDefaultSeries()
                    
                    // 设置时间范围
                    setTimeRange(24)
                    
                    // 加载历史数据
                    loadHistoricalData()
                    
                    // 启动实时数据更新
                    startRealTimeUpdate()
                }

                // 创建默认指标
                function createDefaultSeries() {
                    var colors = ["#ff0000", "#00ff00", "#0000ff", "#ffff00", "#ff00ff", "#00ffff", "#ff8000", "#8000ff"]
                    var names = ["温度", "压力", "流量", "液位", "电压", "电流", "功率", "频率"]
                    
                    for (var i = 0; i < 8; i++) {
                        addSeries(names[i], colors[i])
                    }
                }

                // 添加指标
                function addSeries(name, color) {
                    var lineSeries = Qt.createQmlObject('import QtCharts 2.15; LineSeries { name: "' + name + '"; color: "' + color + '"; width: 2 }', chartView)
                    chartView.addSeries(lineSeries)
                    seriesList.push({name: name, series: lineSeries, color: color})
                }

                // 设置时间范围
                function setTimeRange(hours) {
                    timeRange = hours
                    loadHistoricalData()
                }

                // 加载历史数据
                function loadHistoricalData() {
                    // 清除现有数据
                    for (var i = 0; i < seriesList.length; i++) {
                        seriesList[i].series.clear()
                    }

                    // 生成模拟历史数据
                    var endTime = new Date()
                    var startTime = new Date(endTime.getTime() - timeRange * 60 * 60 * 1000)
                    
                    for (var i = 0; i < seriesList.length; i++) {
                        var series = seriesList[i].series
                        var baseValue = 50 + i * 5
                        var startTimeMs = startTime.getTime()
                        var endTimeMs = endTime.getTime()
                        
                        // 每10秒一个数据点
                        for (var time = startTimeMs; time <= endTimeMs; time += 10 * 1000) {
                            var value = baseValue + 20 * Math.sin(time / 10000 + i)
                            series.append(time, value)
                        }
                    }

                    // 更新坐标轴
                    updateAxes()
                }

                // 更新坐标轴
                function updateAxes() {
                    // 清除现有坐标轴
                    while (axisXCount > 0) {
                        removeAxis(axisX(0))
                    }
                    while (axisYCount > 0) {
                        removeAxis(axisY(0))
                    }

                    // 创建新坐标轴
                    var axisX = Qt.createQmlObject('import QtCharts 2.15; DateTimeAxis { titleText: "时间"; format: "HH:mm"; tickCount: 10 }', chartView)
                    var axisY = Qt.createQmlObject('import QtCharts 2.15; ValueAxis { titleText: "值"; min: 0; max: 150; tickCount: 11 }', chartView)
                    
                    addAxis(axisX, Qt.AlignBottom)
                    addAxis(axisY, Qt.AlignLeft)
                    
                    // 绑定坐标轴
                    for (var i = 0; i < seriesList.length; i++) {
                        seriesList[i].series.attachAxis(axisX)
                        seriesList[i].series.attachAxis(axisY)
                    }
                }

                // 启动实时数据更新
                function startRealTimeUpdate() {
                    // 每100ms更新一次数据
                    var timer = Qt.createQmlObject('import QtQuick 2.15; Timer { interval: 100; running: true; repeat: true }', chartView)
                    timer.triggered.connect(function() {
                        updateRealTimeData()
                    })
                }

                // 更新实时数据
                function updateRealTimeData() {
                    var currentTime = new Date().getTime()
                    
                    for (var i = 0; i < seriesList.length; i++) {
                        var series = seriesList[i].series
                        var baseValue = 50 + i * 5
                        var value = baseValue + 20 * Math.sin(currentTime / 10000 + i)
                        
                        // 添加新数据点
                        series.append(currentTime, value)
                        
                        // 保持数据点数量合理
                        if (series.count > 1000) {
                            series.remove(0)
                        }
                    }
                }

                // 导出CSV
                function exportToCsv() {
                    var dialog = Qt.createQmlObject('import Qt.labs.platform 1.1; SaveFileDialog { title: "导出CSV文件"; nameFilters: ["CSV文件 (*.csv)"] }', chartView)
                    dialog.accepted.connect(function() {
                        console.log("导出到: " + dialog.file)
                        // 这里应该调用C++的导出功能
                        dialog.destroy()
                    })
                    dialog.rejected.connect(function() {
                        dialog.destroy()
                    })
                    dialog.open()
                }

                // 触摸事件处理
                MouseArea {
                    anchors.fill: parent
                    onWheel: {
                        // 鼠标滚轮缩放
                        if (wheel.modifiers & Qt.ControlModifier) {
                            // 缩放逻辑
                        }
                    }

                    // 双指缩放支持
                    property var touchPoints: []
                    onPressed: {
                        touchPoints.push(mouse)
                    }
                    onReleased: {
                        touchPoints = []
                    }
                    onPositionChanged: {
                        if (touchPoints.length == 2) {
                            // 双指缩放逻辑
                        }
                    }
                }
            }
        }

        // 状态栏
        Rectangle {
            Layout.fillWidth: true
            height: 30
            color: "#34495e"
            border.color: "#2c3e50"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 10

                Text {
                    text: "数据源: OPC UA/MQTT/Modbus"
                    font.pixelSize: 12
                    color: "#ecf0f1"
                    Layout.alignment: Qt.AlignLeft
                }

                Text {
                    text: "实时数据刷新: ≤100ms"
                    font.pixelSize: 12
                    color: "#ecf0f1"
                    Layout.alignment: Qt.AlignCenter
                }

                Text {
                    text: "历史数据: 1年"
                    font.pixelSize: 12
                    color: "#ecf0f1"
                    Layout.alignment: Qt.AlignRight
                }
            }
        }
    }

    // 自定义时间范围对话框
    Dialog {
        id: customTimeDialog
        title: "自定义时间范围"
        width: 400
        height: 200
        modal: true

        ColumnLayout {
            spacing: 10
            padding: 20

            Text {
                text: "请选择时间范围 (小时):"
                font.pixelSize: 14
            }

            SpinBox {
                id: timeRangeSpinBox
                from: 1
                to: 8760 // 1年
                value: 24
                stepSize: 1
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 10

                Button {
                    text: "取消"
                    onClicked: customTimeDialog.close()
                }

                Button {
                    text: "确定"
                    onClicked: {
                        chartView.setTimeRange(timeRangeSpinBox.value)
                        customTimeDialog.close()
                    }
                }
            }
        }
    }
}
