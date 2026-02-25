import QtQuick 2.15

Button {
    id: industrialButton
    
    property bool isPressed: false
    property bool isEnabled: true
    property bool isAlarm: false
    property string label: "Button"
    property color normalColor: "#4CAF50"
    property color pressedColor: "#45a049"
    property color disabledColor: "#BDBDBD"
    property color alarmColor: "#F44336"
    property int cornerRadius: 4
    
    width: 120
    height: 60
    
    background: Rectangle {
        id: buttonBackground
        anchors.fill: parent
        color: {
            if (!isEnabled) {
                return disabledColor;
            } else if (isAlarm) {
                return alarmColor;
            } else if (isPressed) {
                return pressedColor;
            } else {
                return normalColor;
            }
        }
        border.color: Qt.darker(buttonBackground.color, 1.2)
        border.width: 2
        radius: cornerRadius
        
        // 按钮效果
        Rectangle {
            id: buttonEffect
            anchors.fill: parent
            color: "white"
            opacity: isPressed ? 0.1 : 0.2
            radius: cornerRadius
        }
        
        // 按钮边框高光
        Rectangle {
            id: buttonHighlight
            anchors { top: parent.top; left: parent.left; right: parent.right; }
            height: parent.height * 0.3
            color: "white"
            opacity: 0.3
            radius: cornerRadius
        }
    }
    
    contentItem: Text {
        id: buttonText
        text: label
        font.pixelSize: 16
        font.bold: true
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        
        // 文字阴影效果
        style: Text.Sunken
        styleColor: Qt.rgba(0, 0, 0, 0.3)
    }
    
    // 鼠标区域
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (isEnabled) {
                isPressed = !isPressed;
                industrialButton.clicked();
            }
        }
        onPressed: {
            if (isEnabled) {
                isPressed = true;
            }
        }
        onReleased: {
            if (isEnabled) {
                isPressed = false;
            }
        }
    }
    
    // 禁用效果
    states: [
        State {
            name: "disabled"
            when: !isEnabled
            PropertyChanges {
                target: buttonText
                opacity: 0.7
            }
        }
    ]
    
    // 动画效果
    transitions: [
        Transition {
            from: "*"
            to: "disabled"
            NumberAnimation {
                target: buttonText
                property: "opacity"
                duration: 200
            }
        }
    ]
}
