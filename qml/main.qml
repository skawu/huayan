import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import BasicComponents 1.0
import IndustrialComponents 1.0
import ChartComponents 1.0
import ControlComponents 1.0

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 800
    title: ""
    color: "#1E1E1E"

    // Core modules
    property var tagManager: null
    property var modbusDriver: null
    property var dataProcessor: null
    property var currentTime: ""

    // Drag and drop helper
    DragAndDropHelper {
        id: dragDropHelper
    }

    // System time update
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var date = new Date();
            mainWindow.currentTime = date.toLocaleString();
        }
    }

    // Title bar
    Rectangle {
        id: titleBar
        width: parent.width
        height: 60
        color: "#2C2C2C"
        border.bottom: Rectangle {
            width: parent.width
            height: 2
            color: "#3498DB"
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 20

            // Logo and title
            RowLayout {
                spacing: 10

                Rectangle {
                    width: 40
                    height: 40
                    color: "#3498DB"
                    radius: 4

                    Text {
                        anchors.centerIn: parent
                        text: "S"
                        font.bold: true
                        font.pointSize: 20
                        color: "white"
                    }
                }

                Text {
                    text: "Industrial SCADA System"
                    font.bold: true
                    font.pointSize: 16
                    color: "white"
                }
            }

            // System status indicators
            RowLayout {
                spacing: 15
                Layout.alignment: Qt.AlignCenter

                RowLayout {
                    spacing: 5

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: modbusDriver && modbusDriver.isConnected() ? "#27AE60" : "#E74C3C"
                    }

                    Text {
                        text: modbusDriver ? (modbusDriver.isConnected() ? "Connected" : "Disconnected") : "Initializing"
                        font.pointSize: 12
                        color: "white"
                    }
                }

                RowLayout {
                    spacing: 5

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: dataProcessor ? "#27AE60" : "#E74C3C"
                    }

                    Text {
                        text: dataProcessor ? "Active" : "Inactive"
                        font.pointSize: 12
                        color: "white"
                    }
                }

                RowLayout {
                    spacing: 5

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: "#F39C12"
                    }

                    Text {
                        text: tagManager ? tagManager.getAllTags().length + " Tags" : "0 Tags"
                        font.pointSize: 12
                        color: "white"
                    }
                }
            }

            // System time
            Text {
                text: mainWindow.currentTime
                font.pointSize: 12
                color: "white"
                Layout.alignment: Qt.AlignRight
            }
        }
    }

    // Main content area
    Rectangle {
        anchors.top: titleBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        color: "#1E1E1E"

        // Tab view for main interface
        TabView {
            id: mainTabView
            anchors.fill: parent
            tabPosition: TabView.TabPosition.Top
            background: Rectangle { color: "#2C2C2C" }
            tabBar: TabBar {
                id: mainTabBar
                background: Rectangle { color: "#2C2C2C" }
                width: parent.width

                TabButton {
                    text: "Dashboard"
                    font.pointSize: 12
                    font.bold: true
                    color: mainTabView.currentIndex === 0 ? "#3498DB" : "#BDC3C7"
                    background: Rectangle {
                        color: mainTabView.currentIndex === 0 ? "#2C2C2C" : "transparent"
                        border.bottom: Rectangle {
                            width: parent.width
                            height: 2
                            color: mainTabView.currentIndex === 0 ? "#3498DB" : "transparent"
                        }
                    }
                }

                TabButton {
                    text: "Configuration Editor"
                    font.pointSize: 12
                    font.bold: true
                    color: mainTabView.currentIndex === 1 ? "#3498DB" : "#BDC3C7"
                    background: Rectangle {
                        color: mainTabView.currentIndex === 1 ? "#2C2C2C" : "transparent"
                        border.bottom: Rectangle {
                            width: parent.width
                            height: 2
                            color: mainTabView.currentIndex === 1 ? "#3498DB" : "transparent"
                        }
                    }
                }

                TabButton {
                    text: "Tag Management"
                    font.pointSize: 12
                    font.bold: true
                    color: mainTabView.currentIndex === 2 ? "#3498DB" : "#BDC3C7"
                    background: Rectangle {
                        color: mainTabView.currentIndex === 2 ? "#2C2C2C" : "transparent"
                        border.bottom: Rectangle {
                            width: parent.width
                            height: 2
                            color: mainTabView.currentIndex === 2 ? "#3498DB" : "transparent"
                        }
                    }
                }

                TabButton {
                    text: "Component Management"
                    font.pointSize: 12
                    font.bold: true
                    color: mainTabView.currentIndex === 3 ? "#3498DB" : "#BDC3C7"
                    background: Rectangle {
                        color: mainTabView.currentIndex === 3 ? "#2C2C2C" : "transparent"
                        border.bottom: Rectangle {
                            width: parent.width
                            height: 2
                            color: mainTabView.currentIndex === 3 ? "#3498DB" : "transparent"
                        }
                    }
                }

                TabButton {
                    text: "Alarm & Event Management"
                    font.pointSize: 12
                    font.bold: true
                    color: mainTabView.currentIndex === 4 ? "#3498DB" : "#BDC3C7"
                    background: Rectangle {
                        color: mainTabView.currentIndex === 4 ? "#2C2C2C" : "transparent"
                        border.bottom: Rectangle {
                            width: parent.width
                            height: 2
                            color: mainTabView.currentIndex === 4 ? "#3498DB" : "transparent"
                        }
                    }
                }
            }

            // Dashboard tab
            Tab {
                Rectangle {
                    anchors.fill: parent
                    color: "#1E1E1E"

                    GridLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        columns: 3
                        rowSpacing: 15
                        columnSpacing: 15

                        // System status card
                        Rectangle {
                            id: statusCard
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#2C2C2C"
                            radius: 4
                            border.color: "#34495E"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                Text {
                                    text: "System Status"
                                    font.bold: true
                                    font.pointSize: 14
                                    color: "#3498DB"
                                }

                                ColumnLayout {
                                    spacing: 10

                                    RowLayout {
                                        spacing: 10
                                        Layout.fillWidth: true

                                        Text {
                                            text: "Modbus TCP:"
                                            color: "#BDC3C7"
                                            Layout.preferredWidth: 120
                                        }

                                        Text {
                                            text: modbusDriver ? (modbusDriver.isConnected() ? "Connected" : "Disconnected") : "Not Initialized"
                                            font.bold: true
                                            color: modbusDriver && modbusDriver.isConnected() ? "#27AE60" : "#E74C3C"
                                            Layout.fillWidth: true
                                        }
                                    }

                                    RowLayout {
                                        spacing: 10
                                        Layout.fillWidth: true

                                        Text {
                                            text: "Data Collection:"
                                            color: "#BDC3C7"
                                            Layout.preferredWidth: 120
                                        }

                                        Text {
                                            text: dataProcessor ? "Active" : "Inactive"
                                            font.bold: true
                                            color: dataProcessor ? "#27AE60" : "#E74C3C"
                                            Layout.fillWidth: true
                                        }
                                    }

                                    RowLayout {
                                        spacing: 10
                                        Layout.fillWidth: true

                                        Text {
                                            text: "Tags Count:"
                                            color: "#BDC3C7"
                                            Layout.preferredWidth: 120
                                        }

                                        Text {
                                            text: tagManager ? tagManager.getAllTags().length : 0
                                            font.bold: true
                                            color: "#3498DB"
                                            Layout.fillWidth: true
                                        }
                                    }

                                    RowLayout {
                                        spacing: 10
                                        Layout.fillWidth: true

                                        Text {
                                            text: "System Time:"
                                            color: "#BDC3C7"
                                            Layout.preferredWidth: 120
                                        }

                                        Text {
                                            text: mainWindow.currentTime
                                            font.bold: true
                                            color: "#3498DB"
                                            Layout.fillWidth: true
                                        }
                                    }
                                }
                            }
                        }

                        // Process overview card
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#2C2C2C"
                            radius: 4
                            border.color: "#34495E"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                Text {
                                    text: "Process Overview"
                                    font.bold: true
                                    font.pointSize: 14
                                    color: "#3498DB"
                                }

                                GridLayout {
                                    columns: 2
                                    rowSpacing: 10
                                    columnSpacing: 10
                                    Layout.fillWidth: true

                                    // Tank level
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "#34495E"
                                        radius: 4

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 5

                                            Text {
                                                text: "Tank Level"
                                                font.bold: true
                                                color: "#BDC3C7"
                                            }

                                            Tank {
                                                width: 80
                                                height: 120
                                                level: 0.7
                                                Layout.alignment: Qt.AlignCenter
                                            }

                                            Text {
                                                text: "70%"
                                                font.bold: true
                                                color: "#27AE60"
                                                Layout.alignment: Qt.AlignCenter
                                            }
                                        }
                                    }

                                    // Pump status
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "#34495E"
                                        radius: 4

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 5

                                            Text {
                                                text: "Pump Status"
                                                font.bold: true
                                                color: "#BDC3C7"
                                            }

                                            Pump {
                                                width: 80
                                                height: 80
                                                running: true
                                                Layout.alignment: Qt.AlignCenter
                                            }

                                            Text {
                                                text: "Running"
                                                font.bold: true
                                                color: "#27AE60"
                                                Layout.alignment: Qt.AlignCenter
                                            }
                                        }
                                    }

                                    // Valve status
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "#34495E"
                                        radius: 4

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 5

                                            Text {
                                                text: "Valve Status"
                                                font.bold: true
                                                color: "#BDC3C7"
                                            }

                                            Valve {
                                                width: 80
                                                height: 80
                                                open: true
                                                Layout.alignment: Qt.AlignCenter
                                            }

                                            Text {
                                                text: "Open"
                                                font.bold: true
                                                color: "#27AE60"
                                                Layout.alignment: Qt.AlignCenter
                                            }
                                        }
                                    }

                                    // Motor status
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "#34495E"
                                        radius: 4

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 5

                                            Text {
                                                text: "Motor Status"
                                                font.bold: true
                                                color: "#BDC3C7"
                                            }

                                            Motor {
                                                width: 80
                                                height: 80
                                                running: true
                                                Layout.alignment: Qt.AlignCenter
                                            }

                                            Text {
                                                text: "Running"
                                                font.bold: true
                                                color: "#27AE60"
                                                Layout.alignment: Qt.AlignCenter
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // System trends card
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#2C2C2C"
                            radius: 4
                            border.color: "#34495E"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                Text {
                                    text: "System Trends"
                                    font.bold: true
                                    font.pointSize: 14
                                    color: "#3498DB"
                                }

                                TrendChart {
                                    width: parent.width
                                    height: parent.height - 40
                                    title: "Process Values"
                                    // Bind to a tag if available
                                    tagName: tagManager && tagManager.getAllTags().length > 0 ? tagManager.getAllTags()[0].name : ""
                                }
                            }
                        }
                    }
                }
            }

            // Configuration Editor tab
            Tab {
                Rectangle {
                    anchors.fill: parent
                    color: "#1E1E1E"

                    SplitView {
                        anchors.fill: parent
                        orientation: Qt.Horizontal
                        handleDelegate: Rectangle {
                            width: 2
                            color: "#34495E"
                        }

                        // Component library
                        Rectangle {
                            id: componentLibrary
                            width: 220
                            color: "#2C2C2C"
                            border.right: Rectangle {
                                width: 1
                                height: parent.height
                                color: "#34495E"
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                Text {
                                    text: "Component Library"
                                    font.bold: true
                                    font.pointSize: 14
                                    color: "#3498DB"
                                }

                                // Basic components section
                                ColumnLayout {
                                    spacing: 8

                                    Text {
                                        text: "Basic Components"
                                        font.bold: true
                                        color: "#BDC3C7"
                                    }

                                    ColumnLayout {
                                        spacing: 5

                                        Button {
                                            text: "Indicator"
                                            width: parent.width
                                            height: 35
                                            color: "#34495E"
                                            textColor: "white"
                                            onClicked: {
                                                dragDropHelper.startDragFromLibrary("BasicComponents.Indicator", mouse.x + componentLibrary.x, mouse.y + componentLibrary.y);
                                            }
                                        }

                                        Button {
                                            text: "PushButton"
                                            width: parent.width
                                            height: 35
                                            color: "#34495E"
                                            textColor: "white"
                                            onClicked: {
                                                dragDropHelper.startDragFromLibrary("BasicComponents.PushButton", mouse.x + componentLibrary.x, mouse.y + componentLibrary.y);
                                            }
                                        }

                                        Button {
                                            text: "TextLabel"
                                            width: parent.width
                                            height: 35
                                            color: "#34495E"
                                            textColor: "white"
                                            onClicked: {
                                                dragDropHelper.startDragFromLibrary("BasicComponents.TextLabel", mouse.x + componentLibrary.x, mouse.y + componentLibrary.y);
                                            }
                                        }
                                    }
                                }

                                // Industrial components section
                                ColumnLayout {
                                    spacing: 8

                                    Text {
                                        text: "Industrial Components"
                                        font.bold: true
                                        color: "#BDC3C7"
                                    }

                                    ColumnLayout {
                                        spacing: 5

                                        Button {
                                            text: "Valve"
                                            width: parent.width
                                            height: 35
                                            color: "#34495E"
                                            textColor: "white"
                                            onClicked: {
                                                dragDropHelper.startDragFromLibrary("IndustrialComponents.Valve", mouse.x + componentLibrary.x, mouse.y + componentLibrary.y);
                                            }
                                        }

                                        Button {
                                            text: "Tank"
                                            width: parent.width
                                            height: 35
                                            color: "#34495E"
                                            textColor: "white"
                                            onClicked: {
                                                dragDropHelper.startDragFromLibrary("IndustrialComponents.Tank", mouse.x + componentLibrary.x, mouse.y + componentLibrary.y);
                                            }
                                        }

                                        Button {
                                            text: "Motor"
                                            width: parent.width
                                            height: 35
                                            color: "#34495E"
                                            textColor: "white"
                                            onClicked: {
                                                dragDropHelper.startDragFromLibrary("IndustrialComponents.Motor", mouse.x + componentLibrary.x, mouse.y + componentLibrary.y);
                                            }
                                        }

                                        Button {
                                            text: "Pump"
                                            width: parent.width
                                            height: 35
                                            color: "#34495E"
                                            textColor: "white"
                                            onClicked: {
                                                dragDropHelper.startDragFromLibrary("IndustrialComponents.Pump", mouse.x + componentLibrary.x, mouse.y + componentLibrary.y);
                                            }
                                        }
                                    }
                                }

                                // Chart components section
                                ColumnLayout {
                                    spacing: 8

                                    Text {
                                        text: "Chart Components"
                                        font.bold: true
                                        color: "#BDC3C7"
                                    }

                                    ColumnLayout {
                                        spacing: 5

                                        Button {
                                            text: "TrendChart"
                                            width: parent.width
                                            height: 35
                                            color: "#34495E"
                                            textColor: "white"
                                            onClicked: {
                                                dragDropHelper.startDragFromLibrary("ChartComponents.TrendChart", mouse.x + componentLibrary.x, mouse.y + componentLibrary.y);
                                            }
                                        }

                                        Button {
                                            text: "BarChart"
                                            width: parent.width
                                            height: 35
                                            color: "#34495E"
                                            textColor: "white"
                                            onClicked: {
                                                dragDropHelper.startDragFromLibrary("ChartComponents.BarChart", mouse.x + componentLibrary.x, mouse.y + componentLibrary.y);
                                            }
                                        }
                                    }
                                }

                                // Control components section
                                ColumnLayout {
                                    spacing: 8

                                    Text {
                                        text: "Control Components"
                                        font.bold: true
                                        color: "#BDC3C7"
                                    }

                                    ColumnLayout {
                                        spacing: 5

                                        Button {
                                            text: "Slider"
                                            width: parent.width
                                            height: 35
                                            color: "#34495E"
                                            textColor: "white"
                                            onClicked: {
                                                dragDropHelper.startDragFromLibrary("ControlComponents.Slider", mouse.x + componentLibrary.x, mouse.y + componentLibrary.y);
                                            }
                                        }

                                        Button {
                                            text: "Knob"
                                            width: parent.width
                                            height: 35
                                            color: "#34495E"
                                            textColor: "white"
                                            onClicked: {
                                                dragDropHelper.startDragFromLibrary("ControlComponents.Knob", mouse.x + componentLibrary.x, mouse.y + componentLibrary.y);
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Canvas for component placement
                        Rectangle {
                            id: canvasContainer
                            color: "#1E1E1E"
                            SplitView.fillWidth: true
                            SplitView.fillHeight: true

                            Item {
                                id: canvas
                                anchors.fill: parent
                                anchors.margins: 15
                                clip: true

                                // Canvas background with grid
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#2C2C2C"
                                    radius: 4
                                    border.color: "#34495E"
                                    border.width: 1

                                    // Grid pattern
                                    Repeater {
                                        model: 20
                                        Rectangle {
                                            x: (parent.width / 20) * index
                                            width: 1
                                            height: parent.height
                                            color: "#34495E"
                                            opacity: 0.3
                                        }
                                    }

                                    Repeater {
                                        model: 15
                                        Rectangle {
                                            y: (parent.height / 15) * index
                                            width: parent.width
                                            height: 1
                                            color: "#34495E"
                                            opacity: 0.3
                                        }
                                    }
                                }

                                // Initialize drag and drop helper
                                Component.onCompleted: {
                                    dragDropHelper.init(canvas);
                                }
                            }
                        }

                        // Component properties
                        Rectangle {
                            width: 280
                            color: "#2C2C2C"
                            border.left: Rectangle {
                                width: 1
                                height: parent.height
                                color: "#34495E"
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                Text {
                                    text: "Component Properties"
                                    font.bold: true
                                    font.pointSize: 14
                                    color: "#3498DB"
                                }

                                Text {
                                    id: selectedComponentText
                                    text: "Selected Component: None"
                                    color: "#BDC3C7"
                                }

                                // Property editors will be added here dynamically
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: "#34495E"
                                    radius: 4
                                    visible: false

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Select a component to edit properties"
                                        color: "#7F8C8D"
                                        wrapMode: Text.Wrap
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Tag Management tab
            Tab {
                Rectangle {
                    anchors.fill: parent
                    color: "#1E1E1E"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15

                        // Tag management header
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                text: "Tag Management"
                                font.bold: true
                                font.pointSize: 14
                                color: "#3498DB"
                                Layout.fillWidth: true
                            }

                            Button {
                                text: "Add Tag"
                                width: 100
                                height: 35
                                color: "#27AE60"
                                textColor: "white"
                                onClicked: {
                                    tagDialog.visible = true;
                                }
                            }
                        }

                        // Tag list
                        Rectangle {
                            id: tagListContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#2C2C2C"
                            radius: 4
                            border.color: "#34495E"
                            border.width: 1

                            TableView {
                                anchors.fill: parent
                                anchors.margins: 5
                                model: tagManager ? tagManager.getAllTags() : []
                                sortIndicatorVisible: true

                                TableViewColumn {
                                    role: "name"
                                    title: "Name"
                                    width: 180
                                    delegate: Text {
                                        text: modelData.name
                                        color: "#BDC3C7"
                                        padding: 5
                                    }
                                }

                                TableViewColumn {
                                    role: "group"
                                    title: "Group"
                                    width: 120
                                    delegate: Text {
                                        text: modelData.group
                                        color: "#BDC3C7"
                                        padding: 5
                                    }
                                }

                                TableViewColumn {
                                    role: "value"
                                    title: "Value"
                                    width: 100
                                    delegate: Text {
                                        text: modelData.value
                                        font.bold: true
                                        color: "#3498DB"
                                        padding: 5
                                    }
                                }

                                TableViewColumn {
                                    role: "description"
                                    title: "Description"
                                    width: 300
                                    delegate: Text {
                                        text: modelData.description
                                        color: "#BDC3C7"
                                        padding: 5
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Component Management tab
            Tab {
                Rectangle {
                    anchors.fill: parent
                    color: "#1E1E1E"

                    GridLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        columns: 3
                        rowSpacing: 15
                        columnSpacing: 15

                        // Basic components card
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#2C2C2C"
                            radius: 4
                            border.color: "#34495E"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                Text {
                                    text: "Basic Components"
                                    font.bold: true
                                    font.pointSize: 14
                                    color: "#3498DB"
                                }

                                ColumnLayout {
                                    spacing: 15

                                    Indicator {
                                        width: 80
                                        height: 80
                                        active: true
                                        Layout.alignment: Qt.AlignCenter
                                    }

                                    PushButton {
                                        text: "Button"
                                        width: 120
                                        height: 40
                                        Layout.alignment: Qt.AlignCenter
                                    }

                                    TextLabel {
                                        labelText: "Label:"
                                        valueText: "Value"
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }

                        // Industrial components card
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#2C2C2C"
                            radius: 4
                            border.color: "#34495E"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                Text {
                                    text: "Industrial Components"
                                    font.bold: true
                                    font.pointSize: 14
                                    color: "#3498DB"
                                }

                                ColumnLayout {
                                    spacing: 15

                                    Valve {
                                        width: 100
                                        height: 100
                                        open: true
                                        Layout.alignment: Qt.AlignCenter
                                    }

                                    Tank {
                                        width: 100
                                        height: 140
                                        level: 0.7
                                        Layout.alignment: Qt.AlignCenter
                                    }

                                    Motor {
                                        width: 100
                                        height: 100
                                        running: true
                                        Layout.alignment: Qt.AlignCenter
                                    }

                                    Pump {
                                        width: 100
                                        height: 100
                                        running: true
                                        Layout.alignment: Qt.AlignCenter
                                    }
                                }
                            }
                        }

                        // Chart components card
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#2C2C2C"
                            radius: 4
                            border.color: "#34495E"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                Text {
                                    text: "Chart Components"
                                    font.bold: true
                                    font.pointSize: 14
                                    color: "#3498DB"
                                }

                                ColumnLayout {
                                    spacing: 15
                                    Layout.fillWidth: true

                                    TrendChart {
                                        width: parent.width
                                        height: 180
                                        title: "Trend Chart"
                                    }

                                    BarChart {
                                        width: parent.width
                                        height: 180
                                        title: "Bar Chart"
                                    }
                                }
                            }
                        }

                        // Control components card
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#2C2C2C"
                            radius: 4
                            border.color: "#34495E"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                Text {
                                    text: "Control Components"
                                    font.bold: true
                                    font.pointSize: 14
                                    color: "#3498DB"
                                }

                                ColumnLayout {
                                    spacing: 15
                                    Layout.fillWidth: true

                                    Slider {
                                        width: parent.width
                                        height: 60
                                        label: "Temperature"
                                        unit: "°C"
                                        value: 75
                                    }

                                    Knob {
                                        width: 120
                                        height: 150
                                        label: "Pressure"
                                        unit: "bar"
                                        value: 60
                                        Layout.alignment: Qt.AlignCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Alarm & Event Management tab
            Tab {
                Rectangle {
                    anchors.fill: parent
                    color: "#1E1E1E"

                    SplitView {
                        anchors.fill: parent
                        orientation: Qt.Horizontal
                        handleDelegate: Rectangle {
                            width: 2
                            color: "#34495E"
                        }

                        // Alarm configuration panel
                        Rectangle {
                            id: alarmConfigPanel
                            width: 300
                            color: "#2C2C2C"
                            border.right: Rectangle {
                                width: 1
                                height: parent.height
                                color: "#34495E"
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                Text {
                                    text: "Alarm Configuration"
                                    font.bold: true
                                    font.pointSize: 14
                                    color: "#3498DB"
                                }

                                // Alarm list
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: "#34495E"
                                    radius: 4

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 10

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 10

                                            Text {
                                                text: "Name"
                                                font.bold: true
                                                color: "#BDC3C7"
                                                Layout.preferredWidth: 100
                                            }

                                            Text {
                                                text: "Type"
                                                font.bold: true
                                                color: "#BDC3C7"
                                                Layout.preferredWidth: 80
                                            }

                                            Text {
                                                text: "Status"
                                                font.bold: true
                                                color: "#BDC3C7"
                                                Layout.fillWidth: true
                                            }
                                        }

                                        // Alarm items
                                        Repeater {
                                            model: [
                                                { name: "High Temperature", type: "Warning", status: "Active" },
                                                { name: "Low Pressure", type: "Critical", status: "Inactive" },
                                                { name: "Tank Overflow", type: "Critical", status: "Inactive" },
                                                { name: "Motor Fault", type: "Warning", status: "Inactive" },
                                                { name: "Valve Stuck", type: "Warning", status: "Inactive" }
                                            ]

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 10

                                                Text {
                                                    text: modelData.name
                                                    color: "#BDC3C7"
                                                    Layout.preferredWidth: 100
                                                    elide: Text.ElideRight
                                                }

                                                Text {
                                                    text: modelData.type
                                                    color: modelData.type === "Critical" ? "#E74C3C" : "#F39C12"
                                                    Layout.preferredWidth: 80
                                                }

                                                Text {
                                                    text: modelData.status
                                                    color: modelData.status === "Active" ? "#E74C3C" : "#27AE60"
                                                    Layout.fillWidth: true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Event logs panel
                        Rectangle {
                            id: eventLogsPanel
                            color: "#1E1E1E"
                            SplitView.fillWidth: true
                            SplitView.fillHeight: true

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Text {
                                        text: "Event Logs"
                                        font.bold: true
                                        font.pointSize: 14
                                        color: "#3498DB"
                                        Layout.fillWidth: true
                                    }

                                    Button {
                                        text: "Clear Logs"
                                        width: 100
                                        height: 35
                                        color: "#E74C3C"
                                        textColor: "white"
                                    }
                                }

                                // Event log table
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: "#34495E"
                                    radius: 4

                                    TableView {
                                        anchors.fill: parent
                                        anchors.margins: 5
                                        model: [
                                            { time: "2024-01-01 12:30:45", type: "Alarm", source: "Temperature Sensor", message: "High temperature detected" },
                                            { time: "2024-01-01 12:25:30", type: "Event", source: "Motor 1", message: "Motor started" },
                                            { time: "2024-01-01 12:20:15", type: "Event", source: "Valve 2", message: "Valve opened" },
                                            { time: "2024-01-01 12:15:00", type: "Alarm", source: "Pressure Sensor", message: "Low pressure detected" },
                                            { time: "2024-01-01 12:10:45", type: "Event", source: "System", message: "System started" }
                                        ]

                                        TableViewColumn {
                                            role: "time"
                                            title: "Time"
                                            width: 150
                                            delegate: Text {
                                                text: modelData.time
                                                color: "#BDC3C7"
                                                padding: 5
                                            }
                                        }

                                        TableViewColumn {
                                            role: "type"
                                            title: "Type"
                                            width: 80
                                            delegate: Text {
                                                text: modelData.type
                                                color: modelData.type === "Alarm" ? "#E74C3C" : "#3498DB"
                                                font.bold: true
                                                padding: 5
                                            }
                                        }

                                        TableViewColumn {
                                            role: "source"
                                            title: "Source"
                                            width: 150
                                            delegate: Text {
                                                text: modelData.source
                                                color: "#BDC3C7"
                                                padding: 5
                                            }
                                        }

                                        TableViewColumn {
                                            role: "message"
                                            title: "Message"
                                            width: 400
                                            delegate: Text {
                                                text: modelData.message
                                                color: "#BDC3C7"
                                                padding: 5
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Notification settings panel
                        Rectangle {
                            id: notificationPanel
                            width: 250
                            color: "#2C2C2C"
                            border.left: Rectangle {
                                width: 1
                                height: parent.height
                                color: "#34495E"
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                Text {
                                    text: "Notification Settings"
                                    font.bold: true
                                    font.pointSize: 14
                                    color: "#3498DB"
                                }

                                // Notification options
                                ColumnLayout {
                                    spacing: 10

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            text: "Email Notifications"
                                            color: "#BDC3C7"
                                            Layout.fillWidth: true
                                        }

                                        Switch {
                                            checked: true
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            text: "SMS Notifications"
                                            color: "#BDC3C7"
                                            Layout.fillWidth: true
                                        }

                                        Switch {
                                            checked: false
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            text: "System Alerts"
                                            color: "#BDC3C7"
                                            Layout.fillWidth: true
                                        }

                                        Switch {
                                            checked: true
                                        }
                                    }
                                }

                                // Criticality levels
                                ColumnLayout {
                                    spacing: 10

                                    Text {
                                        text: "Criticality Levels"
                                        font.bold: true
                                        color: "#BDC3C7"
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Rectangle {
                                            width: 20
                                            height: 20
                                            color: "#E74C3C"
                                            radius: 2
                                        }

                                        Text {
                                            text: "Critical - Immediate action required"
                                            color: "#BDC3C7"
                                            Layout.fillWidth: true
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Rectangle {
                                            width: 20
                                            height: 20
                                            color: "#F39C12"
                                            radius: 2
                                        }

                                        Text {
                                            text: "Warning - Action may be required"
                                            color: "#BDC3C7"
                                            Layout.fillWidth: true
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Rectangle {
                                            width: 20
                                            height: 20
                                            color: "#3498DB"
                                            radius: 2
                                        }

                                        Text {
                                            text: "Information - For reference only"
                                            color: "#BDC3C7"
                                            Layout.fillWidth: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Tag dialog for adding new tags
    Dialog {
        id: tagDialog
        visible: false
        title: "Add New Tag"
        width: 400
        height: 300
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            TextField {
                id: tagNameInput
                placeholderText: "Tag Name"
                Layout.fillWidth: true
            }

            TextField {
                id: tagGroupInput
                placeholderText: "Group"
                Layout.fillWidth: true
            }

            TextField {
                id: tagValueInput
                placeholderText: "Value"
                Layout.fillWidth: true
            }

            TextField {
                id: tagDescriptionInput
                placeholderText: "Description"
                Layout.fillWidth: true
            }
        }

        onAccepted: {
            if (tagManager && tagNameInput.text) {
                tagManager.addTag(
                    tagNameInput.text,
                    tagGroupInput.text || "Default",
                    tagValueInput.text || 0,
                    tagDescriptionInput.text
                );
                // Clear inputs
                tagNameInput.text = "";
                tagGroupInput.text = "";
                tagValueInput.text = "";
                tagDescriptionInput.text = "";
            }
        }
    }

    // Initialize core modules
    Component.onCompleted: {
        // Core modules will be initialized from C++
        console.log("SCADA System initialized");
    }
}
