import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: tank
    width: 120
    height: 180

    property real level: 0.5 // 0.0 to 1.0
    property string tagName: ""
    property var tagValue: null
    property color fillColor: "#2196F3"
    property color emptyColor: "#E0E0E0"
    property bool showLevelText: true
    property string unit: "%"

    // Update tank level based on tag value
    onTagValueChanged: {
        if (tagName !== "") {
            // Assuming tag value is 0-100 for percentage
            level = Math.max(0, Math.min(1, Number(tagValue) / 100));
        }
    }

    // Tank outline
    Rectangle {
        id: tankOutline
        anchors.fill: parent
        color: "#757575"
        radius: 8
        border.color: "#424242"
        border.width: 2

        // Tank bottom
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.8
            height: 10
            color: "#757575"
            border.color: "#424242"
            border.width: 2
            y: 5
        }

        // Tank top
        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.6
            height: 10
            color: "#757575"
            border.color: "#424242"
            border.width: 2
            y: -5
        }

        // Fill level
        Rectangle {
            id: tankFill
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height * level
            color: fillColor
            border.color: "#1976D2"
            border.width: 1
            // Add gradient for better visual effect
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: fillColor
                }
                GradientStop {
                    position: 1.0
                    color: Qt.darker(fillColor, 1.2)
                }
            }

            // Animate level changes
            Behavior on height {
                NumberAnimation {
                    duration: 1000
                    easing.type: Easing.InOutQuad
                }
            }
        }

        // Empty space
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: tankFill.top
            anchors.left: parent.left
            anchors.right: parent.right
            color: emptyColor
            opacity: 0.5
        }
    }

    // Level text
    Text {
        visible: showLevelText
        text: Math.round(level * 100) + unit
        font.pixelSize: 14
        font.bold: true
        color: "#333"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        y: 10
    }

    // Tag name label
    Text {
        visible: tagName !== ""
        text: tagName
        font.pixelSize: 10
        color: "#666"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        y: -5
    }
}
