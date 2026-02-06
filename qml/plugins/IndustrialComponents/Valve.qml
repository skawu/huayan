import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: valve
    width: 100
    height: 100

    property bool open: false
    property string tagName: ""
    property var tagValue: null
    property color openColor: "#4CAF50"
    property color closedColor: "#F44336"

    // Update valve state based on tag value
    onTagValueChanged: {
        if (tagName !== "") {
            open = Boolean(tagValue);
        }
    }

    // Valve body
    Rectangle {
        id: valveBody
        anchors.centerIn: parent
        width: 80
        height: 60
        color: "#757575"
        radius: 8

        // Valve stem
        Rectangle {
            id: valveStem
            anchors.horizontalCenter: parent.horizontalCenter
            width: 8
            height: 40
            color: "#9E9E9E"
            y: 10
        }

        // Valve handle
        Rectangle {
            id: valveHandle
            width: 30
            height: 8
            color: open ? openColor : closedColor
            radius: 4
            anchors.centerIn: valveStem
            rotation: open ? 90 : 0

            // Animate handle rotation
            Behavior on rotation {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    // Valve label
    Text {
        text: open ? "OPEN" : "CLOSED"
        font.pixelSize: 12
        font.bold: true
        color: open ? openColor : closedColor
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        y: -5
    }

    // Click handler
    MouseArea {
        anchors.fill: parent
        onClicked: {
            open = !open;
            if (tagName !== "") {
                valveClicked(open);
            }
        }
    }

    // Signal for valve state change
    signal valveClicked(var value)
}
