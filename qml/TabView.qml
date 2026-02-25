import QtQuick 2.15

Item {
    id: root
    width: parent ? parent.width : 400
    height: parent ? parent.height : 300

    property int currentIndex: 0

    // hidden container to collect Tab children
    Item {
        id: content
        visible: false
    }

    default property alias data: content.data

    Column {
        anchors.fill: parent
        spacing: 0

        Row {
            id: tabBar
            anchors.left: parent.left
            anchors.right: parent.right
            height: 36
            spacing: 6
        }

        Loader {
            id: viewLoader
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: tabBar.bottom
            anchors.bottom: parent.bottom
            sourceComponent: content.children.length > 0 ? content.children[root.currentIndex] : null
        }
    }

    Component.onCompleted: {
        // build simple tab buttons using pure QtQuick (avoid Controls dependency)
        for (var i = 0; i < content.children.length; ++i) {
            (function(idx){
                var child = content.children[idx]
                var title = child.title !== undefined ? child.title : ("Tab " + idx)
                var qml = 'import QtQuick 2.15; Item { width: 100; height: 36; Rectangle { anchors.fill: parent; color: "transparent"; border.width: 1; border.color: "#CCCCCC" } Text { anchors.centerIn: parent; text: "' + title.replace(/"/g, '\\"') + '"; font.pixelSize: 14 } MouseArea { anchors.fill: parent; onClicked: { parent.parent.parent._setIndex(' + idx + ') } } }'
                var btn = Qt.createQmlObject(qml, tabBar)
                // expose a small helper to switch index
                if (!tabBar._setIndex) tabBar._setIndex = function(i){ root.currentIndex = i; viewLoader.sourceComponent = content.children[root.currentIndex] }
            })(i)
        }
    }
}
