import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: root
    
    // 可自定义属性
    property color normalColor: "#4CAF50"
    property color pressedColor: "#388E3C"
    property color disabledColor: "#9E9E9E"
    property color textColor: "#FFFFFF"
    property int cornerRadius: 4
    property int borderWidth: 1
    property color borderColor: "#2E7D32"
    
    // 设备点位绑定
    property string tagName: ""
    property bool bindToTag: false
    property bool tagValue: false
    
    // 长按属性
    property int longPressDuration: 500
    property bool isLongPress: false
    
    // 样式
    background: Rectangle {
        color: root.enabled ? (root.down ? pressedColor : normalColor) : disabledColor
        radius: cornerRadius
        border.width: borderWidth
        border.color: borderColor
    }
    
    label: Text {
        text: root.text
        color: textColor
        font.pixelSize: 14
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    
    // 长按检测
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        
        property int pressTime: 0
        
        onPressed: {
            pressTime = Date.now()
            isLongPress = false
        }
        
        onReleased: {
            if (Date.now() - pressTime >= longPressDuration) {
                isLongPress = true
                root.longPressed()
            }
        }
    }
    
    // 点位值变化处理
    onTagValueChanged: {
        if (bindToTag) {
            root.checked = tagValue
        }
    }
    
    // 点击处理
    onClicked: {
        if (bindToTag && tagName !== "") {
            // 触发点位值变化
            tagValue = !tagValue
            root.tagClicked()
        }
    }
    
    // 信号
    signal longPressed()
    signal tagClicked()
    
    // 默认尺寸
    width: 100
    height: 40
}
