import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.15
import QtQuick.Window 2.15
import Qt.labs.folderlistmodel 2.15

Window {
    id: mainWindow
    width: 1920
    height: 1080
    title: "Huayan 可视化组态编辑器"
    visible: true

    Rectangle {
        id: mainBackground
        anchors.fill: parent
        color: "#1E1E1E"
    }

    // 工具栏
    Rectangle {
        id: toolbar
        width: parent.width
        height: 60
        color: "#2D2D2D"
        border.bottom: 1
        border.color: "#3D3D3D"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Button {
                text: "新建"
                onClicked: editorCore.initialize()
            }

            Button {
                text: "保存模板"
                onClicked: {
                    fileDialog.title = "保存模板"
                    fileDialog.selectExisting: false
                    fileDialog.nameFilters = ["JSON 文件 (*.json)"]
                    fileDialog.open()
                }
            }

            Button {
                text: "加载模板"
                onClicked: {
                    fileDialog.title = "加载模板"
                    fileDialog.selectExisting: true
                    fileDialog.nameFilters = ["JSON 文件 (*.json)"]
                    fileDialog.open()
                }
            }

            Label {
                text: "行业模板:"
                color: "white"
                verticalAlignment: Text.AlignVCenter
            }

            ComboBox {
                model: ["钢铁", "化工", "电力"]
                onCurrentIndexChanged: {
                    if (currentIndex === 0) {
                        editorCore.loadIndustryTemplate("steel")
                    } else if (currentIndex === 1) {
                        editorCore.loadIndustryTemplate("chemical")
                    } else if (currentIndex === 2) {
                        editorCore.loadIndustryTemplate("power")
                    }
                }
            }
        }
    }

    // 组件库
    Rectangle {
        id: componentLibrary
        x: 0
        y: toolbar.height
        width: 200
        height: parent.height - toolbar.height
        color: "#252525"
        border.right: 1
        border.color: "#3D3D3D"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Label {
                text: "组件库"
                color: "white"
                font.bold: true
            }

            ComponentDrag {
                text: "仪表盘"
                type: "dashboard"
                icon: "dashboard"
            }

            ComponentDrag {
                text: "趋势图"
                type: "chart"
                icon: "chart"
            }

            ComponentDrag {
                text: "3D视图"
                type: "3dview"
                icon: "3d"
            }

            ComponentDrag {
                text: "按钮"
                type: "button"
                icon: "button"
            }

            ComponentDrag {
                text: "标签"
                type: "label"
                icon: "label"
            }
        }
    }

    // 编辑区域
    Rectangle {
        id: editorArea
        x: componentLibrary.width
        y: toolbar.height
        width: parent.width - componentLibrary.width
        height: parent.height - toolbar.height
        color: "#1E1E1E"

        // 网格背景
        Grid {
            id: grid
            anchors.fill: parent
            rows: Math.ceil(parent.height / 10)
            columns: Math.ceil(parent.width / 10)
            spacing: 0

            Repeater {
                model: grid.rows * grid.columns
                Rectangle {
                    width: 10
                    height: 10
                    color: index % 2 === 0 ? "#1E1E1E" : "#202020"
                }
            }
        }

        // 组件容器
        Item {
            id: componentsContainer
            anchors.fill: parent

            Repeater {
                id: componentsRepeater
                model: editorCore.getAllComponents()

                ComponentItem {
                    id: componentItem
                    componentData: modelData
                    onPositionChanged: {
                        editorCore.updateComponentPosition(componentData.id, Qt.point(x, y))
                    }
                    onPropertyChanged: {
                        editorCore.updateComponentProperty(componentData.id, propertyName, propertyValue)
                    }
                }
            }
        }
    }

    // 属性面板
    Rectangle {
        id: propertyPanel
        x: parent.width - 300
        y: toolbar.height
        width: 300
        height: parent.height - toolbar.height
        color: "#252525"
        border.left: 1
        border.color: "#3D3D3D"
        visible: false

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Label {
                text: "属性编辑"
                color: "white"
                font.bold: true
            }

            Label {
                id: propertyTitle
                text: "选择组件"
                color: "white"
            }

            ColumnLayout {
                id: propertyGrid
                spacing: 5
            }
        }
    }

    // 文件对话框
    FileDialog {
        id: fileDialog
        onAccepted: {
            if (fileDialog.title === "保存模板") {
                editorCore.exportTemplate(fileUrl.toString())
            } else if (fileDialog.title === "加载模板") {
                editorCore.importTemplate(fileUrl.toString())
                componentsRepeater.model = editorCore.getAllComponents()
            }
        }
    }

    // 编辑器核心
    EditorCore {
        id: editorCore
        onComponentCreated: {
            componentsRepeater.model = editorCore.getAllComponents()
        }
        onComponentUpdated: {
            componentsRepeater.model = editorCore.getAllComponents()
        }
        onComponentDeleted: {
            componentsRepeater.model = editorCore.getAllComponents()
        }
        onTemplateLoaded: {
            componentsRepeater.model = editorCore.getAllComponents()
        }
    }

    // 组件拖拽
    Component {
        id: ComponentDrag
        Rectangle {
            property string text: ""
            property string type: ""
            property string icon: ""
            width: 180
            height: 60
            color: "#333"
            border.width: 1
            border.color: "#555"
            radius: 4

            Text {
                anchors.centerIn: parent
                text: text
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                drag {
                    enabled: true
                    type: "Copy"
                }
                onDragStarted: {
                    drag.imageSource = ""
                    drag.setHotSpot(width/2, height/2)
                }
                onDragEnded: {
                    if (drag.target === editorArea) {
                        var position = editorArea.mapFromItem(drag.source, drag.x, drag.y)
                        editorCore.createComponent(type, Qt.point(position.x - width/2, position.y - height/2))
                    }
                }
            }
        }
    }

    // 组件项
    Component {
        id: ComponentItem
        Rectangle {
            property var componentData: {}
            property string propertyName: ""
            property var propertyValue: {}
            signal positionChanged
            signal propertyChanged

            width: componentData.width || 200
            height: componentData.height || 150
            x: componentData.x || 0
            y: componentData.y || 0
            color: "#333"
            border.width: 1
            border.color: "#555"
            radius: 4

            Text {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 5
                text: componentData.type || ""
                color: "white"
                font.bold: true
            }

            Text {
                anchors.centerIn: parent
                text: componentData.properties ? componentData.properties.title || "" : ""
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                drag {
                    enabled: true
                    type: "Automatic"
                }
                onPressed: {
                    propertyPanel.visible = true
                    propertyTitle.text = componentData.type || ""
                    updatePropertyPanel()
                }
                onDragEnded: {
                    positionChanged()
                }
            }

            function updatePropertyPanel() {
                propertyGrid.children = []
                
                if (componentData.properties) {
                    for (var key in componentData.properties) {
                        var value = componentData.properties[key]
                        var row = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Layouts 1.15; RowLayout { spacing: 5 }', propertyGrid)
                        
                        var label = Qt.createQmlObject('import QtQuick 2.15; Label { text: "' + key + ':"; color: "white"; width: 80 }', row)
                        
                        if (typeof value === 'string') {
                            var textField = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; TextField { text: "' + value + '"; onTextChanged: { componentItem.propertyName = "' + key + '"; componentItem.propertyValue = text; componentItem.propertyChanged() } }', row)
                            textField.Layout.fillWidth: true
                        } else if (typeof value === 'number') {
                            var spinBox = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; SpinBox { value: ' + value + '; onValueChanged: { componentItem.propertyName = "' + key + '"; componentItem.propertyValue = value; componentItem.propertyChanged() } }', row)
                            spinBox.Layout.fillWidth: true
                        } else if (typeof value === 'boolean') {
                            var checkBox = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Controls 2.15; CheckBox { checked: ' + value + '; onCheckedChanged: { componentItem.propertyName = "' + key + '"; componentItem.propertyValue = checked; componentItem.propertyChanged() } }', row)
                        }
                    }
                }
            }
        }
    }
}
