import QtQuick 2.15
import QtQuick.Controls 2.15

/**
 * @brief 水泵组件
 * 
 * 用于模拟和显示水泵运行状态的工业组件，支持动画效果和数据标签关联。
 * 可用于工业监控系统中的水泵状态显示和控制。
 * 
 * @property running 是否运行，默认为false
 * @property tagName 数据标签名称，默认为空字符串
 * @property tagValue 数据标签值，默认为null
 * @property runningColor 运行状态颜色，默认为"#4CAF50"（绿色）
 * @property stoppedColor 停止状态颜色，默认为"#F44336"（红色）
 * @property showStatusText 是否显示状态文本，默认为true
 * 
 * @signal pumpClicked(var value) 水泵状态变更信号，参数为新的运行状态
 * 
 * @example 基本用法
 * ```qml
 * Pump {
 *     width: 120
 *     height: 120
 *     running: true
 *     showStatusText: true
 * }
 * ```
 * 
 * @example 关联数据标签
 * ```qml
 * Pump {
 *     width: 100
 *     height: 100
 *     tagName: "Main_Pump"
 *     runningColor: "#4CAF50"
 *     stoppedColor: "#F44336"
 *     onPumpClicked: function(value) {
 *         console.log("Pump state changed:", value);
 *     }
 * }
 * ```
 */
Item {
    id: pump
    width: 120
    height: 120

    /**
     * @brief 是否运行
     * 
     * 控制水泵的运行状态，true为运行，false为停止。
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
     * 水泵运行时的状态指示器颜色。
     */
    property color runningColor: "#4CAF50"
    
    /**
     * @brief 停止状态颜色
     * 
     * 水泵停止时的状态指示器颜色。
     */
    property color stoppedColor: "#F44336"
    
    /**
     * @brief 是否显示状态文本
     * 
     * 控制是否在水泵下方显示"RUNNING"或"STOPPED"状态文本。
     */
    property bool showStatusText: true

    /**
     * @brief 根据标签值更新水泵状态
     * 
     * 当tagValue属性变化且tagName不为空时，自动更新running状态。
     */
    onTagValueChanged: {
        if (tagName !== "") {
            running = Boolean(tagValue);
        }
    }

    // Pump body
    Rectangle {
        id: pumpBody
        anchors.centerIn: parent
        width: 80
        height: 60
        color: "#757575"
        radius: 8
        border.color: "#424242"
        border.width: 2

        // Pump inlet
        Rectangle {
            id: pumpInlet
            width: 15
            height: 30
            color: "#9E9E9E"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            x: -7
            radius: 7
        }

        // Pump outlet
        Rectangle {
            id: pumpOutlet
            width: 15
            height: 30
            color: "#9E9E9E"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            x: 7
            radius: 7
        }

        // Pump impeller (rotating part)
        Rectangle {
            id: pumpImpeller
            width: 40
            height: 40
            color: "#616161"
            anchors.centerIn: parent
            radius: 20

            // Impeller blades
            Repeater {
                model: 4
                Rectangle {
                    width: 3
                    height: 20
                    color: "#9E9E9E"
                    anchors.centerIn: pumpImpeller
                    rotation: index * 90
                    transformOrigin: Item.Center
                }
            }

            /**
             * @brief 叶轮旋转动画
             * 
             * 当水泵运行时，叶轮会以800毫秒/圈的速度旋转。
             */
            RotationAnimation {
                target: pumpImpeller
                from: 0
                to: 360
                duration: 800
                running: pump.running
                loops: Animation.Infinite
                easing.type: Easing.Linear
            }
        }

        // Pump status indicator
        Rectangle {
            id: statusIndicator
            width: 10
            height: 10
            radius: 5
            color: running ? runningColor : stoppedColor
            anchors.top: parent.top
            anchors.right: parent.right
            x: -5
            y: 5

            // Add glow effect when running
            Rectangle {
                anchors.fill: statusIndicator
                radius: 5
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

    // Pump status text
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
     * 处理鼠标点击事件，切换水泵运行状态并发送pumpClicked信号。
     */
    MouseArea {
        anchors.fill: parent
        onClicked: {
            running = !running;
            if (tagName !== "") {
                pumpClicked(running);
            }
        }
    }

    /**
     * @brief 水泵状态变更信号
     * 
     * 当水泵状态变更时发出的信号，参数为新的运行状态。
     */
    signal pumpClicked(var value)
}
