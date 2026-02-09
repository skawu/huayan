import QtQuick 2.15
import QtQuick.Controls 2.15

Slider {
    id: root
    
    // 可自定义属性
    property color trackColor: "#9E9E9E"
    property color progressColor: "#4CAF50"
    property color handleColor: "#FFFFFF"
    property color handleBorderColor: "#4CAF50"
    property int handleSize: 20
    property int trackHeight: 8
    
    // 范围属性
    property real minValue: 0
    property real maxValue: 100
    property real customStepSize: 1
    
    // 设备点位绑定
    property string tagName: ""
    property bool bindToTag: false
    property real tagValue: 0
    
    // 触摸交互
    property bool touchEnabled: true
    
    // 样式
    from: minValue
    to: maxValue
    stepSize: root.customStepSize
    
    // 轨道样式
    track: Rectangle {
        x: root.left
        y: root.top + root.height / 2 - trackHeight / 2
        implicitWidth: root.width
        implicitHeight: trackHeight
        radius: trackHeight / 2
        color: trackColor
        
        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: progressColor
        }
    }
    
    // 手柄样式
    handle: Rectangle {
        x: root.left + root.visualPosition * (root.width - width)
        y: root.top + root.height / 2 - handleSize / 2
        implicitWidth: handleSize
        implicitHeight: handleSize
        radius: handleSize / 2
        color: handleColor
        border.width: 2
        border.color: handleBorderColor
        
        // 按下效果
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Qt.rgba(0, 0, 0, 0.1)
            visible: root.pressed
        }
    }
    
    // 点位值变化处理
    onTagValueChanged: {
        if (bindToTag) {
            root.value = tagValue
        }
    }
    
    // 值变化处理
    onValueChanged: {
        if (bindToTag && tagName !== "") {
            root.tagValue = root.value
            root.valueChanged()
        }
    }
    
    // 信号
    signal valueChanged()
    
    // 默认尺寸
    width: 200
    height: 40
}
