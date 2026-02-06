import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: textLabel
    width: 200
    height: 40
    color: "transparent"
    border.color: "#666"
    border.width: 1
    radius: 4

    property string labelText: "Label"
    property string valueText: ""
    property string tagName: ""
    property var tagValue: null
    property bool showValue: true
    property int fontSize: 14

    // Update value text based on tag value
    onTagValueChanged: {
        if (tagName !== "") {
            valueText = String(tagValue);
        }
    }

    // Main layout
    Row {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // Label text
        Text {
            text: labelText
            font.pixelSize: fontSize
            font.bold: true
            color: "#333"
            verticalAlignment: Text.AlignVCenter
        }

        // Value text (if enabled)
        Text {
            visible: showValue
            text: valueText
            font.pixelSize: fontSize
            color: "#2196F3"
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            // Add ellipsis if text is too long
            elide: Text.ElideRight
            maximumWidth: parent.width - 80
        }
    }

    // Optional background for better visibility
    property bool showBackground: false
    onShowBackgroundChanged: {
        color = showBackground ? "#F5F5F5" : "transparent";
    }
}
