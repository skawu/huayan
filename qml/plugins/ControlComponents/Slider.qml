import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: slider
    
    property real value: 0.5
    property real minValue: 0
    property real maxValue: 100
    property string label: "Slider"
    property string unit: ""
    property color backgroundColor: "#F5F5F5"
    property color trackColor: "#E0E0E0"
    property color fillColor: "#2196F3"
    property color thumbColor: "#2196F3"
    property color textColor: "#333333"
    
    width: 200
    height: 60
    
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