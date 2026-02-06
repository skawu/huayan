import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: pushButton
    width: 120
    height: 40
    text: "Button"
    font.pixelSize: 14
    font.bold: true

    property string tagName: ""
    property var tagValue: null
    property bool toggleMode: false
    property bool checked: false

    // Update button state based on tag value
    onTagValueChanged: {
        if (tagName !== "") {
            if (toggleMode) {
                checked = Boolean(tagValue);
            }
        }
    }

    // Handle button click
    onClicked: {
        if (toggleMode) {
            checked = !checked;
            // Emit signal for tag value change
            if (tagName !== "") {
                buttonClicked(checked);
            }
        } else {
            // Emit signal for button click
            buttonClicked(true);
        }
    }

    // Style the button
    background: Rectangle {
        color: pushButton.down ? "#2196F3" : pushButton.checked ? "#1976D2" : "#2196F3"
        border.color: "#1976D2"
        border.width: 1
        radius: 4
    }

    contentItem: Text {
        text: pushButton.text
        font: pushButton.font
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    // Signal for button click
    signal buttonClicked(var value)
}
