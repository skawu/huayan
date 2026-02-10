import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.15
import SteelPlantMonitoring 1.0
import BasicComponents 1.0
import IndustrialComponents 1.0
import HMIControls 1.0
import ControlComponents 1.0
import ThreeDComponents 1.0

Window {
    width: 1920
    height: 1080
    visible: true
    title: "钢铁厂监控平台"

    // 钢铁厂管理器
    SteelPlantManager {
        id: steelPlantManager
        onAlarmTriggered: {
            showAlarm(alarmId, message, isEmergency);
        }
    }

    // 模拟数据源
    SimulatedDataSource {
        id: simulatedDataSource
    }

    // 主布局
    GridLayout {
        anchors.fill: parent
        columns: 3
        rows: 2
        columnSpacing: 10
        rowSpacing: 10

        // 左侧：3D可视化区
        Rectangle {
            Layout.row: 0
            Layout.column: 0
            Layout.rowSpan: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f0f0f0"
            border.color: "#ccc"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                padding: 10
                spacing: 10

                Text {
                    text: "3D可视化区"
                    font.bold: true
                    font.pointSize: 14
                    Layout.fillWidth: true
                }

                // 3D场景
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#000000"
                    border.color: "#ddd"
                    border.width: 1

                    // 这里应该使用Qt 3D组件
                    // 由于示例中没有实际的3D模型，我们使用一个占位符
                    Text {
                        anchors.centerIn: parent
                        text: "3D钢铁厂场景\n（左键旋转/滚轮缩放/右键平移）"
                        color: "#ffffff"
                        font.pointSize: 14
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // 设备状态指示器
                    ColumnLayout {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        padding: 10
                        spacing: 10

                        RowLayout {
                            spacing: 5
                            Text {
                                text: "高炉状态:"
                                color: "#ffffff"
                            }
                            Rectangle {
                                width: 20
                                height: 20
                                color: steelPlantManager.blastFurnaceStatus["status"] ? "#00ff00" : "#ff0000"
                                radius: 10
                            }
                        }

                        RowLayout {
                            spacing: 5
                            Text {
                                text: "转炉状态:"
                                color: "#ffffff"
                            }
                            Rectangle {
                                width: 20
                                height: 20
                                color: steelPlantManager.converterStatus["status"] ? "#00ff00" : "#ff0000"
                                radius: 10
                            }
                        }

                        RowLayout {
                            spacing: 5
                            Text {
                                text: "轧钢状态:"
                                color: "#ffffff"
                            }
                            Rectangle {
                                width: 20
                                height: 20
                                color: steelPlantManager.rollingMillStatus["status"] ? "#00ff00" : "#ff0000"
                                radius: 10
                            }
                        }
                    }
                }

                // 设备控制按钮
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    PushButton {
                        text: "启动高炉"
                        Layout.fillWidth: true
                        onClicked: steelPlantManager.toggleDevice("blastFurnace", true)
                    }

                    PushButton {
                        text: "停止高炉"
                        Layout.fillWidth: true
                        onClicked: steelPlantManager.toggleDevice("blastFurnace", false)
                    }

                    PushButton {
                        text: "启动转炉"
                        Layout.fillWidth: true
                        onClicked: steelPlantManager.toggleDevice("converter", true)
                    }

                    PushButton {
                        text: "停止转炉"
                        Layout.fillWidth: true
                        onClicked: steelPlantManager.toggleDevice("converter", false)
                    }

                    PushButton {
                        text: "启动轧钢"
                        Layout.fillWidth: true
                        onClicked: steelPlantManager.toggleDevice("rollingMill", true)
                    }

                    PushButton {
                        text: "停止轧钢"
                        Layout.fillWidth: true
                        onClicked: steelPlantManager.toggleDevice("rollingMill", false)
                    }
                }
            }
        }

        // 中间：生产总览Dashboard
        Rectangle {
            Layout.row: 0
            Layout.column: 1
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f0f0f0"
            border.color: "#ccc"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                padding: 10
                spacing: 10

                Text {
                    text: "生产总览Dashboard"
                    font.bold: true
                    font.pointSize: 14
                    Layout.fillWidth: true
                }

                // 告警统计
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        color: "#ffffff"
                        border.color: "#ddd"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            padding: 10
                            spacing: 5

                            Text {
                                text: "紧急告警"
                                font.bold: true
                                font.pointSize: 12
                            }

                            Text {
                                text: steelPlantManager.emergencyAlarmCount
                                font.pointSize: 24
                                font.bold: true
                                color: "#ff0000"
                            }
                        }
                    }

                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        color: "#ffffff"
                        border.color: "#ddd"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            padding: 10
                            spacing: 5

                            Text {
                                text: "一般告警"
                                font.bold: true
                                font.pointSize: 12
                            }

                            Text {
                                text: steelPlantManager.normalAlarmCount
                                font.pointSize: 24
                                font.bold: true
                                color: "#ff9800"
                            }
                        }
                    }
                }

                // 温度趋势图
                Card {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    color: "#ffffff"
                    border.color: "#ddd"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        padding: 10
                        spacing: 5

                        Text {
                            text: "温度趋势"
                            font.bold: true
                            font.pointSize: 12
                        }

                        ChartView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            theme: ChartView.ChartThemeLight
                            antialiasing: true

                            LineSeries {
                                name: "高炉温度"
                                XYPoint { x: 1; y: 1500 }
                                XYPoint { x: 2; y: 1510 }
                                XYPoint { x: 3; y: 1520 }
                                XYPoint { x: 4; y: 1515 }
                                XYPoint { x: 5; y: 1525 }
                                XYPoint { x: 6; y: 1530 }
                                XYPoint { x: 7; y: 1520 }
                            }

                            LineSeries {
                                name: "转炉温度"
                                XYPoint { x: 1; y: 1600 }
                                XYPoint { x: 2; y: 1610 }
                                XYPoint { x: 3; y: 1620 }
                                XYPoint { x: 4; y: 1615 }
                                XYPoint { x: 5; y: 1625 }
                                XYPoint { x: 6; y: 1630 }
                                XYPoint { x: 7; y: 1620 }
                            }

                            LineSeries {
                                name: "轧钢温度"
                                XYPoint { x: 1; y: 1450 }
                                XYPoint { x: 2; y: 1460 }
                                XYPoint { x: 3; y: 1470 }
                                XYPoint { x: 4; y: 1465 }
                                XYPoint { x: 5; y: 1475 }
                                XYPoint { x: 6; y: 1480 }
                                XYPoint { x: 7; y: 1470 }
                            }

                            ValueAxis {
                                id: xAxis
                                min: 0
                                max: 8
                                titleText: "时间"
                            }

                            ValueAxis {
                                id: yAxis
                                min: 1400
                                max: 1650
                                titleText: "温度 (°C)"
                            }

                            axes: [xAxis, yAxis]
                        }
                    }
                }

                // 压力和流量趋势图
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        color: "#ffffff"
                        border.color: "#ddd"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            padding: 10
                            spacing: 5

                            Text {
                                text: "压力趋势"
                                font.bold: true
                                font.pointSize: 12
                            }

                            ChartView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                theme: ChartView.ChartThemeLight
                                antialiasing: true

                                LineSeries {
                                    name: "高炉压力"
                                    XYPoint { x: 1; y: 2.5 }
                                    XYPoint { x: 2; y: 2.6 }
                                    XYPoint { x: 3; y: 2.7 }
                                    XYPoint { x: 4; y: 2.65 }
                                    XYPoint { x: 5; y: 2.75 }
                                    XYPoint { x: 6; y: 2.8 }
                                    XYPoint { x: 7; y: 2.7 }
                                }

                                ValueAxis {
                                    id: pressureXAxis
                                    min: 0
                                    max: 8
                                    titleText: "时间"
                                }

                                ValueAxis {
                                    id: pressureYAxis
                                    min: 2.0
                                    max: 3.0
                                    titleText: "压力 (MPa)"
                                }

                                axes: [pressureXAxis, pressureYAxis]
                            }
                        }
                    }

                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        color: "#ffffff"
                        border.color: "#ddd"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            padding: 10
                            spacing: 5

                            Text {
                                text: "流量趋势"
                                font.bold: true
                                font.pointSize: 12
                            }

                            ChartView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                theme: ChartView.ChartThemeLight
                                antialiasing: true

                                LineSeries {
                                    name: "氧气流量"
                                    XYPoint { x: 1; y: 85 }
                                    XYPoint { x: 2; y: 86 }
                                    XYPoint { x: 3; y: 87 }
                                    XYPoint { x: 4; y: 86.5 }
                                    XYPoint { x: 5; y: 87.5 }
                                    XYPoint { x: 6; y: 88 }
                                    XYPoint { x: 7; y: 87 }
                                }

                                LineSeries {
                                    name: "冷却水流量"
                                    XYPoint { x: 1; y: 90 }
                                    XYPoint { x: 2; y: 91 }
                                    XYPoint { x: 3; y: 92 }
                                    XYPoint { x: 4; y: 91.5 }
                                    XYPoint { x: 5; y: 92.5 }
                                    XYPoint { x: 6; y: 93 }
                                    XYPoint { x: 7; y: 92 }
                                }

                                ValueAxis {
                                    id: flowXAxis
                                    min: 0
                                    max: 8
                                    titleText: "时间"
                                }

                                ValueAxis {
                                    id: flowYAxis
                                    min: 80
                                    max: 100
                                    titleText: "流量 (%)"
                                }

                                axes: [flowXAxis, flowYAxis]
                            }
                        }
                    }
                }
            }
        }

        // 右侧：操作控制区
        Rectangle {
            Layout.row: 0
            Layout.column: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f0f0f0"
            border.color: "#ccc"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                padding: 10
                spacing: 10

                Text {
                    text: "操作控制区"
                    font.bold: true
                    font.pointSize: 14
                    Layout.fillWidth: true
                }

                // 高炉控制
                Card {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    color: "#ffffff"
                    border.color: "#ddd"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        padding: 10
                        spacing: 5

                        Text {
                            text: "高炉控制"
                            font.bold: true
                            font.pointSize: 12
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                spacing: 5

                                Text {
                                    text: "温度: " + steelPlantManager.blastFurnaceStatus["temperature"].toFixed(1) + " °C"
                                }

                                Text {
                                    text: "压力: " + steelPlantManager.blastFurnaceStatus["pressure"].toFixed(2) + " MPa"
                                }

                                Text {
                                    text: "料位: " + steelPlantManager.blastFurnaceStatus["level"].toFixed(1) + "%"
                                }

                                Text {
                                    text: "状态: " + (steelPlantManager.blastFurnaceStatus["status"] ? "运行中" : "停止")
                                }
                            }
                        }
                    }
                }

                // 转炉控制
                Card {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    color: "#ffffff"
                    border.color: "#ddd"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        padding: 10
                        spacing: 5

                        Text {
                            text: "转炉控制"
                            font.bold: true
                            font.pointSize: 12
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                spacing: 5

                                Text {
                                    text: "温度: " + steelPlantManager.converterStatus["temperature"].toFixed(1) + " °C"
                                }

                                Text {
                                    text: "氧气流量: " + steelPlantManager.converterStatus["oxygenFlow"].toFixed(1) + "%"
                                }

                                Text {
                                    text: "钢水液位: " + steelPlantManager.converterStatus["steelLevel"].toFixed(1) + "%"
                                }

                                Text {
                                    text: "状态: " + (steelPlantManager.converterStatus["status"] ? "运行中" : "停止")
                                }
                            }
                        }
                    }
                }

                // 轧钢控制
                Card {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    color: "#ffffff"
                    border.color: "#ddd"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        padding: 10
                        spacing: 5

                        Text {
                            text: "轧钢控制"
                            font.bold: true
                            font.pointSize: 12
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                spacing: 5

                                Text {
                                    text: "速度: " + steelPlantManager.rollingMillStatus["speed"].toFixed(2) + " m/min"
                                }

                                Text {
                                    text: "温度: " + steelPlantManager.rollingMillStatus["temperature"].toFixed(1) + " °C"
                                }

                                Text {
                                    text: "冷却水流量: " + steelPlantManager.rollingMillStatus["coolingWaterFlow"].toFixed(1) + "%"
                                }

                                Text {
                                    text: "状态: " + (steelPlantManager.rollingMillStatus["status"] ? "运行中" : "停止")
                                }
                            }
                        }
                    }
                }

                // 数据导出
                Card {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    color: "#ffffff"
                    border.color: "#ddd"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        padding: 10
                        spacing: 5

                        Text {
                            text: "数据导出"
                            font.bold: true
                            font.pointSize: 12
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            TextField {
                                placeholderText: "开始时间"
                                Layout.fillWidth: true
                            }

                            TextField {
                                placeholderText: "结束时间"
                                Layout.fillWidth: true
                            }

                            PushButton {
                                text: "导出CSV"
                                Layout.fillWidth: true
                                onClicked: steelPlantManager.exportData("2023-01-01", "2023-01-31", "steel_plant_data.csv")
                            }
                        }
                    }
                }
            }
        }
    }

    // 告警弹窗
    Rectangle {
        id: alarmDialog
        anchors.centerIn: parent
        width: 400
        height: 200
        color: "#ffffff"
        border.color: "#ddd"
        border.width: 2
        radius: 5
        visible: false

        ColumnLayout {
            anchors.fill: parent
            padding: 20
            spacing: 10

            Text {
                id: alarmTitle
                text: "告警"
                font.bold: true
                font.pointSize: 16
                Layout.fillWidth: true
            }

            Text {
                id: alarmMessage
                text: "告警信息"
                font.pointSize: 14
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 10

                PushButton {
                    text: "确认"
                    onClicked: {
                        steelPlantManager.acknowledgeAlarm(alarmId);
                        alarmDialog.visible = false;
                    }
                }
            }
        }
    }

    // 告警ID
    property string alarmId: ""

    // 显示告警
    function showAlarm(id, message, isEmergency) {
        alarmId = id;
        alarmTitle.text = isEmergency ? "紧急告警" : "一般告警";
        alarmTitle.color = isEmergency ? "#ff0000" : "#ff9800";
        alarmMessage.text = message;
        alarmDialog.visible = true;
    }

    // 初始化
    Component.onCompleted: {
        console.log("初始化钢铁厂监控平台...");
        steelPlantManager.initialize();
        steelPlantManager.startSimulation();
        simulatedDataSource.initialize();
        simulatedDataSource.start();
        console.log("钢铁厂监控平台初始化完成");
    }

    // 清理
    Component.onDestruction: {
        console.log("清理钢铁厂监控平台...");
        steelPlantManager.stopSimulation();
        simulatedDataSource.stop();
        console.log("钢铁厂监控平台清理完成");
    }
}
