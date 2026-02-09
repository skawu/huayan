import QtQuick 2.15
import QtQuick.Controls 2.15

/**
 * @brief 阀门组件
 * 
 * 用于模拟和显示阀门开关状态的工业组件，支持动画效果和数据标签关联。
 * 可用于工业监控系统中的阀门状态显示和控制。
 * 
 * @property open 是否打开，默认为false
 * @property tagName 数据标签名称，默认为空字符串
 * @property tagValue 数据标签值，默认为null
 * @property openColor 打开状态颜色，默认为"#4CAF50"（绿色）
 * @property closedColor 关闭状态颜色，默认为"#F44336"（红色）
 * 
 * @signal valveClicked(var value) 阀门状态变更信号，参数为新的开关状态
 * 
 * @example 基本用法
 * ```qml
 * Valve {
 *     width: 100
 *     height: 100
 *     open: true
 * }
 * ```
 * 
 * @example 关联数据标签
 * ```qml
 * Valve {
 *     width: 120
 *     height: 120
 *     tagName: "Main_Valve"
 *     openColor: "#4CAF50"
 *     closedColor: "#F44336"
 *     onValveClicked: function(value) {
 *         console.log("Valve state changed:", value);
 *     }
 * }
 * ```
 */
Item {
    id: valve
    width: 100
    height: 100

    /**
     * @brief 是否打开
     * 
     * 控制阀门的开关状态，true为打开，false为关闭。
     */
    property bool open: false
    
    /**
     * @brief 数据标签名称
     * 
     * 关联的数据标签名称，用于从标签系统获取数据和发送命令。
     */
    property string tagName: ""
    
    /**
     * @brief 数据标签值
     * 
     * 关联的数据标签值，当值变化时会自动更新open状态。
     */
    property var tagValue: null
    
    /**
     * @brief 打开状态颜色
     * 
     * 阀门打开时的手柄颜色和文本颜色。
     */
    property color openColor: "#4CAF50"
    
    /**
     * @brief 关闭状态颜色
     * 
     * 阀门关闭时的手柄颜色和文本颜色。
     */
    property color closedColor: "#F44336"

    /**
     * @brief 根据标签值更新阀门状态
     * 
     * 当tagValue属性变化且tagName不为空时，自动更新open状态。
     */
    onTagValueChanged: {
        if (tagName !== "") {
            open = Boolean(tagValue);
        }
    }

    // Valve body
    Rectangle {
        id: valveBody
        anchors.centerIn: parent
        width: 80
        height: 60
        color: "#757575"
        radius: 8

        // Valve stem
        Rectangle {
            id: valveStem
            anchors.horizontalCenter: parent.horizontalCenter
            width: 8
            height: 40
            color: "#9E9E9E"
            y: 10
        }

        // Valve handle
        Rectangle {
            id: valveHandle
            width: 30
            height: 8
            color: open ? openColor : closedColor
            radius: 4
            anchors.centerIn: valveStem
            rotation: open ? 90 : 0

            /**
             * @brief 手柄旋转动画
             * 
             * 当阀门状态变更时，手柄会以500毫秒的时间平滑旋转。
             */
            Behavior on rotation {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    // Valve label
    Text {
        text: open ? "OPEN" : "CLOSED"
        font.pixelSize: 12
        font.bold: true
        color: open ? openColor : closedColor
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        y: -5
    }

    /**
     * @brief 鼠标点击处理
     * 
     * 处理鼠标点击事件，切换阀门开关状态并发送valveClicked信号。
     */
    MouseArea {
        anchors.fill: parent
        onClicked: {
            open = !open;
            if (tagName !== "") {
                valveClicked(open);
            }
        }
    }

    /**
     * @brief 阀门状态变更信号
     * 
     * 当阀门状态变更时发出的信号，参数为新的开关状态。
     */
    signal valveClicked(var value)
}
