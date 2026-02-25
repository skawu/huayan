import QtQuick 2.15

Item {
    id: root
    property color color: "#ffffff"
    signal accepted()
    signal rejected()

    function open() {
        // simple fallback: immediately accept with current color
        accepted()
    }
}
