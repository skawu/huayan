import QtQuick 2.15

Item {
    id: root
    
    // 可自定义属性
    property color backgroundColor: "#9E9E9E"
    property color progressColor: "#4CAF50"
    property color borderColor: "#616161"
    property color textColor: "#FFFFFF"
    property int height: 30
    property int borderWidth: 1
    property int cornerRadius: 4
    
    // 进度属性
    property real value: 0
    property real minValue: 0
    property real maxValue: 100
    property bool showText: true
    property string unit: "%"
    property int decimalPlaces: 0
    
    // 设备点位绑定
    property string tagName: ""
    property bool bindToTag: false
    property real tagValue: 0
    
    // 动画属性
    property int animationDuration: 300
    
    // 背景
    Rectangle {
        id: background
        anchors.fill: parent
        radius: cornerRadius
        color: backgroundColor
        border.width: borderWidth
        border.color: borderColor
    }
    
    // 进度条
    Rectangle {
        id: progress
        height: parent.height
        radius: cornerRadius
        color: progressColor
        
        // 宽度动画
        width: (root.value - root.minValue) / (root.maxValue - root.minValue) * root.width
        
        Behavior on width {
            NumberAnimation {
                duration: animationDuration
                easing.type: Easing.OutCubic
            }
        }
        
        // 渐变效果
        LinearGradient {
            anchors.fill: parent
            start: Qt.point(0, 0)
            end: Qt.point(parent.width, 0)
            
            GradientStop {
                position: 0
                color: Qt.rgba(1, 1, 1, 0.3)
            }
            GradientStop {
                position: 1
                color: Qt.rgba(1, 1, 1, 0)
            }
        }
    }
    
    // 文本显示
    Text {
        id: valueText
        visible: showText
        text: ((value - minValue) / (maxValue - minValue) * 100).toFixed(decimalPlaces) + unit
        color: textColor
        font.pixelSize: height * 0.6
        font.bold: true
        anchors.centerIn: parent
        
        // 文本阴影
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.2)
            z: -1
        }
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
