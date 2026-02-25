import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    // Compatible API for code expecting a Button type (pure QtQuick fallback)
    property alias text: label.text
    property bool enabled: true
    property bool down: false
    property color normalColor: "#4CAF50"
    property color pressedColor: "#388E3C"
    property color disabledColor: "#9E9E9E"
    property color textColor: "#FFFFFF"
    property int cornerRadius: 4
    property int borderWidth: 1
    property color borderColor: "#2E7D32"

    // 点位绑定兼容属性
    property string tagName: ""
    property bool bindToTag: false
    property bool tagValue: false

    // 长按
    property int longPressDuration: 500
    property bool isLongPress: false

    signal clicked()
    signal longPressed()
    signal tagClicked()

    Rectangle {
        id: bg
        anchors.fill: parent
        color: root.enabled ? (root.down ? root.pressedColor : root.normalColor) : root.disabledColor
        radius: root.cornerRadius
        border.width: root.borderWidth
        border.color: root.borderColor
    }

    Text {
        id: label
        anchors.centerIn: parent
        color: root.textColor
        font.pixelSize: 14
        font.bold: true
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        property int pressTime: 0

        onPressed: {
            root.down = true
            pressTime = Date.now()
            root.isLongPress = false
        }
        onReleased: {
            root.down = false
            if (Date.now() - pressTime >= root.longPressDuration) {
                root.isLongPress = true
                root.longPressed()
            }
            root.clicked()
            if (root.bindToTag && root.tagName !== "") {
                root.tagValue = !root.tagValue
                root.tagClicked()
            }
        }
    }

    // 默认尺寸
    implicitWidth: 100
    implicitHeight: 40
    Layout.preferredWidth: 100
    Layout.preferredHeight: 40
}
