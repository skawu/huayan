import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: motor
    width: 120
    height: 120

    property bool running: false
    property string tagName: ""
    property var tagValue: null
    property color runningColor: "#4CAF50"
    property color stoppedColor: "#F44336"
    property bool showStatusText: true

    // Update motor state based on tag value
    onTagValueChanged: {
        if (tagName !== "") {
            running = Boolean(tagValue);
        }
    }

    // Motor body
    Rectangle {
        id: motorBody
        anchors.centerIn: parent
        width: 100
        height: 80
        color: "#757575"
        radius: 8
        border.color: "#424242"
        border.width: 2

        // Motor shaft
        Rectangle {
            id: motorShaft
            width: 10
            height: 40
            color: "#9E9E9E"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            x: 5
            radius: 5
        }

        // Motor fan (revolving part)
        Rectangle {
            id: motorFan
            width: 20
            height: 60
            color: "#616161"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            x: -5
            radius: 10

            // Fan blades
            Repeater {
                model: 4
                Rectangle {
                    width: 15
                    height: 3
                    color: "#9E9E9E"
                    anchors.centerIn: motorFan
                    rotation: index * 90
                    transformOrigin: Item.Center
                }
            }

            // Rotate fan when motor is running
            RotationAnimation {
                target: motorFan
                from: 0
                to: 360
                duration: 1000
                running: motor.running
                loops: Animation.Infinite
                easing.type: Easing.Linear
            }
        }

        // Motor status indicator
        Rectangle {
            id: statusIndicator
            width: 12
            height: 12
            radius: 6
            color: running ? runningColor : stoppedColor
            anchors.top: parent.top
            anchors.right: parent.right
            x: -5
            y: 5

            // Add glow effect when running
            Rectangle {
                anchors.fill: statusIndicator
                radius: 6
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

    // Motor status text
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
                motorClicked(running);
            }
        }
    }

    // Signal for motor state change
    signal motorClicked(var value)
}
