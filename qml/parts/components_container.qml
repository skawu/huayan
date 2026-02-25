import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    // 将原 main.qml 中的 Component 提取为属性，供主入口通过 Loader 获取并赋值
    property Component componentItem: Component {
        Item {
            id: root
            property string name: ""
            property string type: ""

            implicitWidth: 80
            Layout.preferredWidth: 80
            height: 100

            Rectangle {
                id: preview
                anchors.left: root.left
                anchors.right: root.right
                anchors.margins: 5
                height: root.width - 10
                anchors.centerIn: parent
                anchors.topMargin: 5
                color: "#F0F0F0"
                border.color: "#CCCCCC"
                border.width: 1

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 5
                    color: "#F0F0F0"
                    border.color: "#CCCCCC"
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "Component Preview"
                        font.pixelSize: 10
                        color: "#666666"
                    }
                }
            }

            Text {
                text: name
                anchors.top: preview.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 5
                font.pixelSize: 12
            }

            MouseArea {
                anchors.fill: parent
                drag.target: root
                drag.axis: Drag.XAndY
            }
        }
    }

    property Component canvasComponent: Component {
        Item {
            id: root
            property string name: ""
            property string color: "#FFFFFF"
            property string borderColor: "#CCCCCC"
            property int borderWidth: 1
            property real rotation: 0
            property bool selected: false

            implicitWidth: 100
            Layout.preferredWidth: 100
            height: 100

            Rectangle {
                id: content
                anchors.fill: parent
                color: root.color
                border.color: root.borderColor
                border.width: root.borderWidth
                rotation: root.rotation
            }

            Rectangle {
                id: selectionBorder
                anchors.fill: parent
                border.color: "#2196F3"
                border.width: 2
                color: "transparent"
                visible: root.selected
            }

            Item {
                id: resizeHandles
                anchors.fill: parent
                visible: root.selected

                Loader {
                    sourceComponent: resizeHandle
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    onLoaded: {
                        item.target = root
                        item.position = "bottomRight"
                    }
                }
                Loader {
                    sourceComponent: resizeHandle
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    onLoaded: {
                        item.target = root
                        item.position = "bottomLeft"
                    }
                }
                Loader {
                    sourceComponent: resizeHandle
                    anchors.top: parent.top
                    anchors.right: parent.right
                    onLoaded: {
                        item.target = root
                        item.position = "topRight"
                    }
                }
                Loader {
                    sourceComponent: resizeHandle
                    anchors.top: parent.top
                    anchors.left: parent.left
                    onLoaded: {
                        item.target = root
                        item.position = "topLeft"
                    }
                }
                Loader {
                    sourceComponent: resizeHandle
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    onLoaded: {
                        item.target = root
                        item.position = "left"
                    }
                }
                Loader {
                    sourceComponent: resizeHandle
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onLoaded: {
                        item.target = root
                        item.position = "right"
                    }
                }
                Loader {
                    sourceComponent: resizeHandle
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    onLoaded: {
                        item.target = root
                        item.position = "top"
                    }
                }
                Loader {
                    sourceComponent: resizeHandle
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    onLoaded: {
                        item.target = root
                        item.position = "bottom"
                    }
                }
            }

            Rectangle {
                id: rotationHandle
                implicitWidth: 12
                Layout.preferredWidth: 12
                height: 12
                color: "#FF9800"
                border.color: "#F57C00"
                border.width: 1
                visible: root.selected
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: -20

                MouseArea {
                    anchors.fill: parent
                    drag.target: root
                    drag.axis: Drag.XAndY
                }
            }

            MouseArea {
                anchors.fill: parent
                drag.target: root
                drag.axis: Drag.XAndY

                onPressed: {
                    root.selected = true
                    updatePropertyPanel(root)
                }
            }
        }
    }

    property Component resizeHandle: Component {
        Item {
            property var target: null
            property string position: ""

            implicitWidth: 8
            Layout.preferredWidth: 8
            height: 8

            Rectangle {
                anchors.fill: parent
                color: "#2196F3"
                border.color: "#1976D2"
                border.width: 1
            }

            MouseArea {
                anchors.fill: parent
                drag.target: target
                drag.axis: Drag.XAndY

                onMouseXChanged: {
                    if (pressed && target) {
                        switch (position) {
                            case "bottomRight":
                                target.width = Math.max(20, mouseX)
                                target.height = Math.max(20, mouseY)
                                break
                            case "bottomLeft":
                                target.width = Math.max(20, target.width + (target.x - mouseX))
                                target.x = Math.max(0, mouseX)
                                target.height = Math.max(20, mouseY)
                                break
                            case "topRight":
                                target.width = Math.max(20, mouseX)
                                target.height = Math.max(20, target.height + (target.y - mouseY))
                                target.y = Math.max(0, mouseY)
                                break
                            case "topLeft":
                                target.width = Math.max(20, target.width + (target.x - mouseX))
                                target.x = Math.max(0, mouseX)
                                target.height = Math.max(20, target.height + (target.y - mouseY))
                                target.y = Math.max(0, mouseY)
                                break
                            case "left":
                                target.width = Math.max(20, target.width + (target.x - mouseX))
                                target.x = Math.max(0, mouseX)
                                break
                            case "right":
                                target.width = Math.max(20, mouseX)
                                break
                            case "top":
                                target.height = Math.max(20, target.height + (target.y - mouseY))
                                target.y = Math.max(0, mouseY)
                                break
                            case "bottom":
                                target.height = Math.max(20, mouseY)
                                break
                        }
                    }
                }
            }
        }
    }
}
