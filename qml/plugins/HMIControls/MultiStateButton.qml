import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    
    // 可自定义属性
    property color backgroundColor: "#212121"
    property color borderColor: "#616161"
    property color textColor: "#FFFFFF"
    property color hoverColor: "#37474F"
    property color pressedColor: "#455A64"
    property int borderWidth: 1
    property int cornerRadius: 4
    
    // 状态属性
    property var states: ["状态1", "状态2", "状态3"]
    property int currentStateIndex: 0
    property bool enabled: true
    
    // 设备点位绑定
    property string tagName: ""
    property bool bindToTag: false
    property int tagValue: 0
    
    // 动画属性
    property int animationDuration: 200
    
    // 背景
    Rectangle {
        id: background
        anchors.fill: parent
        radius: cornerRadius
        color: root.enabled ? (mouseArea.containsMouse ? hoverColor : backgroundColor) : "#BDBDBD"
        border.width: borderWidth
        border.color: borderColor
        
        Behavior on color {
            ColorAnimation {
                duration: animationDuration
            }
        }
    }
    
    // 文本显示
    Text {
        id: stateText
        text: states.length > 0 ? states[currentStateIndex] : ""
        color: textColor
        font.pixelSize: root.height * 0.4
        font.bold: true
        anchors.centerIn: parent
    }
    
    // 点击处理
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled
        
        onClicked: {
            // 切换到下一个状态
            currentStateIndex = (currentStateIndex + 1) % states.length
            
            // 更新点位值
            if (bindToTag && tagName !== "") {
                tagValue = currentStateIndex
            }
            
            // 触发状态变化信号
            root.stateChanged(currentStateIndex, states[currentStateIndex])
        }
        
        onPressAndHold: {
            // 长按触发
            root.longPressed()
        }
    }
    
    // 点位值变化处理
    onTagValueChanged: {
        if (bindToTag && tagValue >= 0 && tagValue < states.length) {
            currentStateIndex = tagValue
        }
    }
    
    // 信号
    signal stateChanged(int index, string state)
    signal longPressed()
    
    // 默认尺寸
    width: 120
    height: 40
}
