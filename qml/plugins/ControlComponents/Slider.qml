import QtQuick 2.15
import QtQuick.Layouts 1.15

/**
 * @brief 滑块控件组件
 * 
 * 用于通过鼠标拖动来调整数值的水平滑块控件，支持自定义范围、颜色和标签。
 * 可用于调节音量、亮度、温度等参数。
 * 
 * @property value 当前值，默认为0.5
 * @property minValue 最小值，默认为0
 * @property maxValue 最大值，默认为100
 * @property label 控件标签，默认为"Slider"
 * @property unit 数值单位，默认为空字符串
 * @property backgroundColor 背景颜色，默认为"#F5F5F5"
 * @property trackColor 轨道颜色，默认为"#E0E0E0"
 * @property fillColor 填充颜色，默认为"#2196F3"
 * @property thumbColor 滑块颜色，默认为"#2196F3"
 * @property textColor 文本颜色，默认为"#333333"
 * 
 * @signal 无自定义信号，value属性变化时会触发valueChanged信号
 * 
 * @example 基本用法
 * ```qml
 * Slider {
 *     label: "音量"
 *     unit: "%"
 *     minValue: 0
 *     maxValue: 100
 *     value: 50
 *     width: 200
 *     height: 60
 * }
 * ```
 * 
 * @example 自定义颜色
 * ```qml
 * Slider {
 *     label: "亮度"
 *     unit: "%"
 *     minValue: 0
 *     maxValue: 100
 *     value: 75
 *     fillColor: "#4CAF50"
 *     thumbColor: "#4CAF50"
 *     backgroundColor: "#FAFAFA"
 *     width: 250
 *     height: 60
 * }
 * ```
 */
Item {
    id: slider
    
    /**
     * @brief 当前值
     * 
     * 滑块的当前数值，范围在minValue和maxValue之间。
     */
    property real value: 0.5
    
    /**
     * @brief 最小值
     * 
     * 滑块可调节的最小值。
     */
    property real minValue: 0
    
    /**
     * @brief 最大值
     * 
     * 滑块可调节的最大值。
     */
    property real maxValue: 100
    
    /**
     * @brief 控件标签
     * 
     * 显示在滑块左下方的标签文本。
     */
    property string label: "Slider"
    
    /**
     * @brief 数值单位
     * 
     * 显示在数值后面的单位符号。
     */
    property string unit: ""
    
    /**
     * @brief 背景颜色
     * 
     * 控件整体背景颜色。
     */
    property color backgroundColor: "#F5F5F5"
    
    /**
     * @brief 轨道颜色
     * 
     * 滑块轨道的背景颜色。
     */
    property color trackColor: "#E0E0E0"
    
    /**
     * @brief 填充颜色
     * 
     * 滑块已选择部分的填充颜色。
     */
    property color fillColor: "#2196F3"
    
    /**
     * @brief 滑块颜色
     * 
     * 滑块拇指的颜色。
     */
    property color thumbColor: "#2196F3"
    
    /**
     * @brief 文本颜色
     * 
     * 标签和数值文本的颜色。
     */
    property color textColor: "#333333"
    
    implicitWidth: 200
    implicitHeight: 60
    Layout.preferredWidth: 200
    Layout.preferredHeight: 60
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: backgroundColor
        radius: 4
        border.color: "#E0E0E0"
        border.width: 1
    }
    
    // 滑块轨道
    Rectangle {
        id: track
        x: 20
        y: height / 2 - 2
        width: parent.width - 40
        height: 4
        color: trackColor
        radius: 2
        
        // 填充部分
        Rectangle {
            id: fill
            width: parent.width * ((value - minValue) / (maxValue - minValue))
            height: parent.height
            color: fillColor
            radius: 2
        }
    }
    
    // 滑块
    Rectangle {
        id: thumb
        x: 20 + (parent.width - 40) * ((value - minValue) / (maxValue - minValue)) - 8
        y: height / 2 - 8
        width: 16
        height: 16
        color: thumbColor
        radius: 8
        border.color: "#1976D2"
        border.width: 2
        
        /**
         * @brief 鼠标事件处理
         * 
         * 处理鼠标拖动事件，根据滑块位置计算对应的值。
         */
        MouseArea {
            anchors.fill: parent
            drag.target: thumb
            drag.axis: Drag.XAxis
            drag.minimumX: 20 - 8
            drag.maximumX: parent.width - 20 - 8
            
            onDragChanged: {
                const newValue = minValue + (maxValue - minValue) * ((thumb.x + 8 - 20) / (parent.width - 40));
                slider.value = Math.max(minValue, Math.min(maxValue, newValue));
            }
        }
    }
    
    // 标签
    Text {
        id: labelText
        text: label
        font.pixelSize: 14
        font.bold: true
        color: textColor
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
    }
    
    // 数值显示
    Text {
        id: valueText
        text: value.toFixed(1) + unit
        font.pixelSize: 14
        color: textColor
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
    }
}