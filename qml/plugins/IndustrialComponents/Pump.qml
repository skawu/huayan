import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: pump
    width: 120
    height: 120

    property bool running: false
    property string tagName: ""
    property var tagValue: null
    property color runningColor: "#4CAF50"
    property color stoppedColor: "#F44336"
    property bool showStatusText: true

    // Update pump state based on tag value
    onTagValueChanged: {
        if (tagName !== "") {
            running = Boolean(tagValue);
        }
    }

    // Pump body
    Rectangle {
        id: pumpBody
        anchors.centerIn: parent
        width: 80
        height: 60
        color: "#757575"
        radius: 8
        border.color: "#424242"
        border.width: 2

        // Pump inlet
        Rectangle {
            id: pumpInlet
            width: 15
            height: 30
            color: "#9E9E9E"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            x: -7
            radius: 7
        }

        // Pump outlet
        Rectangle {
            id: pumpOutlet
            width: 15
            height: 30
            color: "#9E9E9E"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            x: 7
            radius: 7
        }

        // Pump impeller (rotating part)
        Rectangle {
            id: pumpImpeller
            width: 40
            height: 40
            color: "#616161"
            anchors.centerIn: parent
            radius: 20

            // Impeller blades
            Repeater {
                model: 4
                Rectangle {
                    width: 3
                    height: 20
                    color: "#9E9E9E"
                    anchors.centerIn: pumpImpeller
                    rotation: index * 90
                    transformOrigin: Item.Center
                }
            }

            // Rotate impeller when pump is running
            RotationAnimation {
                target: pumpImpeller
                from: 0
                to: 360
                duration: 800
                running: pump.running
                loops: Animation.Infinite
                easing.type: Easing.Linear
            }
        }

        // Pump status indicator
        Rectangle {
            id: statusIndicator
            width: 10
            height: 10
            radius: 5
            color: running ? runningColor : stoppedColor
            anchors.top: parent.top
            anchors.right: parent.right
            x: -5
            y: 5

            // Add glow effect when running
            Rectangle {
                anchors.fill: statusIndicator
                radius: 5
                color: running ? runningColor : "transparent"
                opacity: running ? 0.5 : 0
                scale: running ? 1.5 : 1

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 300
                    }
                }
            }
        }
    }

    // Pump status text
    Text {
        visible: showStatusText
        text: running ? "RUNNING" : "STOPPED"
        font.pixelSize: 12
        font.bold: true
        color: running ? runningColor : stoppedColor
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        y: -5
    }

    // Click handler
    MouseArea {
        anchors.fill: parent
        onClicked: {
            running = !running;
            if (tagName !== "") {
                pumpClicked(running);
            }
        }
    }

    // Signal for pump state change
    signal pumpClicked(var value)
}
