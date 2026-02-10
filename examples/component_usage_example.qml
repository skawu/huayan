import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SCADASystemQml 1.0
import BasicComponents 1.0
import IndustrialComponents 1.0
import HMIControls 1.0
import ControlComponents 1.0
import ThreeDComponents 1.0

Window {
    width: 800
    height: 600
    visible: true
    title: "SCADASystem 组件使用示例"

    // 主布局
    ColumnLayout {
        anchors.fill: parent
        padding: 20
        spacing: 20

        Text {
            text: "=== SCADASystem 组件使用示例 ==="
            font.bold: true
            font.pointSize: 16
            Layout.fillWidth: true
        }

        // 1. 基础组件使用示例
        GroupBox {
            title: "1. 基础组件使用示例"
            Layout.fillWidth: true
            Layout.preferredHeight: 150

            RowLayout {
                anchors.fill: parent
                padding: 10
                spacing: 20

                // 按钮组件
                PushButton {
                    text: "按钮示例"
                    onClicked: console.log("按钮被点击")
                }

                // 文本标签组件
                TextLabel {
                    text: "文本标签示例"
                    font.pointSize: 12
                }

                // 指示器组件
                Indicator {
                    value: 0.75
                    color: "#4CAF50"
                }
            }
        }

        // 2. 工业组件使用示例
        GroupBox {
            title: "2. 工业组件使用示例"
            Layout.fillWidth: true
            Layout.preferredHeight: 150

            RowLayout {
                anchors.fill: parent
                padding: 10
                spacing: 20

                // 阀门组件
                Valve {
                    size: 80
                    open: true
                }

                // 储罐组件
                Tank {
                    size: 80
                    level: 0.6
                    color: "#2196F3"
                }

                // 电机组件
                Motor {
                    size: 80
                    running: true
                }

                // 泵组件
                Pump {
                    size: 80
                    running: true
                }
            }
        }

        // 3. HMI控件使用示例
        GroupBox {
            title: "3. HMI控件使用示例"
            Layout.fillWidth: true
            Layout.preferredHeight: 150

            RowLayout {
                anchors.fill: parent
                padding: 10
                spacing: 20

                // 仪表盘组件
                Gauge {
                    value: 85.5
                    minValue: 0
                    maxValue: 100
                    unit: "°C"
                    size: 120
                }

                // 其他HMI控件可以在这里添加
            }
        }

        // 4. 3D组件使用示例
        GroupBox {
            title: "4. 3D组件使用示例"
            Layout.fillWidth: true
            Layout.preferredHeight: 150

            RowLayout {
                anchors.fill: parent
                padding: 10
                spacing: 20

                Text {
                    text: "3D组件使用示例"
                    font.pointSize: 12
                }

                // 3D组件可以在这里添加
            }
        }

        // 5. 控制组件使用示例
        GroupBox {
            title: "5. 控制组件使用示例"
            Layout.fillWidth: true
            Layout.preferredHeight: 150

            RowLayout {
                anchors.fill: parent
                padding: 10
                spacing: 20

                Text {
                    text: "控制组件使用示例"
                    font.pointSize: 12
                }

                // 控制组件可以在这里添加
            }
        }
    }

    // 组件使用说明
    Component.onCompleted: {
        console.log("=== SCADASystem 组件使用示例 ===");
        console.log("此示例展示了如何在QML中使用SCADASystem项目的各种组件");
        console.log("包括基础组件、工业组件、HMI控件、3D组件和控制组件");
        console.log("=== 组件使用示例说明 ===");
    }
}
