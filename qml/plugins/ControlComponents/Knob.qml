import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: knob
    
    property real value: 0.5
    property real minValue: 0
    property real maxValue: 100
    property string label: "Knob"
    property string unit: ""
    property color backgroundColor: "#F5F5F5"
    property color trackColor: "#E0E0E0"
    property color fillColor: "#2196F3"
    property color knobColor: "#FFFFFF"
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