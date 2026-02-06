import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: indicator
    width: 50
    height: 50
    radius: width / 2
    color: "#333"
    border.width: 2
    border.color: "#666"

    property bool active: false
    property color activeColor: "#4CAF50"
    property color inactiveColor: "#333"
    property string tagName: ""
    property var tagValue: null

    // Internal value that tracks the actual state
    property bool _internalActive: active

    // Update visual state based on active property
    onActiveChanged: {
        _internalActive = active;
        updateVisualState();
    }

    // Update visual state based on tag value
    onTagValueChanged: {
        if (tagName !== "") {
            active = Boolean(tagValue);
        }
    }

    function updateVisualState() {
        color = _internalActive ? activeColor : inactiveColor;
        // Add animation for visual feedback
        scale = 0.9;
        animateScale(1.0);
    }

    function animateScale(targetScale) {
        Qt.createQmlObject('import QtQuick 2.15; NumberAnimation { target: indicator; property: "scale"; to: ' + targetScale + '; duration: 100 }', indicator);
    }

    // Inner glow effect
    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: width / 2
        color: indicator.color
        opacity: 0.7
    }

    // Initialize visual state
    Component.onCompleted: {
        updateVisualState();
    }
}
