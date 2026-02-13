import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    
    // 可自定义属性
    property color backgroundColor: "#212121"
    property color textColor: "#4CAF50"
    property color borderColor: "#616161"
    property int borderWidth: 1
    property int cornerRadius: 4
    
    // 数值属性
    property real value: 0
    property int decimalPlaces: 2
    property string unit: ""
    property string label: ""
    property color labelColor: "#9E9E9E"
    
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
    
    // 标签显示
    Text {
        id: labelText
        text: label
        color: labelColor
        font.pixelSize: root.height * 0.3
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 8
    }
    
    // 数值显示
    Text {
        id: valueText
        text: value.toFixed(decimalPlaces) + (unit ? " " + unit : "")
        color: textColor
        font.pixelSize: root.height * 0.4
        font.bold: true
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 8
        
        // 文本变化动画
        Behavior on text {
            NumberAnimation {
                duration: animationDuration
                easing.type: Easing.OutCubic
            }
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
    
    // 默认尺寸
    width: 150
    height: 60
}
