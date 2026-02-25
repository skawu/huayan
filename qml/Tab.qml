import QtQuick 2.15

Item {
    id: tab
    property alias title: tabTitle.text
    default property alias content: container.data

    Column {
        id: container
    }

    Text {
        id: tabTitle
        visible: false
        text: ""
    }
}
