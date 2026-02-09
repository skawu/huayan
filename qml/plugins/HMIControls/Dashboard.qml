import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Item {
    id: root
    
    // 可自定义属性
    property color backgroundColor: "#212121"
    property color borderColor: "#616161"
    property color scaleColor: "#9E9E9E"
    property color needleColor: "#F44336"
    property color valueColor: "#FFFFFF"
    property color labelColor: "#9E9E9E"
    property int size: 200
    property int borderWidth: 2
    
    // 数值属性
    property real value: 0
    property real minValue: 0
    property real maxValue: 100
    property int decimalPlaces: 0
    property string unit: ""
    property string label: ""
    
    // 设备点位绑定
    property string tagName: ""
    property bool bindToTag: false
    property real tagValue: 0
    
    // 动画属性
    property int animationDuration: 500
    
    // 尺寸
    width: size
    height: size
    
    // 背景
    Rectangle {
        id: background
        anchors.fill: parent
        radius: width / 2
        color: backgroundColor
        border.width: borderWidth
        border.color: borderColor
    }
    
    // 刻度盘
    Canvas {
        id: scale
        anchors.fill: parent
        
        onPaint: {
            var ctx = getContext("2d")
            var centerX = width / 2
            var centerY = height / 2
            var radius = width * 0.7
            
            // 清除画布
            ctx.clearRect(0, 0, width, height)
            
            // 绘制刻度
            ctx.strokeStyle = scaleColor
            ctx.lineWidth = 2
            
            // 绘制主刻度
            for (var i = 0; i <= 10; i++) {
                var angle = Math.PI * 0.2 + Math.PI * 1.6 * (i / 10)
                var x1 = centerX + Math.cos(angle) * radius
                var y1 = centerY + Math.sin(angle) * radius
                var x2 = centerX + Math.cos(angle) * (radius - 15)
                var y2 = centerY + Math.sin(angle) * (radius - 15)
                
                ctx.beginPath()
                ctx.moveTo(x1, y1)
                ctx.lineTo(x2, y2)
                ctx.stroke()
                
                // 绘制刻度值
                var textAngle = Math.PI * 0.2 + Math.PI * 1.6 * (i / 10)
                var textX = centerX + Math.cos(textAngle) * (radius - 30)
                var textY = centerY + Math.sin(textAngle) * (radius - 30)
                
                ctx.fillStyle = scaleColor
                ctx.font = "12px Arial"
                ctx.textAlign = "center"
                ctx.textBaseline = "middle"
                ctx.fillText(Math.round(minValue + (maxValue - minValue) * (i / 10)), textX, textY)
            }
        }
    }
    
    // 指针
    Item {
        id: needleContainer
        anchors.centerIn: parent
        width: root.width * 0.8
        height: root.height * 0.8
        
        // 指针旋转
        transform: [
            Rotation {
                id: needleRotation
                origin.x: needleContainer.width / 2
                origin.y: needleContainer.height * 0.8
                angle: 36 + (value - minValue) / (maxValue - minValue) * 288
                
                Behavior on angle {
                    NumberAnimation {
                        duration: animationDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }
        ]
        
        // 指针
        Rectangle {
            id: needle
            width: 4
            height: parent.height * 0.7
            color: needleColor
            radius: 2
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            
            // 指针效果
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(1, 1, 1, 0.3)
                width: 2
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        
        // 指针中心点
        Rectangle {
            width: 15
            height: 15
            radius: 7.5
            color: needleColor
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
    
    // 数值显示
    Text {
        id: valueText
        text: value.toFixed(decimalPlaces) + (unit ? " " + unit : "")
        color: valueColor
        font.pixelSize: size * 0.12
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: size * 0.15
    }
    
    // 标签显示
    Text {
        id: labelText
        text: label
        color: labelColor
        font.pixelSize: size * 0.08
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: size * 0.1
    }
    
    // 点位值变化处理
    onTagValueChanged: {
        if (bindToTag) {
            root.value = tagValue
        }
    }
    
    // 值变化信号
    signal valueChanged(real newValue)
    
    // 值变化处理
    onValueChanged: {
        root.valueChanged(value)
    }
}
