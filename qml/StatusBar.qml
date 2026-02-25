import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: parent ? parent.width : 400
    height: implicitHeight
    color: "#F5F5F5"
    implicitHeight: 36
    border.color: "#D0D0D0"

    RowLayout {
        id: contentHolder
        anchors.fill: parent
        anchors.margins: 6
        spacing: 12
    }

    // 允许在 QML 中直接在 StatusBar 内放置子项
    default property alias data: contentHolder.data
}
