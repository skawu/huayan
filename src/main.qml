import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import BasicComponents 1.0
import IndustrialComponents 1.0
import ChartComponents 1.0

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1024
    height: 768
    title: "SCADA System"
    
    // 主页面切换
    property int currentPage: 0
    
    // 拖拽辅助
    DragAndDropHelper {
        id: dragHelper
        onItemDropped: {
            if (target === canvas) {
                // 将组件添加到画布
                var newItem = Qt.createComponent("qrc:/qml/plugins/" + item.componentType + "/" + item.componentName + ".qml").createObject(canvas);
                newItem.x = item.x;
                newItem.y = item.y;
                newItem.label = item.componentName + " " + canvas.children.length;
                canvasItemsModel.append({
                    "id": canvas.children.length,
                    "name": newItem.label,
                    "type": item.componentType,
                    "x": newItem.x,
                    "y": newItem.y
                });
            }
        }
    }
    
    // 画布项目模型
    ListModel {
        id: canvasItemsModel
    }
    
    // 标签模型
    ListModel {
        id: tagsModel
        Component.onCompleted: {
            // 添加示例标签
            append({"name": "Motor1", "value": true, "group": " Motors", "isConnected": true});
            append({"name": "Valve1", "value": false, "group": " Valves", "isConnected": true});
            append({"name": "Tank1", "value": 0.75, "group": " Tanks", "isConnected": true});
            append({"name": "Temperature", "value": 25.5, "group": " Sensors", "isConnected": true});
            append({"name": "Pressure", "value": 10.2, "group": " Sensors", "isConnected": true});
        }
    }
    
    // 组件库模型
    ListModel {
        id: componentsModel
        Component.onCompleted: {
            // 添加基础组件
            append({"name": "Indicator", "type": "BasicComponents", "icon": "🔴"});
            append({"name": "PushButton", "type": "BasicComponents", "icon": "🔘"});
            append({"name": "TextLabel", "type": "BasicComponents", "icon": "📝"});
            
            // 添加工业组件
            append({"name": "Valve", "type": "IndustrialComponents", "icon": "🔐"});
            append({"name": "Tank", "type": "IndustrialComponents", "icon": "📦"});
            append({"name": "Motor", "type": "IndustrialComponents", "icon": "⚙️"});
            
            // 添加图表组件
            append({"name": "TrendChart", "type": "ChartComponents", "icon": "📈"});
            append({"name": "BarChart", "type": "ChartComponents", "icon": "📊"});
        }
    }
    
    // 主布局
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // 标题栏
        Rectangle {
            Layout.fillWidth: true
            height: 50
            color: "#3498DB"
            
            RowLayout {
                anchors.fill: parent
                spacing: 20
                
                Text {
                    text: "SCADA System"
                    font.pixelSize: 20
                    font.bold: true
                    color: "white"
                    Layout.leftMargin: 20
                    Layout.verticalAlignment: Layout.AlignVCenter
                }
                
                Item {
                    Layout.fillWidth: true
                }
                
                RowLayout {
                    spacing: 10
                    Layout.rightMargin: 20
                    Layout.verticalAlignment: Layout.AlignVCenter
                    
                    Button {
                        text: "Dashboard"
                        onClicked: mainWindow.currentPage = 0
                        background: Rectangle {
                            color: mainWindow.currentPage === 0 ? "#2980B9" : "transparent"
                            border.color: "white"
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 14
                        }
                    }
                    
                    Button {
                        text: "Tags"
                        onClicked: mainWindow.currentPage = 1
                        background: Rectangle {
                            color: mainWindow.currentPage === 1 ? "#2980B9" : "transparent"
                            border.color: "white"
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 14
                        }
                    }
                    
                    Button {
                        text: "Editor"
                        onClicked: mainWindow.currentPage = 2
                        background: Rectangle {
                            color: mainWindow.currentPage === 2 ? "#2980B9" : "transparent"
                            border.color: "white"
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 14
                        }
                    }
                    
                    Button {
                        text: "Components"
                        onClicked: mainWindow.currentPage = 3
                        background: Rectangle {
                            color: mainWindow.currentPage === 3 ? "#2980B9" : "transparent"
                            border.color: "white"
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 14
                        }
                    }
                }
            }
        }
        
        // 内容区域
        StackLayout {
            id: contentStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: mainWindow.currentPage
            
            // 仪表盘页面
            Page {
                id: dashboardPage
                padding: 20
                
                GridLayout {
                    columns: 3
                    rows: 2
                    spacing: 20
                    
                    // 电机状态
                    Card {
                        width: (dashboardPage.width - 40) / 3
                        height: (dashboardPage.height - 40) / 2
                        title: "Motor Status"
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 20
                            
                            Motor {
                                id: motor1
                                width: 100
                                height: 100
                                value: tagsModel.get(0).value
                                label: "Motor 1"
                            }
                            
                            Text {
                                text: "Status: " + (motor1.value ? "Running" : "Stopped")
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                    
                    // 阀门状态
                    Card {
                        width: (dashboardPage.width - 40) / 3
                        height: (dashboardPage.height - 40) / 2
                        title: "Valve Status"
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 20
                            
                            Valve {
                                id: valve1
                                width: 100
                                height: 100
                                value: tagsModel.get(1).value
                                label: "Valve 1"
                            }
                            
                            Text {
                                text: "Status: " + (valve1.value ? "Open" : "Closed")
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                    
                    // 储罐状态
                    Card {
                        width: (dashboardPage.width - 40) / 3
                        height: (dashboardPage.height - 40) / 2
                        title: "Tank Level"
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 20
                            
                            Tank {
                                id: tank1
                                width: 100
                                height: 150
                                value: tagsModel.get(2).value
                                label: "Tank 1"
                            }
                            
                            Text {
                                text: "Level: " + Math.round(tank1.value * 100) + "%"
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                    
                    // 温度传感器
                    Card {
                        width: (dashboardPage.width - 40) / 3
                        height: (dashboardPage.height - 40) / 2
                        title: "Temperature"
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 20
                            
                            TextLabel {
                                id: tempLabel
                                width: 150
                                height: 50
                                text: tagsModel.get(3).value + " °C"
                                label: "Temperature"
                                textSize: 24
                                boldText: true
                            }
                            
                            TrendChart {
                                width: 250
                                height: 100
                                data: [22, 23, 24, 25, 25.5, 25, 24.5]
                                title: "Temperature Trend"
                            }
                        }
                    }
                    
                    // 压力传感器
                    Card {
                        width: (dashboardPage.width - 40) / 3
                        height: (dashboardPage.height - 40) / 2
                        title: "Pressure"
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 20
                            
                            TextLabel {
                                id: pressureLabel
                                width: 150
                                height: 50
                                text: tagsModel.get(4).value + " bar"
                                label: "Pressure"
                                textSize: 24
                                boldText: true
                            }
                            
                            TrendChart {
                                width: 250
                                height: 100
                                data: [9.8, 10.0, 10.1, 10.2, 10.1, 10.0, 10.2]
                                title: "Pressure Trend"
                                lineColor: "#4CAF50"
                            }
                        }
                    }
                    
                    // 系统状态
                    Card {
                        width: (dashboardPage.width - 40) / 3
                        height: (dashboardPage.height - 40) / 2
                        title: "System Status"
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 15
                            
                            RowLayout {
                                spacing: 10
                                
                                Indicator {
                                    id: connIndicator
                                    width: 50
                                    height: 50
                                    value: true
                                    label: "Connection"
                                }
                                
                                Text {
                                    text: "Connected"
                                    font.pixelSize: 16
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            
                            RowLayout {
                                spacing: 10
                                
                                Indicator {
                                    id: dataIndicator
                                    width: 50
                                    height: 50
                                    value: true
                                    label: "Data"
                                }
                                
                                Text {
                                    text: "Data Receiving"
                                    font.pixelSize: 16
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            
                            RowLayout {
                                spacing: 10
                                
                                Indicator {
                                    id: alarmIndicator
                                    width: 50
                                    height: 50
                                    value: false
                                    label: "Alarm"
                                    onColor: "#F44336"
                                }
                                
                                Text {
                                    text: "No Alarms"
                                    font.pixelSize: 16
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }
                }
            }
            
            // 标签管理页面
            Page {
                id: tagsPage
                padding: 20
                
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 20
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        TextField {
                            id: tagNameField
                            placeholderText: "Tag Name"
                            Layout.fillWidth: true
                        }
                        
                        TextField {
                            id: tagValueField
                            placeholderText: "Tag Value"
                            Layout.fillWidth: true
                        }
                        
                        TextField {
                            id: tagGroupField
                            placeholderText: "Tag Group"
                            Layout.fillWidth: true
                        }
                        
                        Button {
                            text: "Add Tag"
                            onClicked: {
                                tagsModel.append({
                                    "name": tagNameField.text,
                                    "value": parseFloat(tagValueField.text) || false,
                                    "group": tagGroupField.text,
                                    "isConnected": true
                                });
                                tagNameField.text = "";
                                tagValueField.text = "";
                                tagGroupField.text = "";
                            }
                        }
                    }
                    
                    TableView {
                        id: tagsTable
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: tagsModel
                        
                        TableViewColumn {
                            role: "name"
                            title: "Name"
                            width: 150
                        }
                        
                        TableViewColumn {
                            role: "value"
                            title: "Value"
                            width: 100
                        }
                        
                        TableViewColumn {
                            role: "group"
                            title: "Group"
                            width: 100
                        }
                        
                        TableViewColumn {
                            role: "isConnected"
                            title: "Connected"
                            width: 100
                            delegate: CheckBox {
                                checked: model.isConnected
                                enabled: false
                            }
                        }
                        
                        TableViewColumn {
                            title: "Actions"
                            width: 100
                            delegate: Button {
                                text: "Delete"
                                onClicked: {
                                    tagsModel.remove(model.row);
                                }
                            }
                        }
                    }
                }
            }
            
            // 组态编辑器页面
            Page {
                id: editorPage
                padding: 20
                
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 20
                    
                    // 组件库
                    ColumnLayout {
                        width: 200
                        Layout.fillHeight: true
                        spacing: 10
                        
                        Text {
                            text: "Component Library"
                            font.pixelSize: 18
                            font.bold: true
                        }
                        
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            
                            ListView {
                                id: componentsList
                                model: componentsModel
                                delegate: Item {
                                    width: componentsList.width
                                    height: 50
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        color: "#F5F5F5"
                                        radius: 4
                                        border.color: "#E0E0E0"
                                        border.width: 1
                                        
                                        RowLayout {
                                            anchors.fill: parent
                                            padding: 10
                                            spacing: 10
                                            
                                            Text {
                                                text: model.icon
                                                font.pixelSize: 20
                                            }
                                            
                                            ColumnLayout {
                                                spacing: 2
                                                
                                                Text {
                                                    text: model.name
                                                    font.pixelSize: 14
                                                    font.bold: true
                                                }
                                                
                                                Text {
                                                    text: model.type
                                                    font.pixelSize: 12
                                                    color: "#666"
                                                }
                                            }
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            onPressed: {
                                                dragHelper.startDrag({componentType: model.type, componentName: model.name}, mouseX, mouseY);
                                            }
                                            onMouseXChanged: {
                                                if (dragHelper.isDragging) {
                                                    dragHelper.drag(mouseX, mouseY);
                                                }
                                            }
                                            onMouseYChanged: {
                                                if (dragHelper.isDragging) {
                                                    dragHelper.drag(mouseX, mouseY);
                                                }
                                            }
                                            onReleased: {
                                                dragHelper.endDrag(canvas);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // 画布
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 10
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: "Configuration Canvas"
                                font.pixelSize: 18
                                font.bold: true
                            }
                            
                            Button {
                                text: "Save Configuration"
                                onClicked: {
                                    console.log("Configuration saved");
                                }
                            }
                        }
                        
                        Rectangle {
                            id: canvas
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#FFFFFF"
                            border.color: "#E0E0E0"
                            border.width: 1
                            
                            // 网格背景
                            Repeater {
                                model: canvas.width / 20
                                Rectangle {
                                    x: index * 20
                                    width: 1
                                    height: canvas.height
                                    color: "#F0F0F0"
                                }
                            }
                            
                            Repeater {
                                model: canvas.height / 20
                                Rectangle {
                                    y: index * 20
                                    width: canvas.width
                                    height: 1
                                    color: "#F0F0F0"
                                }
                            }
                            
                            // 画布上的组件
                            Component.onCompleted: {
                                // 添加示例组件
                                // 注意：这里使用注释掉的代码，因为在JavaScript中不能直接使用QML组件语法
                                // 实际使用时，应该通过拖拽方式添加组件
                                console.log("Canvas initialized");
                            }
                        }
                    }
                    
                    // 组件属性
                    ColumnLayout {
                        width: 250
                        Layout.fillHeight: true
                        spacing: 10
                        
                        Text {
                            text: "Component Properties"
                            font.pixelSize: 18
                            font.bold: true
                        }
                        
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            
                            ColumnLayout {
                                spacing: 10
                                
                                TextField {
                                    id: componentNameField
                                    placeholderText: "Component Name"
                                    Layout.fillWidth: true
                                }
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10
                                    
                                    TextField {
                                        id: componentXField
                                        placeholderText: "X Position"
                                        Layout.fillWidth: true
                                    }
                                    
                                    TextField {
                                        id: componentYField
                                        placeholderText: "Y Position"
                                        Layout.fillWidth: true
                                    }
                                }
                                
                                ComboBox {
                                    id: tagBindingCombo
                                    placeholderText: "Bind to Tag"
                                    Layout.fillWidth: true
                                    model: tagsModel
                                    textRole: "name"
                                }
                                
                                Button {
                                    text: "Bind Tag"
                                    onClicked: {
                                        console.log("Tag bound:", tagBindingCombo.currentText);
                                    }
                                }
                                
                                Button {
                                    text: "Delete Component"
                                    onClicked: {
                                        console.log("Component deleted");
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // 组件管理页面
            Page {
                id: componentsPage
                padding: 20
                
                GridLayout {
                    columns: 3
                    rows: 3
                    spacing: 20
                    
                    // 基础组件
                    Card {
                        width: (componentsPage.width - 40) / 3
                        height: (componentsPage.height - 40) / 3
                        title: "Basic Components"
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 20
                            
                            Indicator {
                                width: 80
                                height: 80
                                value: true
                                label: "Indicator"
                            }
                            
                            PushButton {
                                width: 100
                                height: 40
                                text: "Button"
                            }
                            
                            TextLabel {
                                width: 120
                                height: 40
                                text: "Sample Text"
                                label: "TextLabel"
                            }
                        }
                    }
                    
                    // 工业组件
                    Card {
                        width: (componentsPage.width - 40) / 3
                        height: (componentsPage.height - 40) / 3
                        title: "Industrial Components"
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 20
                            
                            Valve {
                                width: 80
                                height: 80
                                value: true
                                label: "Valve"
                            }
                            
                            Tank {
                                width: 100
                                height: 120
                                value: 0.6
                                label: "Tank"
                            }
                            
                            Motor {
                                width: 80
                                height: 80
                                value: true
                                label: "Motor"
                            }
                        }
                    }
                    
                    // 图表组件
                    Card {
                        width: (componentsPage.width - 40) / 3
                        height: (componentsPage.height - 40) / 3
                        title: "Chart Components"
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 20
                            
                            TrendChart {
                                width: 250
                                height: 120
                                data: [0, 1, 2, 3, 2, 1, 0, 1, 2, 3]
                                title: "Trend Chart"
                            }
                            
                            BarChart {
                                width: 250
                                height: 120
                                data: [1, 3, 5, 2, 4]
                                categories: ["A", "B", "C", "D", "E"]
                                title: "Bar Chart"
                            }
                        }
                    }
                }
            }
        }
    }
}

// 卡片组件
Component {
    id: cardComponent
    
    Rectangle {
        id: card
        property string title: "Card"
        
        color: "#FFFFFF"
        border.color: "#E0E0E0"
        border.width: 1
        radius: 4
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            
            Text {
                text: card.title
                font.pixelSize: 16
                font.bold: true
                color: "#333333"
                Layout.leftMargin: 15
                Layout.topMargin: 15
                Layout.fillWidth: true
            }
            
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 15
                
                contentItem.parent = this
            }
        }
    }
}

// 卡片控件
Card {
    id: card
    property alias contentItem: contentItem
    
    Rectangle {
        id: card
        color: "#FFFFFF"
        border.color: "#E0E0E0"
        border.width: 1
        radius: 4
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            
            Text {
                text: card.title
                font.pixelSize: 16
                font.bold: true
                color: "#333333"
                Layout.leftMargin: 15
                Layout.topMargin: 15
                Layout.fillWidth: true
            }
            
            Item {
                id: contentItem
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 15
            }
        }
    }
}
