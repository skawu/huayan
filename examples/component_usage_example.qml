import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import HYSCADASystemQml 1.0
import HYBasicComponents 1.0
import HYIndustrialComponents 1.0
import HYHMIControls 1.0
import HYControlComponents 1.0
import HYThreeDComponents 1.0

Window {
    width: 800
    height: 600
    visible: true
    title: "华颜工业SCADA系统组件使用示例"

    // 主布局
    ColumnLayout {
        anchors.fill: parent
        padding: 20
        spacing: 20

        Text {
            text: "=== 华颜工业SCADA系统组件使用示例 ==="
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
                HYPushButton {
                    text: "按钮示例"
                    onClicked: console.log("按钮被点击")
                }

                // 文本标签组件
                HYTextLabel {
                    text: "文本标签示例"
                    font.pointSize: 12
                }

                // 指示器组件
                HYIndicator {
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
                HYValve {
                    size: 80
                    open: true
                }

                // 储罐组件
                HYTank {
                    size: 80
                    level: 0.6
                    color: "#2196F3"
                }

                // 电机组件
                HYMotor {
                    size: 80
                    running: true
                }

                // 泵组件
                HYPump {
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
                HYGauge {
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
        console.log("=== 华颜工业SCADA系统组件使用示例 ===");
        console.log("此示例展示了如何在QML中使用华颜工业SCADA系统项目的各种组件");
        console.log("包括基础组件、工业组件、HMI控件、3D组件和控制组件");
        console.log("=== 组件使用示例说明 ===");
    }
}
