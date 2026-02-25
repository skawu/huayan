import QtQuick 2.15

Item {
    id: root
    
    // 可自定义属性
    property color onColor: "#4CAF50"
    property color offColor: "#9E9E9E"
    property color disabledColor: "#BDBDBD"
    property int size: 40
    property int borderWidth: 2
    property color borderColor: "#616161"
    
    // 状态属性
    property bool on: false
    property bool enabled: true
    
    // 设备点位绑定
    property string tagName: ""
    property bool bindToTag: false
    property bool tagValue: false
    
    // 动画属性
    property int animationDuration: 200
    
    // 尺寸
    implicitWidth: size
    implicitHeight: size
    Layout.preferredWidth: size
    Layout.preferredHeight: size
    
    // 指示灯主体
    Rectangle {
        id: light
        anchors.centerIn: parent
        width: root.width * 0.8
        height: root.height * 0.8
        radius: width / 2
        color: root.enabled ? (root.on ? onColor : offColor) : disabledColor
        border.width: borderWidth
        border.color: borderColor
        
        // 发光效果
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: Qt.rgba(1, 1, 1, 0.3)
            visible: root.on && root.enabled
            opacity: 0.7
        }
        
        // 动画
        Behavior on color {
            ColorAnimation {
                duration: animationDuration
            }
        }
    }
    
    // 点位值变化处理
    onTagValueChanged: {
        if (bindToTag) {
            root.on = tagValue
        }
    }
    
    // 状态变化信号
    signal stateChanged(bool newState)
    
    // 状态变化处理
    onOnChanged: {
        root.stateChanged(on)
    }
}
