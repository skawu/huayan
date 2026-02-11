import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Dialogs 1.3
import BasicComponents 1.0
import IndustrialComponents 1.0
import ChartComponents 1.0
import "./themes"

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1024
    height: 768
    title: "SCADA System"
    
    // 主题
    property var theme: IndustrialTheme {}
    
    // 主页面切换
    property int currentPage: 0
    
    // 图层管理
    property int currentLayer: 0
    
    // 组件-标签绑定关系
    property var tagBindings: {}
    
    // 快捷键支持
    Shortcut {
        sequence: "Ctrl+S"
        onActivated: {
            if (currentPage === 2) {
                saveConfiguration();
            }
        }
    }
    
    Shortcut {
        sequence: "Ctrl+Z"
        onActivated: {
            // 实现撤销功能
            console.log("Undo operation");
        }
    }
    
    Shortcut {
        sequence: "Ctrl+N"
        onActivated: {
            // 实现新建功能
            console.log("New project");
        }
    }
    
    Shortcut {
        sequence: "Ctrl+O"
        onActivated: {
            if (currentPage === 2) {
                importProject();
            }
        }
    }
    
    Shortcut {
        sequence: "Ctrl+E"
        onActivated: {
            if (currentPage === 2) {
                exportProject();
            }
        }
    }
    
    // 窗口大小变化处理
    onWidthChanged: {
        console.log("Window width changed:", width);
        adjustLayout();
    }
    
    onHeightChanged: {
        console.log("Window height changed:", height);
        adjustLayout();
    }
    
    // 自适应布局调整
    function adjustLayout() {
        // 根据窗口大小调整布局
        if (width < 1280) {
            // 小屏幕布局
            console.log("Using small screen layout");
            // 这里可以添加小屏幕布局调整逻辑
        } else if (width < 1920) {
            // 中等屏幕布局
            console.log("Using medium screen layout");
            // 这里可以添加中等屏幕布局调整逻辑
        } else {
            // 大屏幕布局
            console.log("Using large screen layout");
            // 这里可以添加大屏幕布局调整逻辑
        }
        
        // 调整仪表盘页面的卡片大小
        if (dashboardPage) {
            var cardWidth = (dashboardPage.width - 40) / 3;
            var cardHeight = (dashboardPage.height - 40) / 2;
            // 这里可以添加卡片大小调整逻辑
        }
    }
    
    // 无障碍设计：确保按钮尺寸符合要求
    Component.onCompleted: {
        // 确保所有按钮尺寸≥48×48px
        ensureButtonSizes();
        
        // 启动窗口大小监控
        adjustLayout();
    }
    
    // 确保按钮尺寸符合要求
    function ensureButtonSizes() {
        // 遍历所有按钮，确保尺寸符合要求
        var buttons = findChildren(mainWindow, "Button");
        for (var i = 0; i < buttons.length; i++) {
            var button = buttons[i];
            if (button.implicitWidth < 48) {
                button.implicitWidth = 48;
            }
            if (button.implicitHeight < 48) {
                button.implicitHeight = 48;
            }
        }
    }
    
    // 告警音效提示
    function playAlarmSound(severity) {
        // 根据告警级别播放不同的音效
        console.log("Playing alarm sound for severity:", severity);
        // 这里可以添加音效播放逻辑
    }
    
    // 实时参数预览
    Rectangle {
        id: parameterPreview
        width: 200
        height: 60
        color: theme.surfaceColor
        border.color: theme.borderColor
        border.width: 1
        radius: 4
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 10
        visible: false
        
        ColumnLayout {
            anchors.fill: parent
            padding: 10
            spacing: 5
            
            Text {
                id: previewTitle
                text: "Parameter Preview"
                font.pixelSize: 12
                font.bold: true
                color: theme.textSecondary
                Layout.fillWidth: true
            }
            
            Text {
                id: previewValue
                text: "Value: N/A"
                font.pixelSize: 14
                color: theme.textPrimary
                Layout.fillWidth: true
            }
        }
    }
    
    // 显示参数预览
    function showParameterPreview(title, value) {
        previewTitle.text = title;
        previewValue.text = "Value: " + value;
        parameterPreview.visible = true;
        
        // 3秒后自动隐藏
        setTimeout(function() {
            parameterPreview.visible = false;
        }, 3000);
    }
    
    // 图层模型
    ListModel {
        id: layersModel
        Component.onCompleted: {
            // 添加默认图层
            append({name: "Layer 1", visible: true});
            append({name: "Layer 2", visible: true});
            append({name: "Layer 3", visible: true});
        }
    }
    
    // 更新图层可见性
    function updateLayerVisibility() {
        // 遍历画布上的所有组件
        for (let i = 0; i < canvas.children.length; i++) {
            const item = canvas.children[i];
            // 检查组件是否有图层属性
            if (item.layer !== undefined) {
                // 检查图层是否存在且可见
                if (item.layer < layersModel.count) {
                    const layer = layersModel.get(item.layer);
                    item.visible = layer.visible;
                }
            }
        }
    }
    
    // 保存配置
    function saveConfiguration() {
        const configuration = {
            layout: getCanvasLayout(),
            layers: getLayersData(),
            tags: getTagsData(),
            version: "1.0",
            timestamp: new Date().toISOString()
        };
        
        const jsonString = JSON.stringify(configuration, null, 2);
        const fileName = "configuration.json";
        
        // 使用 Qt 5.15+ 的 File API
        const file = Qt.createQmlObject('import QtQuick 2.15; File { fileName: "./' + fileName + '"; }', mainWindow);
        if (file) {
            if (file.open(File.WriteOnly | File.Truncate)) {
                file.write(jsonString);
                file.close();
                console.log("Configuration saved to", fileName);
            } else {
                console.error("Failed to open file for writing");
            }
        }
    }
    
    // 导出项目
    function exportProject() {
        const project = {
            configuration: {
                layout: getCanvasLayout(),
                layers: getLayersData(),
                tags: getTagsData()
            },
            metadata: {
                version: "1.0",
                timestamp: new Date().toISOString(),
                projectName: "Huayan SCADA Project"
            }
        };
        
        const jsonString = JSON.stringify(project, null, 2);
        
        // 创建文件对话框
        const fileDialog = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Dialogs 1.3; FileDialog { title: "Export Project"; selectExisting: false; nameFilters: ["Huayan Project Files (*.hyproj)", "All Files (*)"]; }', mainWindow);
        if (fileDialog) {
            fileDialog.accepted.connect(function() {
                const fileName = fileDialog.fileUrl.toString().replace("file://", "");
                const file = Qt.createQmlObject('import QtQuick 2.15; File { fileName: "' + fileName + '"; }', mainWindow);
                if (file) {
                    if (file.open(File.WriteOnly | File.Truncate)) {
                        file.write(jsonString);
                        file.close();
                        console.log("Project exported to", fileName);
                    } else {
                        console.error("Failed to open file for writing");
                    }
                }
            });
            fileDialog.rejected.connect(function() {
                console.log("Export canceled");
            });
            fileDialog.open();
        }
    }
    
    // 导入项目
    function importProject() {
        // 创建文件对话框
        const fileDialog = Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Dialogs 1.3; FileDialog { title: "Import Project"; selectExisting: true; nameFilters: ["Huayan Project Files (*.hyproj)", "All Files (*)"]; }', mainWindow);
        if (fileDialog) {
            fileDialog.accepted.connect(function() {
                const fileName = fileDialog.fileUrl.toString().replace("file://", "");
                const file = Qt.createQmlObject('import QtQuick 2.15; File { fileName: "' + fileName + '"; }', mainWindow);
                if (file) {
                    if (file.open(File.ReadOnly)) {
                        const jsonString = file.readAll();
                        file.close();
                        
                        try {
                            const project = JSON.parse(jsonString);
                            loadProject(project);
                            console.log("Project imported successfully");
                        } catch (e) {
                            console.error("Failed to parse project file:", e);
                        }
                    } else {
                        console.error("Failed to open file for reading");
                    }
                }
            });
            fileDialog.rejected.connect(function() {
                console.log("Import canceled");
            });
            fileDialog.open();
        }
    }
    
    // 获取画布布局
    function getCanvasLayout() {
        const layout = [];
        if (canvas) {
            for (let i = 0; i < canvas.children.length; i++) {
                const item = canvas.children[i];
                if (item.layer !== undefined) {
                    layout.push({
                        type: item.toString().split('QQuickItem_QML_')[1],
                        x: item.x,
                        y: item.y,
                        width: item.width,
                        height: item.height,
                        layer: item.layer,
                        label: item.label || "",
                        tagName: item.tagName || ""
                    });
                }
            }
        }
        return layout;
    }
    
    // 获取图层数据
    function getLayersData() {
        const layers = [];
        for (let i = 0; i < layersModel.count; i++) {
            const layer = layersModel.get(i);
            layers.push({
                name: layer.name,
                visible: layer.visible
            });
        }
        return layers;
    }
    
    // 获取标签数据
    function getTagsData() {
        const tags = [];
        for (let i = 0; i < tagsModel.count; i++) {
            const tag = tagsModel.get(i);
            tags.push({
                name: tag.name,
                value: tag.value,
                group: tag.group,
                isConnected: tag.isConnected
            });
        }
        return tags;
    }
    
    // 加载项目
    function loadProject(project) {
        if (!project || !project.configuration) return;
        
        const config = project.configuration;
        
        // 加载标签
        if (config.tags) {
            tagsModel.clear();
            for (const tag of config.tags) {
                tagsModel.append(tag);
            }
        }
        
        // 加载图层
        if (config.layers) {
            layersModel.clear();
            for (const layer of config.layers) {
                layersModel.append(layer);
            }
        }
        
        // 加载布局
        if (config.layout) {
            // 清空画布
            if (canvas) {
                for (let i = canvas.children.length - 1; i >= 0; i--) {
                    canvas.children[i].destroy();
                }
            }
            
            // 加载组件
            for (const itemInfo of config.layout) {
                // 这里需要根据组件类型创建相应的组件
                // 简化实现，实际项目中需要更复杂的组件创建逻辑
                console.log("Loading component:", itemInfo.type);
            }
        }
    }
    
    // 拖拽辅助
    DragAndDropHelper {
        id: dragHelper
        property Item canvas: canvas
        
        Component.onCompleted: {
            init(canvas);
        }
        
        function startDrag(componentType, componentName, mouseX, mouseY) {
            // 查找组件信息
            const componentInfo = componentLibrary.find(item => item.type === componentType + "." + componentName);
            if (!componentInfo) return;
            
            // 创建组件
            const component = Qt.createQmlObject('import QtQuick 2.15; import ' + componentType + ' 1.0; ' + componentName + ' {}', canvas);
            if (component) {
                // 设置初始属性
                component.width = componentInfo.width;
                component.height = componentInfo.height;
                component.x = snapToGrid(mouseX - canvas.x - component.width / 2);
                component.y = snapToGrid(mouseY - canvas.y - component.height / 2);
                component.label = componentName + " " + canvas.children.length;
                component.layer = currentLayer;
                
                // 设置拖拽处理
                setupDragHandlers(component);
                
                // 添加到画布
                canvas.appendChild(component);
                
                // 添加到模型
                canvasItemsModel.append({
                    "id": canvas.children.length,
                    "name": component.label,
                    "type": componentType,
                    "x": component.x,
                    "y": component.y
                });
                
                // 选择并开始拖拽
                selectItem(component);
                startDrag(component, mouseX, mouseY);
            }
        }
        
        // 组件库模型
        property var componentLibrary: [
            { name: "Indicator", type: "BasicComponents.Indicator", width: 50, height: 50 },
            { name: "PushButton", type: "BasicComponents.PushButton", width: 120, height: 40 },
            { name: "TextLabel", type: "BasicComponents.TextLabel", width: 200, height: 40 },
            { name: "Valve", type: "IndustrialComponents.Valve", width: 100, height: 100 },
            { name: "Tank", type: "IndustrialComponents.Tank", width: 120, height: 180 },
            { name: "Motor", type: "IndustrialComponents.Motor", width: 120, height: 120 },
            { name: "Pump", type: "IndustrialComponents.Pump", width: 120, height: 120 },
            { name: "Gauge", type: "IndustrialComponents.Gauge", width: 200, height: 200 },
            { name: "IndustrialButton", type: "IndustrialComponents.IndustrialButton", width: 120, height: 60 },
            { name: "IndustrialIndicator", type: "IndustrialComponents.IndustrialIndicator", width: 60, height: 60 },
            { name: "TrendChart", type: "ChartComponents.TrendChart", width: 400, height: 300 },
            { name: "BarChart", type: "ChartComponents.BarChart", width: 400, height: 300 }
        ]
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
            
            // 启动数据更新器
            startDataUpdater();
        }
    }
    
    // 数据更新器
    Timer {
        id: dataUpdater
        interval: 500 // 500ms 更新一次，确保延迟小于1秒
        running: false
        repeat: true
        onTriggered: {
            updateTagValues();
        }
    }
    
    // 启动数据更新器
    function startDataUpdater() {
        dataUpdater.running = true;
        console.log("Data updater started with interval:", dataUpdater.interval, "ms");
    }
    
    // 更新标签值
    function updateTagValues() {
        // 模拟实时数据更新
        for (let i = 0; i < tagsModel.count; i++) {
            const tag = tagsModel.get(i);
            if (tag.isConnected) {
                switch (tag.name) {
                    case "Temperature":
                        // 温度在25-26之间波动
                        const newTemp = 25 + Math.random() * 1;
                        tagsModel.setProperty(i, "value", newTemp.toFixed(1));
                        // 更新绑定的组件
                        updateComponentsFromTag(tag.name);
                        break;
                    case "Pressure":
                        // 压力在10-10.5之间波动
                        const newPressure = 10 + Math.random() * 0.5;
                        tagsModel.setProperty(i, "value", newPressure.toFixed(1));
                        // 更新绑定的组件
                        updateComponentsFromTag(tag.name);
                        break;
                    case "Tank1":
                        // 液位在0.7-0.8之间波动
                        const newLevel = 0.7 + Math.random() * 0.1;
                        tagsModel.setProperty(i, "value", newLevel.toFixed(2));
                        // 更新绑定的组件
                        updateComponentsFromTag(tag.name);
                        break;
                    case "Motor1":
                    case "Valve1":
                        // 开关状态随机变化（但频率较低）
                        if (Math.random() < 0.1) {
                            tagsModel.setProperty(i, "value", !tag.value);
                            // 更新绑定的组件
                            updateComponentsFromTag(tag.name);
                        }
                        break;
                }
            }
        }
    }
    
    // 绑定组件到标签
    function bindComponentToTag(component, tagName) {
        if (!component || !tagName) return;
        
        // 查找标签
        let tagIndex = -1;
        for (let i = 0; i < tagsModel.count; i++) {
            if (tagsModel.get(i).name === tagName) {
                tagIndex = i;
                break;
            }
        }
        
        if (tagIndex >= 0) {
            // 存储标签信息
            component.tagName = tagName;
            component.tagIndex = tagIndex;
            
            // 初始值绑定
            updateComponentFromTag(component, tagIndex);
            
            // 跟踪绑定关系
            if (!tagBindings[tagName]) {
                tagBindings[tagName] = [];
            }
            tagBindings[tagName].push(component);
            
            console.log("Component bound to tag:", tagName);
        }
    }
    
    // 更新绑定到标签的所有组件
    function updateComponentsFromTag(tagName) {
        if (!tagBindings[tagName]) return;
        
        // 查找标签
        let tagIndex = -1;
        for (let i = 0; i < tagsModel.count; i++) {
            if (tagsModel.get(i).name === tagName) {
                tagIndex = i;
                break;
            }
        }
        
        if (tagIndex >= 0) {
            // 更新所有绑定的组件
            const components = tagBindings[tagName];
            for (const component of components) {
                updateComponentFromTag(component, tagIndex);
            }
        }
    }
    
    // 从标签更新组件
    function updateComponentFromTag(component, tagIndex) {
        if (!component || tagIndex < 0 || tagIndex >= tagsModel.count) return;
        
        const tag = tagsModel.get(tagIndex);
        const tagValue = tag.value;
        
        // 根据组件类型更新
        if (component instanceof IndustrialComponents.Gauge) {
            component.value = parseFloat(tagValue);
        } else if (component instanceof IndustrialComponents.IndustrialIndicator) {
            component.value = (tagValue === true || tagValue === "true" || parseFloat(tagValue) > 0);
        } else if (component instanceof IndustrialComponents.Motor) {
            component.value = (tagValue === true || tagValue === "true" || parseFloat(tagValue) > 0);
        } else if (component instanceof IndustrialComponents.Valve) {
            component.value = (tagValue === true || tagValue === "true" || parseFloat(tagValue) > 0);
        } else if (component instanceof IndustrialComponents.Tank) {
            component.value = parseFloat(tagValue);
        } else if (component instanceof BasicComponents.TextLabel) {
            component.text = tagValue.toString();
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
            append({"name": "Pump", "type": "IndustrialComponents", "icon": "🔄"});
            append({"name": "Gauge", "type": "IndustrialComponents", "icon": "📊"});
            append({"name": "IndustrialButton", "type": "IndustrialComponents", "icon": "🔘"});
            append({"name": "IndustrialIndicator", "type": "IndustrialComponents", "icon": "🔴"});
            
            // 添加图表组件
            append({"name": "TrendChart", "type": "ChartComponents", "icon": "📈"});
            append({"name": "BarChart", "type": "ChartComponents", "icon": "📊"});
            
            // 添加3D组件
            append({"name": "ThreeDScene", "type": "ThreeDComponents", "icon": "🎯"});
            append({"name": "ModelLoader", "type": "ThreeDComponents", "icon": "📦"});
            append({"name": "CameraController", "type": "ThreeDComponents", "icon": "🎮"});
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
            color: theme.primaryColor
            
            RowLayout {
                anchors.fill: parent
                spacing: 20
                
                Text {
                    text: "SCADA System"
                    font.pixelSize: 20
                    font.bold: true
                    color: theme.textLight
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
                            color: mainWindow.currentPage === 0 ? theme.secondaryColor : "transparent"
                            border.color: theme.textLight
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: theme.textLight
                            font.pixelSize: 14
                        }
                    }
                    
                    Button {
                        text: "Tags"
                        onClicked: mainWindow.currentPage = 1
                        background: Rectangle {
                            color: mainWindow.currentPage === 1 ? theme.secondaryColor : "transparent"
                            border.color: theme.textLight
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: theme.textLight
                            font.pixelSize: 14
                        }
                    }
                    
                    Button {
                        text: "Editor"
                        onClicked: mainWindow.currentPage = 2
                        background: Rectangle {
                            color: mainWindow.currentPage === 2 ? theme.secondaryColor : "transparent"
                            border.color: theme.textLight
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: theme.textLight
                            font.pixelSize: 14
                        }
                    }
                    
                    Button {
                        text: "Components"
                        onClicked: mainWindow.currentPage = 3
                        background: Rectangle {
                            color: mainWindow.currentPage === 3 ? theme.secondaryColor : "transparent"
                            border.color: theme.textLight
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: theme.textLight
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
                background: Rectangle { color: theme.backgroundColor }
                
                GridLayout {
                    columns: 3
                    rows: 2
                    spacing: 20
                    
                    // 电机状态
                    Rectangle {
                        width: (dashboardPage.width - 40) / 3
                        height: (dashboardPage.height - 40) / 2
                        color: theme.cardColor
                        border.color: theme.borderColor
                        border.width: 1
                        radius: 8
                        
                        // 阴影效果
                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: theme.shadowColor
                            radius: 4
                            samples: 8
                            offset.x: 0
                            offset.y: 2
                        }
                        
                        ColumnLayout {
                            anchors.fill: parent
                            padding: 16
                            spacing: 10
                            
                            Text {
                                text: "Motor Status"
                                font.pixelSize: 16
                                font.bold: true
                                color: theme.textPrimary
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            Item {
                                Layout.fillHeight: true
                                
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
                                        color: theme.textPrimary
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                        }
                    }
                    
                    // 阀门状态
                    Rectangle {
                        width: (dashboardPage.width - 40) / 3
                        height: (dashboardPage.height - 40) / 2
                        color: theme.cardColor
                        border.color: theme.borderColor
                        border.width: 1
                        radius: 8
                        
                        // 阴影效果
                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: theme.shadowColor
                            radius: 4
                            samples: 8
                            offset.x: 0
                            offset.y: 2
                        }
                        
                        ColumnLayout {
                            anchors.fill: parent
                            padding: 16
                            spacing: 10
                            
                            Text {
                                text: "Valve Status"
                                font.pixelSize: 16
                                font.bold: true
                                color: theme.textPrimary
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            Item {
                                Layout.fillHeight: true
                                
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
                                        color: theme.textPrimary
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                        }
                    }
                    
                    // 储罐状态
                    Rectangle {
                        width: (dashboardPage.width - 40) / 3
                        height: (dashboardPage.height - 40) / 2
                        color: theme.cardColor
                        border.color: theme.borderColor
                        border.width: 1
                        radius: 8
                        
                        // 阴影效果
                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: theme.shadowColor
                            radius: 4
                            samples: 8
                            offset.x: 0
                            offset.y: 2
                        }
                        
                        ColumnLayout {
                            anchors.fill: parent
                            padding: 16
                            spacing: 10
                            
                            Text {
                                text: "Tank Level"
                                font.pixelSize: 16
                                font.bold: true
                                color: theme.textPrimary
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            Item {
                                Layout.fillHeight: true
                                
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
                                        color: theme.textPrimary
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                        }
                    }
                    
                    // 温度传感器
                    Rectangle {
                        width: (dashboardPage.width - 40) / 3
                        height: (dashboardPage.height - 40) / 2
                        color: theme.cardColor
                        border.color: theme.borderColor
                        border.width: 1
                        radius: 8
                        
                        // 阴影效果
                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: theme.shadowColor
                            radius: 4
                            samples: 8
                            offset.x: 0
                            offset.y: 2
                        }
                        
                        ColumnLayout {
                            anchors.fill: parent
                            padding: 16
                            spacing: 10
                            
                            Text {
                                text: "Temperature"
                                font.pixelSize: 16
                                font.bold: true
                                color: theme.textPrimary
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            Item {
                                Layout.fillHeight: true
                                
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
                        }
                    }
                    
                    // 压力传感器
                    Rectangle {
                        width: (dashboardPage.width - 40) / 3
                        height: (dashboardPage.height - 40) / 2
                        color: theme.cardColor
                        border.color: theme.borderColor
                        border.width: 1
                        radius: 8
                        
                        // 阴影效果
                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: theme.shadowColor
                            radius: 4
                            samples: 8
                            offset.x: 0
                            offset.y: 2
                        }
                        
                        ColumnLayout {
                            anchors.fill: parent
                            padding: 16
                            spacing: 10
                            
                            Text {
                                text: "Pressure"
                                font.pixelSize: 16
                                font.bold: true
                                color: theme.textPrimary
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            Item {
                                Layout.fillHeight: true
                                
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
                                        lineColor: theme.successColor
                                    }
                                }
                            }
                        }
                    }
                    
                    // 系统状态
                    Rectangle {
                        width: (dashboardPage.width - 40) / 3
                        height: (dashboardPage.height - 40) / 2
                        color: theme.cardColor
                        border.color: theme.borderColor
                        border.width: 1
                        radius: 8
                        
                        // 阴影效果
                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: theme.shadowColor
                            radius: 4
                            samples: 8
                            offset.x: 0
                            offset.y: 2
                        }
                        
                        ColumnLayout {
                            anchors.fill: parent
                            padding: 16
                            spacing: 10
                            
                            Text {
                                text: "System Status"
                                font.pixelSize: 16
                                font.bold: true
                                color: theme.textPrimary
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            Item {
                                Layout.fillHeight: true
                                
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
                                            color: theme.textPrimary
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
                                            color: theme.textPrimary
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
                                            onColor: theme.errorColor
                                        }
                                        
                                        Text {
                                            text: "No Alarms"
                                            font.pixelSize: 16
                                            color: theme.textPrimary
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
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
                                            hoverEnabled: true
                                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                                            
                                            property var startMouseX: 0
                                            property var startMouseY: 0
                                            property var isDragging: false
                                            
                                            onPressed: {
                                                startMouseX = mouseX;
                                                startMouseY = mouseY;
                                                isDragging = true;
                                                // 开始拖拽组件
                                                dragHelper.startDrag(model.type, model.name, mouseX, mouseY);
                                            }
                                            
                                            onReleased: {
                                                isDragging = false;
                                                dragHelper.endDrag();
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
                            
                            ComboBox {
                                id: layerCombo
                                placeholderText: "Select Layer"
                                model: layersModel
                                currentIndex: 0
                                onCurrentIndexChanged: {
                                    // 切换当前图层
                                    currentLayer = layerCombo.currentIndex;
                                    updateLayerVisibility();
                                }
                            }
                            
                            RowLayout {
                                spacing: 5
                                Button {
                                    text: "Add Layer"
                                    onClicked: {
                                        const layerName = "Layer " + (layersModel.count + 1);
                                        layersModel.append({name: layerName, visible: true});
                                        layerCombo.currentIndex = layersModel.count - 1;
                                    }
                                }
                                Button {
                                    text: "Delete Layer"
                                    onClicked: {
                                        if (layersModel.count > 1) {
                                            layersModel.remove(layerCombo.currentIndex);
                                            layerCombo.currentIndex = Math.min(layerCombo.currentIndex, layersModel.count - 1);
                                        }
                                    }
                                }
                                Button {
                                    text: "Toggle Visibility"
                                    onClicked: {
                                        if (layerCombo.currentIndex >= 0) {
                                            const layer = layersModel.get(layerCombo.currentIndex);
                                            layer.visible = !layer.visible;
                                            updateLayerVisibility();
                                        }
                                    }
                                }
                            }
                            
                            RowLayout {
                                spacing: 5
                                Button {
                                    text: "Save Configuration"
                                    onClicked: {
                                        saveConfiguration();
                                    }
                                }
                                Button {
                                    text: "Export Project"
                                    onClicked: {
                                        exportProject();
                                    }
                                }
                                Button {
                                    text: "Import Project"
                                    onClicked: {
                                        importProject();
                                    }
                                }
                            }
                            
                            RowLayout {
                                spacing: 5
                                
                                Button {
                                    text: "Align Left"
                                    onClicked: {
                                        if (typeof dragHelper !== 'undefined' && dragHelper.alignItems) {
                                            dragHelper.alignItems("left");
                                        }
                                    }
                                }
                                
                                Button {
                                    text: "Align Top"
                                    onClicked: {
                                        if (typeof dragHelper !== 'undefined' && dragHelper.alignItems) {
                                            dragHelper.alignItems("top");
                                        }
                                    }
                                }
                                
                                Button {
                                    text: "Align Center"
                                    onClicked: {
                                        if (typeof dragHelper !== 'undefined' && dragHelper.alignItems) {
                                            dragHelper.alignItems("center");
                                        }
                                    }
                                }
                                
                                Button {
                                    text: "Distribute"
                                    onClicked: {
                                        if (typeof dragHelper !== 'undefined' && dragHelper.distributeItems) {
                                            dragHelper.distributeItems("horizontal");
                                        }
                                    }
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
                    id: contentContainer
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 15
                }
            }
        }
    }

    // 卡片控件
    Card {
        id: card
        property alias contentItem: contentItem
        
        Rectangle {
            id: cardBackground
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
}
