import QtQuick 2.15
import QtQuick.Controls 2.15

/**
 * @brief 储罐组件
 * 
 * 用于显示储罐液位高度的工业组件，支持动画效果和数据标签关联。
 * 可用于工业监控系统中的液体、气体等储罐状态显示。
 * 
 * @property level 液位高度，范围0.0-1.0，默认为0.5
 * @property tagName 数据标签名称，默认为空字符串
 * @property tagValue 数据标签值，默认为null
 * @property fillColor 填充颜色，默认为"#2196F3"（蓝色）
 * @property emptyColor 空罐颜色，默认为"#E0E0E0"（浅灰色）
 * @property showLevelText 是否显示液位文本，默认为true
 * @property unit 液位单位，默认为"%"
 * 
 * @signal 无自定义信号
 * 
 * @example 基本用法
 * ```qml
 * Tank {
 *     width: 120
 *     height: 180
 *     level: 0.75
 *     showLevelText: true
 *     fillColor: "#2196F3"
 * }
 * ```
 * 
 * @example 关联数据标签
 * ```qml
 * Tank {
 *     width: 100
 *     height: 150
 *     tagName: "Water_Tank"
 *     fillColor: "#2196F3"
 *     unit: "%"
 * }
 * ```
 */
Item {
    id: tank
    width: 120
    height: 180

    /**
     * @brief 液位高度
     * 
     * 储罐的液位高度，范围为0.0（空）到1.0（满）。
     */
    property real level: 0.5 // 0.0 to 1.0
    
    /**
     * @brief 数据标签名称
     * 
     * 关联的数据标签名称，用于从标签系统获取数据。
     */
    property string tagName: ""
    
    /**
     * @brief 数据标签值
     * 
     * 关联的数据标签值，当值变化时会自动更新level状态。
     */
    property var tagValue: null
    
    /**
     * @brief 填充颜色
     * 
     * 储罐中液体的填充颜色，支持渐变效果。
     */
    property color fillColor: "#2196F3"
    
    /**
     * @brief 空罐颜色
     * 
     * 储罐中空余部分的颜色。
     */
    property color emptyColor: "#E0E0E0"
    
    /**
     * @brief 是否显示液位文本
     * 
     * 控制是否在储罐顶部显示液位百分比文本。
     */
    property bool showLevelText: true
    
    /**
     * @brief 液位单位
     * 
     * 显示在液位文本后面的单位符号。
     */
    property string unit: "%"

    /**
     * @brief 根据标签值更新储罐液位
     * 
     * 当tagValue属性变化且tagName不为空时，自动更新level状态。
     * 假设标签值为0-100的百分比值。
     */
    onTagValueChanged: {
        if (tagName !== "") {
            // Assuming tag value is 0-100 for percentage
            level = Math.max(0, Math.min(1, Number(tagValue) / 100));
        }
    }

    // Tank outline
    Rectangle {
        id: tankOutline
        anchors.fill: parent
        color: "#757575"
        radius: 8
        border.color: "#424242"
        border.width: 2

        // Tank bottom
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.8
            height: 10
            color: "#757575"
            border.color: "#424242"
            border.width: 2
            y: 5
        }

        // Tank top
        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.6
            height: 10
            color: "#757575"
            border.color: "#424242"
            border.width: 2
            y: -5
        }

        // Fill level
        Rectangle {
            id: tankFill
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height * level
            color: fillColor
            border.color: "#1976D2"
            border.width: 1
            // Add gradient for better visual effect
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: fillColor
                }
                GradientStop {
                    position: 1.0
                    color: Qt.darker(fillColor, 1.2)
                }
            }

            /**
             * @brief 液位变化动画
             * 
             * 当液位高度变化时，会以1000毫秒的时间平滑过渡。
             */
            Behavior on height {
                NumberAnimation {
                    duration: 1000
                    easing.type: Easing.InOutQuad
                }
            }
        }

        // Empty space
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: tankFill.top
            anchors.left: parent.left
            anchors.right: parent.right
            color: emptyColor
            opacity: 0.5
        }
    }

    // Level text
    Text {
        visible: showLevelText
        text: Math.round(level * 100) + unit
        font.pixelSize: 14
        font.bold: true
        color: "#333"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        y: 10
    }

    // Tag name label
    Text {
        visible: tagName !== ""
        text: tagName
        font.pixelSize: 10
        color: "#666"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        y: -5
    }
}
