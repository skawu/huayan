import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    
    // 可自定义属性
    property color onColor: "#4CAF50"
    property color offColor: "#9E9E9E"
    property color handleColor: "#FFFFFF"
    property color handleBorderColor: "#BDBDBD"
    property int width: 80
    property int height: 40
    property int handleSize: 32
    
    // 状态属性
    property bool checked: false
    property bool enabled: true
    
    // 设备点位绑定
    property string tagName: ""
    property bool bindToTag: false
    property bool tagValue: false
    
    // 动画属性
    property int animationDuration: 200
    
    // 背景
    Rectangle {
        id: background
        anchors.fill: parent
        radius: height / 2
        color: root.enabled ? (root.checked ? onColor : offColor) : "#BDBDBD"
        
        Behavior on color {
            ColorAnimation {
                duration: animationDuration
            }
        }
    }
    
    // 手柄
    Rectangle {
        id: handle
        width: handleSize
        height: handleSize
        radius: height / 2
        color: handleColor
        border.width: 1
        border.color: handleBorderColor
        
        // 位置动画
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? (root.width - width - 4) : 4
        
        Behavior on x {
            NumberAnimation {
                duration: animationDuration
                easing.type: Easing.OutCubic
            }
        }
        
        // 阴影效果
        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Qt.rgba(0, 0, 0, 0.1)
        }
    }
    
    // 点击处理
    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        
        onClicked: {
            root.checked = !root.checked
            if (bindToTag && tagName !== "") {
                tagValue = root.checked
            }
            root.toggled(root.checked)
        }
    }
    
    // 点位值变化处理
    onTagValueChanged: {
        if (bindToTag) {
            root.checked = tagValue
        }
    }
    
    // 状态变化信号
    signal toggled(bool checked)
    
    // 状态变化处理
    onCheckedChanged: {
        root.toggled(checked)
    }
}
