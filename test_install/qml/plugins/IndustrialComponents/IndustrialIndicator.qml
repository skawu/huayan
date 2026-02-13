import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: industrialIndicator
    
    property bool value: false
    property string label: "Indicator"
    property color onColor: "#4CAF50"
    property color offColor: "#F44336"
    property bool blinking: false
    property int blinkInterval: 500
    property string shape: "circle"
    property real size: 60
    
    width: size
    height: size
    
    // 指示灯主体
    Rectangle {
        id: indicatorBody
        anchors.centerIn: parent
        width: industrialIndicator.width * 0.8
        height: industrialIndicator.height * 0.8
        radius: shape === "circle" ? width / 2 : 8
        color: value ? onColor : offColor
        border.color: Qt.darker(indicatorBody.color, 1.2)
        border.width: 2
        
        // 指示灯效果
        Rectangle {
            id: indicatorEffect
            anchors.fill: parent
            color: "white"
            opacity: 0.3
            radius: indicatorBody.radius
        }
        
        // 指示灯高光
        Rectangle {
            id: indicatorHighlight
            anchors { top: parent.top; left: parent.left; right: parent.right; }
            height: parent.height * 0.4
            color: "white"
            opacity: 0.5
            radius: indicatorBody.radius
        }
        
        // 指示灯阴影
        Rectangle {
            id: indicatorShadow
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right; }
            height: parent.height * 0.3
            color: "black"
            opacity: 0.1
            radius: indicatorBody.radius
        }
    }
    
    // 标签
    Text {
        id: indicatorLabel
        text: label
        font.pixelSize: 12
        font.bold: true
        color: "#333333"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; }
        anchors.bottomMargin: 5
    }
    
    // 闪烁动画
    NumberAnimation {
        id: blinkAnimation
        target: indicatorBody
        property: "opacity"
        from: 1
        to: 0.3
        duration: blinkInterval
        loops: Animation.Infinite
        running: blinking && value
    }
    
    // 状态变化处理
    onValueChanged: {
        if (value && blinking) {
            blinkAnimation.start();
        } else {
            blinkAnimation.stop();
            indicatorBody.opacity = 1;
        }
    }
    
    onBlinkingChanged: {
        if (value && blinking) {
            blinkAnimation.start();
        } else {
            blinkAnimation.stop();
            indicatorBody.opacity = 1;
        }
    }
    
    // 点击切换状态
    MouseArea {
        anchors.fill: parent
        onClicked: {
            value = !value;
        }
    }
}
