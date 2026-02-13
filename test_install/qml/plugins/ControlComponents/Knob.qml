import QtQuick 2.15
import QtQuick.Controls 2.15

/**
 * @brief 旋钮控件组件
 * 
 * 用于通过鼠标拖动旋转来调整数值的控件，支持自定义范围、颜色和标签。
 * 可用于调节温度、速度、压力等参数。
 * 
 * @property value 当前值，默认为0.5
 * @property minValue 最小值，默认为0
 * @property maxValue 最大值，默认为100
 * @property label 控件标签，默认为"Knob"
 * @property unit 数值单位，默认为空字符串
 * @property backgroundColor 背景颜色，默认为"#F5F5F5"
 * @property trackColor 轨道颜色，默认为"#E0E0E0"
 * @property fillColor 填充颜色，默认为"#2196F3"
 * @property knobColor 旋钮颜色，默认为"#FFFFFF"
 * @property textColor 文本颜色，默认为"#333333"
 * 
 * @signal 无自定义信号，value属性变化时会触发valueChanged信号
 * 
 * @example 基本用法
 * ```qml
 * Knob {
 *     label: "温度"
 *     unit: "°C"
 *     minValue: 0
 *     maxValue: 100
 *     value: 25
 *     width: 120
 *     height: 150
 * }
 * ```
 * 
 * @example 自定义颜色
 * ```qml
 * Knob {
 *     label: "压力"
 *     unit: "bar"
 *     minValue: 0
 *     maxValue: 10
 *     value: 5
 *     fillColor: "#4CAF50"
 *     trackColor: "#E0E0E0"
 *     backgroundColor: "#FAFAFA"
 *     width: 100
 *     height: 130
 * }
 * ```
 */
Item {
    id: knob
    
    /**
     * @brief 当前值
     * 
     * 旋钮的当前数值，范围在minValue和maxValue之间。
     */
    property real value: 0.5
    
    /**
     * @brief 最小值
     * 
     * 旋钮可调节的最小值。
     */
    property real minValue: 0
    
    /**
     * @brief 最大值
     * 
     * 旋钮可调节的最大值。
     */
    property real maxValue: 100
    
    /**
     * @brief 控件标签
     * 
     * 显示在旋钮下方的标签文本。
     */
    property string label: "Knob"
    
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
     * 旋钮背景圆环的颜色。
     */
    property color trackColor: "#E0E0E0"
    
    /**
     * @brief 填充颜色
     * 
     * 旋钮进度填充的颜色，也用于指示线。
     */
    property color fillColor: "#2196F3"
    
    /**
     * @brief 旋钮颜色
     * 
     * 旋钮主体的颜色。
     */
    property color knobColor: "#FFFFFF"
    
    /**
     * @brief 文本颜色
     * 
     * 标签和数值文本的颜色。
     */
    property color textColor: "#333333"
    
    width: 120
    height: 150
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: backgroundColor
        radius: 4
        border.color: "#E0E0E0"
        border.width: 1
    }
    
    // 旋钮主体
    Item {
        id: knobBody
        width: 100
        height: 100
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        
        // 背景圆环
        Canvas {
            id: backgroundCanvas
            anchors.fill: parent
            
            /**
             * @brief 绘制旋钮背景和进度圆环
             * 
             * 绘制背景圆环和根据当前值计算的进度填充圆环。
             */
            onPaint: {
                const ctx = getContext("2d");
                const centerX = width / 2;
                const centerY = height / 2;
                const radius = Math.min(centerX, centerY) - 10;
                
                // 清除画布
                ctx.clearRect(0, 0, width, height);
                
                // 绘制背景圆环
                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
                ctx.lineWidth = 8;
                ctx.strokeStyle = trackColor;
                ctx.stroke();
                
                // 绘制填充圆环
                const normalizedValue = Math.max(0, Math.min(1, (value - minValue) / (maxValue - minValue)));
                const endAngle = Math.PI * 1.5 - Math.PI * 2 * normalizedValue;
                
                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, Math.PI * 1.5, endAngle, true);
                ctx.lineWidth = 8;
                ctx.strokeStyle = fillColor;
                ctx.stroke();
            }
            
            Connections {
                target: knob
                function onValueChanged() {
                    backgroundCanvas.requestPaint();
                }
            }
        }
        
        // 旋钮
        Rectangle {
            id: knobControl
            width: 80
            height: 80
            anchors.centerIn: parent
            color: knobColor
            radius: 40
            border.color: "#E0E0E0"
            border.width: 2
            
            // 指示线
            Rectangle {
                width: 4
                height: 30
                color: fillColor
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 2
            }
            
            /**
             * @brief 鼠标事件处理
             * 
             * 处理鼠标按下和拖动事件，根据鼠标位置计算旋钮角度和对应的值。
             */
            MouseArea {
                anchors.fill: parent
                property var startAngle: 0
                property var startValue: value
                
                onPressed: {
                    const centerX = knobBody.width / 2;
                    const centerY = knobBody.height / 2;
                    startAngle = Math.atan2(mouseY - centerY, mouseX - centerX);
                    startValue = value;
                }
                
                onMouseXChanged: {
                    if (pressed) {
                        const centerX = knobBody.width / 2;
                        const centerY = knobBody.height / 2;
                        const currentAngle = Math.atan2(mouseY - centerY, mouseX - centerX);
                        let angleDiff = currentAngle - startAngle;
                        
                        // 处理角度跨越
                        if (angleDiff > Math.PI) {
                            angleDiff -= Math.PI * 2;
                        } else if (angleDiff < -Math.PI) {
                            angleDiff += Math.PI * 2;
                        }
                        
                        // 计算新值
                        const valueRange = maxValue - minValue;
                        const valueDiff = angleDiff / (Math.PI * 2) * valueRange;
                        const newValue = startValue - valueDiff;
                        
                        knob.value = Math.max(minValue, Math.min(maxValue, newValue));
                    }
                }
                
                onMouseYChanged: {
                    if (pressed) {
                        const centerX = knobBody.width / 2;
                        const centerY = knobBody.height / 2;
                        const currentAngle = Math.atan2(mouseY - centerY, mouseX - centerX);
                        let angleDiff = currentAngle - startAngle;
                        
                        // 处理角度跨越
                        if (angleDiff > Math.PI) {
                            angleDiff -= Math.PI * 2;
                        } else if (angleDiff < -Math.PI) {
                            angleDiff += Math.PI * 2;
                        }
                        
                        // 计算新值
                        const valueRange = maxValue - minValue;
                        const valueDiff = angleDiff / (Math.PI * 2) * valueRange;
                        const newValue = startValue - valueDiff;
                        
                        knob.value = Math.max(minValue, Math.min(maxValue, newValue));
                    }
                }
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
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
    }
    
    // 数值显示
    Text {
        id: valueText
        text: value.toFixed(1) + unit
        font.pixelSize: 14
        color: textColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: labelText.top
        anchors.bottomMargin: 5
    }
}