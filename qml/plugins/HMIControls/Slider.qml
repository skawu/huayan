import QtQuick 2.15

Item {
    id: root

    // 可自定义属性
    property color trackColor: "#9E9E9E"
    property color progressColor: "#4CAF50"
    property color handleColor: "#FFFFFF"
    property color handleBorderColor: "#4CAF50"
    property int handleSize: 20
    property int trackHeight: 8

    // 范围属性
    property real value: 0
    property real minValue: 0
    property real maxValue: 100
    property real customStepSize: 1

    // 设备点位绑定
    property string tagName: ""
    property bool bindToTag: false
    property real tagValue: 0

    // 交互状态
    property bool pressed: false

    readonly property real visualPosition: (maxValue > minValue) ? ((value - minValue) / (maxValue - minValue)) : 0

    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: trackHeight
        radius: trackHeight / 2
        color: trackColor

        Rectangle {
            id: progress
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            width: Math.max(0, Math.min(parent.width, visualPosition * parent.width))
            radius: parent.radius
            color: progressColor

            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }
    }

    Rectangle {
        id: handle
        width: handleSize
        height: handleSize
        radius: handleSize / 2
        color: handleColor
        border.width: 2
        border.color: handleBorderColor
        anchors.verticalCenter: track.verticalCenter
        x: Math.max(0, Math.min(root.width - width, visualPosition * (root.width - width)))

        Rectangle { anchors.fill: parent; color: Qt.rgba(0,0,0, pressed ? 0.1 : 0); radius: parent.radius }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onPressed: { root.pressed = true; updateValue(mouse.x) }
        onPositionChanged: { if (pressed) updateValue(mouse.x) }
        onReleased: { root.pressed = false }
        function updateValue(x) {
            var pos = Math.max(0, Math.min(root.width, x))
            var v = minValue + (pos / root.width) * (maxValue - minValue)
            if (customStepSize && customStepSize > 0) v = Math.round(v / customStepSize) * customStepSize
            root.value = Math.max(minValue, Math.min(maxValue, v))
        }
    }

    // 点位值变化处理
    onTagValueChanged: {
        if (bindToTag) root.value = tagValue
    }

    // 值变化处理
    onValueChanged: {
        if (bindToTag && tagName !== "") {
            root.tagValue = root.value
            root.valueChanged()
        }
    }

    signal valueChanged()

    width: 200
    height: 40
}
