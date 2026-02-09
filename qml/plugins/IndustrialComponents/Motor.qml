import QtQuick 2.15
import QtQuick.Controls 2.15

/**
 * @brief 电机组件
 * 
 * 用于模拟和显示电机运行状态的工业组件，支持动画效果和数据标签关联。
 * 可用于工业监控系统中的电机状态显示和控制。
 * 
 * @property running 是否运行，默认为false
 * @property tagName 数据标签名称，默认为空字符串
 * @property tagValue 数据标签值，默认为null
 * @property runningColor 运行状态颜色，默认为"#4CAF50"（绿色）
 * @property stoppedColor 停止状态颜色，默认为"#F44336"（红色）
 * @property showStatusText 是否显示状态文本，默认为true
 * 
 * @signal motorClicked(var value) 电机状态变更信号，参数为新的运行状态
 * 
 * @example 基本用法
 * ```qml
 * Motor {
 *     width: 120
 *     height: 120
 *     running: true
 *     showStatusText: true
 * }
 * ```
 * 
 * @example 关联数据标签
 * ```qml
 * Motor {
 *     width: 100
 *     height: 100
 *     tagName: "Main_Motor"
 *     runningColor: "#4CAF50"
 *     stoppedColor: "#F44336"
 *     onMotorClicked: function(value) {
 *         console.log("Motor state changed:", value);
 *     }
 * }
 * ```
 */
Item {
    id: motor
    width: 120
    height: 120

    /**
     * @brief 是否运行
     * 
     * 控制电机的运行状态，true为运行，false为停止。
     */
    property bool running: false
    
    /**
     * @brief 数据标签名称
     * 
     * 关联的数据标签名称，用于从标签系统获取数据和发送命令。
     */
    property string tagName: ""
    
    /**
     * @brief 数据标签值
     * 
     * 关联的数据标签值，当值变化时会自动更新running状态。
     */
    property var tagValue: null
    
    /**
     * @brief 运行状态颜色
     * 
     * 电机运行时的状态指示器颜色。
     */
    property color runningColor: "#4CAF50"
    
    /**
     * @brief 停止状态颜色
     * 
     * 电机停止时的状态指示器颜色。
     */
    property color stoppedColor: "#F44336"
    
    /**
     * @brief 是否显示状态文本
     * 
     * 控制是否在电机下方显示"RUNNING"或"STOPPED"状态文本。
     */
    property bool showStatusText: true

    /**
     * @brief 根据标签值更新电机状态
     * 
     * 当tagValue属性变化且tagName不为空时，自动更新running状态。
     */
    onTagValueChanged: {
        if (tagName !== "") {
            running = Boolean(tagValue);
        }
    }

    // Motor body
    Rectangle {
        id: motorBody
        anchors.centerIn: parent
        width: 100
        height: 80
        color: "#757575"
        radius: 8
        border.color: "#424242"
        border.width: 2

        // Motor shaft
        Rectangle {
            id: motorShaft
            width: 10
            height: 40
            color: "#9E9E9E"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            x: 5
            radius: 5
        }

        // Motor fan (revolving part)
        Rectangle {
            id: motorFan
            width: 20
            height: 60
            color: "#616161"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            x: -5
            radius: 10

            // Fan blades
            Repeater {
                model: 4
                Rectangle {
                    width: 15
                    height: 3
                    color: "#9E9E9E"
                    anchors.centerIn: motorFan
                    rotation: index * 90
                    transformOrigin: Item.Center
                }
            }

            /**
             * @brief 风扇旋转动画
             * 
             * 当电机运行时，风扇会以1000毫秒/圈的速度旋转。
             */
            RotationAnimation {
                target: motorFan
                from: 0
                to: 360
                duration: 1000
                running: motor.running
                loops: Animation.Infinite
                easing.type: Easing.Linear
            }
        }

        // Motor status indicator
        Rectangle {
            id: statusIndicator
            width: 12
            height: 12
            radius: 6
            color: running ? runningColor : stoppedColor
            anchors.top: parent.top
            anchors.right: parent.right
            x: -5
            y: 5

            // Add glow effect when running
            Rectangle {
                anchors.fill: statusIndicator
                radius: 6
                color: running ? runningColor : "transparent"
                opacity: running ? 0.5 : 0
                scale: running ? 1.5 : 1

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 300
                    }
                }
            }
        }
    }

    // Motor status text
    Text {
        visible: showStatusText
        text: running ? "RUNNING" : "STOPPED"
        font.pixelSize: 12
        font.bold: true
        color: running ? runningColor : stoppedColor
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        y: -5
    }

    /**
     * @brief 鼠标点击处理
     * 
     * 处理鼠标点击事件，切换电机运行状态并发送motorClicked信号。
     */
    MouseArea {
        anchors.fill: parent
        onClicked: {
            running = !running;
            if (tagName !== "") {
                motorClicked(running);
            }
        }
    }

    /**
     * @brief 电机状态变更信号
     * 
     * 当电机状态变更时发出的信号，参数为新的运行状态。
     */
    signal motorClicked(var value)
}
