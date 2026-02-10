import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import BasicComponents 1.0
import IndustrialComponents 1.0
import ControlComponents 1.0
import ChartComponents 1.0
import ThreeDComponents 1.0

// 组件项组件
Component {
    id: componentItem
    
    Item {
        id: root
        property string name: ""
        property string type: ""
        
        width: 80
        height: 100
        
        Rectangle {
            id: preview
            width: root.width - 10
            height: root.width - 10
            anchors.centerIn: parent
            anchors.topMargin: 5
            color: "#F0F0F0"
            border.color: "#CCCCCC"
            border.width: 1
            
            // 组件预览
            Loader {
                anchors.fill: parent
                anchors.margins: 5
                sourceComponent: Qt.createQmlObject('import QtQuick 2.15; import ' + type.split('.')[0] + ' 1.0; ' + type.split('.')[1] + ' {}', preview)
            }
        }
        
        Text {
            text: name
            anchors.top: preview.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 5
            font.pixelSize: 12
        }
        
        // 拖放功能
        MouseArea {
            anchors.fill: parent
            drag.target: root
            drag.axis: Drag.XAndY
            
            onPressed: {
                // 开始拖动
            }
            
            onReleased: {
                // 结束拖动，放置到画布
            }
        }
    }
}

// 组件项别名
Item {
    id: ComponentItem
    visible: false
}

// CanvasComponent定义
Item {
    id: CanvasComponent
    visible: false
}

// 画布组件
Component {
    id: canvasComponent
    
    Item {
        id: root
        property string name: ""
        property string color: "#FFFFFF"
        property string borderColor: "#CCCCCC"
        property int borderWidth: 1
        property real rotation: 0
        property bool selected: false
        
        width: 100
        height: 100
        
        // 组件内容
        Rectangle {
            id: content
            anchors.fill: parent
            color: root.color
            border.color: root.borderColor
            border.width: root.borderWidth
            rotation: root.rotation
        }
        
        // 选择边框
        Rectangle {
            id: selectionBorder
            anchors.fill: parent
            border.color: "#2196F3"
            border.width: 2
            color: "transparent"
            visible: root.selected
        }
        
        // 调整大小句柄
        Item {
            id: resizeHandles
            anchors.fill: parent
            visible: root.selected
            
            // 右下角
            Loader {
                sourceComponent: resizeHandle
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                onLoaded: {
                    item.target = root
                    item.position = "bottomRight"
                }
            }
            // 左下角
            Loader {
                sourceComponent: resizeHandle
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                onLoaded: {
                    item.target = root
                    item.position = "bottomLeft"
                }
            }
            // 右上角
            Loader {
                sourceComponent: resizeHandle
                anchors.top: parent.top
                anchors.right: parent.right
                onLoaded: {
                    item.target = root
                    item.position = "topRight"
                }
            }
            // 左上角
            Loader {
                sourceComponent: resizeHandle
                anchors.top: parent.top
                anchors.left: parent.left
                onLoaded: {
                    item.target = root
                    item.position = "topLeft"
                }
            }
            // 左侧
            Loader {
                sourceComponent: resizeHandle
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                onLoaded: {
                    item.target = root
                    item.position = "left"
                }
            }
            // 右侧
            Loader {
                sourceComponent: resizeHandle
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                onLoaded: {
                    item.target = root
                    item.position = "right"
                }
            }
            // 顶部
            Loader {
                sourceComponent: resizeHandle
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                onLoaded: {
                    item.target = root
                    item.position = "top"
                }
            }
            // 底部
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
        
        // 旋转句柄
        Rectangle {
            id: rotationHandle
            width: 12
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
                
                onPressed: {
                    // 开始旋转
                }
                
                onMouseXChanged: {
                    if (pressed) {
                        // 计算旋转角度
                        const dx = mouseX - root.width/2
                        const dy = mouseY - root.height/2
                        root.rotation = Math.atan2(dy, dx) * 180 / Math.PI
                    }
                }
            }
        }
        
        // 拖放功能
        MouseArea {
            anchors.fill: parent
            drag.target: root
            drag.axis: Drag.XAndY
            
            onPressed: {
                // 选择组件
                root.selected = true
                // 显示属性面板
                updatePropertyPanel(root)
            }
            
            onReleased: {
                // 结束拖动
            }
        }
    }
}

// 调整大小句柄
Component {
    id: resizeHandle
    
    Item {
        property var target: null
        property string position: ""
        
        width: 8
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
            
            onPressed: {
                // 开始调整大小
            }
            
            onMouseXChanged: {
                if (pressed && target) {
                    // 根据位置调整大小
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

// 更新画布变换
function updateCanvasTransform() {
    if (canvas) {
        canvas.transformOrigin = Item.TopLeft
        canvas.scale = canvasContainer.scale
        canvas.x = canvasContainer.offsetX
        canvas.y = canvasContainer.offsetY
    }
}

// 更新状态栏
function updateStatusBar() {
    // 更新缩放信息
    const scaleLabel = statusBar.findChild(Label, "scaleLabel")
    if (scaleLabel) {
        scaleLabel.text = "缩放: " + Math.round(canvasContainer.scale * 100) + "%"
    }
}

// 更新属性面板
function updatePropertyPanel(component) {
    if (!component) return
    
    // 更新位置与大小属性
    const xSpinBox = propertyPanel.findChild(SpinBox, "xSpinBox")
    const ySpinBox = propertyPanel.findChild(SpinBox, "ySpinBox")
    const widthSpinBox = propertyPanel.findChild(SpinBox, "widthSpinBox")
    const heightSpinBox = propertyPanel.findChild(SpinBox, "heightSpinBox")
    
    if (xSpinBox) xSpinBox.value = component.x
    if (ySpinBox) ySpinBox.value = component.y
    if (widthSpinBox) widthSpinBox.value = component.width
    if (heightSpinBox) heightSpinBox.value = component.height
    
    // 更新外观属性
    // ...
}

// CanvasComponent 工厂函数
function createCanvasComponent(name, x, y, width, height, color) {
    const component = canvasComponent.createObject(canvas)
    if (component) {
        component.name = name
        component.x = x
        component.y = y
        component.width = width
        component.height = height
        component.color = color
        return component
    }
    return null
}

// 数据绑定管理
var dataBindings = {}

// 应用数据绑定
function applyDataBinding() {
    const selectedComponent = getSelectedComponent()
    if (!selectedComponent) {
        showNotification("请先选择一个组件", "warning")
        return
    }
    
    const tagName = tagComboBox.currentText
    if (tagName === "选择点位") {
        showNotification("请选择一个数据点位", "warning")
        return
    }
    
    const property = propertyComboBox.currentText
    const bindingType = bindingTypeComboBox.currentText
    const updateFrequency = updateFrequencyComboBox.currentText
    const historyEnabled = historyDataCheckBox.checked
    const trendEnabled = trendChartCheckBox.checked
    const expression = bindingExpressionField.text
    
    // 保存绑定配置
    const bindingConfig = {
        component: selectedComponent,
        tagName: tagName,
        property: property,
        bindingType: bindingType,
        updateFrequency: updateFrequency,
        historyEnabled: historyEnabled,
        trendEnabled: trendEnabled,
        expression: expression
    }
    
    // 存储绑定
    const componentId = getComponentId(selectedComponent)
    dataBindings[componentId] = bindingConfig
    
    // 启动数据更新
    startDataUpdate(componentId, bindingConfig)
    
    showNotification("数据绑定成功", "success")
}

// 移除数据绑定
function removeDataBinding() {
    const selectedComponent = getSelectedComponent()
    if (!selectedComponent) {
        showNotification("请先选择一个组件", "warning")
        return
    }
    
    const componentId = getComponentId(selectedComponent)
    if (dataBindings[componentId]) {
        // 停止数据更新
        stopDataUpdate(componentId)
        
        // 删除绑定
        delete dataBindings[componentId]
        
        showNotification("数据绑定已解除", "success")
    } else {
        showNotification("该组件没有数据绑定", "info")
    }
}

// 启动数据更新
function startDataUpdate(componentId, bindingConfig) {
    // 模拟数据更新
    const updateInterval = getUpdateIntervalMs(bindingConfig.updateFrequency)
    
    // 创建定时器
    bindingConfig.timer = setInterval(function() {
        updateComponentFromData(bindingConfig)
    }, updateInterval)
}

// 停止数据更新
function stopDataUpdate(componentId) {
    const bindingConfig = dataBindings[componentId]
    if (bindingConfig && bindingConfig.timer) {
        clearInterval(bindingConfig.timer)
        bindingConfig.timer = null
    }
}

// 从数据更新组件
function updateComponentFromData(bindingConfig) {
    if (!bindingConfig || !bindingConfig.component) return
    
    // 模拟数据获取
    const tagValue = getSimulatedTagValue(bindingConfig.tagName)
    
    // 根据绑定类型处理
    switch (bindingConfig.bindingType) {
        case "实时绑定":
            updateComponentProperty(bindingConfig.component, bindingConfig.property, tagValue)
            break
        case "条件绑定":
            if (bindingConfig.expression) {
                const result = evaluateExpression(bindingConfig.expression, tagValue)
                updateComponentProperty(bindingConfig.component, bindingConfig.property, result)
            }
            break
        case "表达式绑定":
            if (bindingConfig.expression) {
                const result = evaluateExpression(bindingConfig.expression, tagValue)
                updateComponentProperty(bindingConfig.component, bindingConfig.property, result)
            }
            break
    }
}

// 更新组件属性
function updateComponentProperty(component, property, value) {
    switch (property) {
        case "填充色":
            if (typeof value === "number") {
                // 基于数值设置颜色
                component.color = value > 50 ? "#F44336" : "#4CAF50"
            } else if (typeof value === "string") {
                component.color = value
            }
            break
        case "位置":
            if (typeof value === "number") {
                // 基于数值设置位置
                component.x = 100 + value * 2
            }
            break
        case "大小":
            if (typeof value === "number") {
                // 基于数值设置大小
                component.width = 100 + value * 0.5
                component.height = 100 + value * 0.5
            }
            break
        case "旋转":
            if (typeof value === "number") {
                component.rotation = value
            }
            break
        case "透明度":
            if (typeof value === "number") {
                component.opacity = value / 100
            }
            break
    }
}

// 获取模拟标签值
function getSimulatedTagValue(tagName) {
    // 模拟不同标签的值
    const tagValues = {
        "tag1": Math.random() * 100,
        "tag2": Math.random() * 50 + 50,
        "tag3": Math.random() * 360,
        "tag4": Math.random() * 100,
        "tag5": Math.random() > 0.5 ? 1 : 0
    }
    return tagValues[tagName] || 0
}

// 评估表达式
function evaluateExpression(expression, value) {
    try {
        // 简单的表达式评估
        const evalExpression = expression.replace(/value/g, value)
        return eval(evalExpression)
    } catch (e) {
        console.error("表达式评估错误:", e)
        return value
    }
}

// 获取更新间隔（毫秒）
function getUpdateIntervalMs(frequency) {
    const intervals = {
        "100ms": 100,
        "200ms": 200,
        "500ms": 500,
        "1s": 1000,
        "2s": 2000,
        "5s": 5000
    }
    return intervals[frequency] || 1000
}

// 获取选中的组件
function getSelectedComponent() {
    // 查找第一个选中的组件
    for (let i = 0; i < canvas.children.length; i++) {
        const child = canvas.children[i]
        if (child.item && child.item.selected) {
            return child.item
        }
    }
    return null
}

// 获取组件ID
function getComponentId(component) {
    return component.name + "_" + Date.now()
}

// 显示通知
function showNotification(message, type) {
    console.log(type + ": " + message)
    // 实际应用中可以显示一个通知组件
}

// 初始化数据点位
function initializeTags() {
    // 模拟初始化一些数据点位
    console.log("数据点位初始化完成")
}

// 初始化函数
function initialize() {
    initializeTags()
    updateCanvasTransform()
    updateStatusBar()
}

Window {
    width: 1440
    height: 900
    visible: true
    title: "Huayan 工业组态软件"
    
    Component.onCompleted: {
        initialize()
    }
    
    // 主布局
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // 菜单栏
        MenuBar {
            Menu {
                title: "文件"
                MenuItem { text: "新建项目" }
                MenuItem { text: "打开项目" }
                MenuItem { text: "保存项目" }
                MenuItem { text: "另存为" }
                MenuSeparator { }
                MenuItem { text: "导出项目" }
                MenuItem { text: "导入项目" }
                MenuSeparator { }
                MenuItem { text: "退出" }
            }
            Menu {
                title: "编辑"
                MenuItem { text: "撤销" }
                MenuItem { text: "重做" }
                MenuSeparator { }
                MenuItem { text: "剪切" }
                MenuItem { text: "复制" }
                MenuItem { text: "粘贴" }
                MenuSeparator { }
                MenuItem { text: "删除" }
                MenuItem { text: "全选" }
            }
            Menu {
                title: "视图"
                MenuItem { text: "工具栏" }
                MenuItem { text: "项目浏览器" }
                MenuItem { text: "属性面板" }
                MenuItem { text: "状态栏" }
                MenuSeparator { }
                MenuItem { text: "网格显示" }
                MenuItem { text: "对齐辅助线" }
            }
            Menu {
                title: "工具"
                MenuItem { text: "组件库" }
                MenuItem { text: "布局模板" }
                MenuItem { text: "主题设置" }
                MenuItem { text: "选项" }
            }
            Menu {
                title: "帮助"
                MenuItem { text: "用户手册" }
                MenuItem { text: "关于" }
            }
        }
        
        // 工具栏
        ToolBar {
            RowLayout {
                spacing: 5
                
                ToolButton { text: "新建" }
                ToolButton { text: "打开" }
                ToolButton { text: "保存" }
                ToolSeparator { }
                ToolButton { text: "撤销" }
                ToolButton { text: "重做" }
                ToolSeparator { }
                ToolButton { text: "剪切" }
                ToolButton { text: "复制" }
                ToolButton { text: "粘贴" }
                ToolSeparator { }
                ToolButton { text: "放大" }
                ToolButton { text: "缩小" }
                ToolButton { text: "适应窗口" }
            }
        }
        
        // 主工作区
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 1
            
            // 左侧项目浏览器
            Rectangle {
                width: 250
                Layout.fillHeight: true
                color: "#F5F5F5"
                border.color: "#CCCCCC"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    
                    Label {
                        text: "项目浏览器"
                        font.bold: true
                        padding: 5
                        background: Rectangle { color: "#E0E0E0" }
                    }
                    
                    // 项目结构和组件库
                    TabView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        Tab {
                            title: "项目"
                            
                            TreeView {
                                model: ListModel {
                                    ListElement { name: "项目"; type: "project" }
                                    ListElement { name: "页面 1"; type: "page" }
                                    ListElement { name: "页面 2"; type: "page" }
                                    ListElement { name: "数据点位"; type: "tags" }
                                    ListElement { name: "报警"; type: "alarms" }
                                }
                                
                                delegate: Item {
                                    width: parent.width
                                    height: 30
                                    Text {
                                        text: name
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                    }
                                }
                            }
                        }
                        
                        Tab {
                            title: "组件库"
                            
                            ColumnLayout {
                                spacing: 10
                                padding: 5
                                
                                // 组件分类
                                RowLayout {
                                    spacing: 5
                                    
                                    Button { text: "基础组件" }
                                    Button { text: "工业组件" }
                                    Button { text: "控制组件" }
                                    Button { text: "图表组件" }
                                    Button { text: "3D组件" }
                                }
                                
                                // 组件列表
                                GridLayout {
                                    columns: 2
                                    spacing: 10
                                    
                                    // 基础组件
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "Indicator"
                                            item.type = "BasicComponents.Indicator"
                                        }
                                    }
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "PushButton"
                                            item.type = "BasicComponents.PushButton"
                                        }
                                    }
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "TextLabel"
                                            item.type = "BasicComponents.TextLabel"
                                        }
                                    }
                                    
                                    // 工业组件
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "Valve"
                                            item.type = "IndustrialComponents.Valve"
                                        }
                                    }
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "Tank"
                                            item.type = "IndustrialComponents.Tank"
                                        }
                                    }
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "Motor"
                                            item.type = "IndustrialComponents.Motor"
                                        }
                                    }
                                    
                                    // 控制组件
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "Slider"
                                            item.type = "ControlComponents.Slider"
                                        }
                                    }
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "Knob"
                                            item.type = "ControlComponents.Knob"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // 中央画布区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#FFFFFF"
                border.color: "#CCCCCC"
                border.width: 1
                
                // 画布容器
                Item {
                    id: canvasContainer
                    anchors.fill: parent
                    
                    // 画布变换属性
                    property real scale: 1.0
                    property real minScale: 0.1
                    property real maxScale: 5.0
                    property real offsetX: 0
                    property real offsetY: 0
                    property bool isPanning: false
                    property real panStartX: 0
                    property real panStartY: 0
                    property real panOffsetX: 0
                    property real panOffsetY: 0
                    
                    // 鼠标区域
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                        
                        // 开始平移
                        onPressed: {
                            if (mouse.button === Qt.MiddleButton || mouse.button === Qt.RightButton) {
                                canvasContainer.isPanning = true
                                canvasContainer.panStartX = mouse.x
                                canvasContainer.panStartY = mouse.y
                                canvasContainer.panOffsetX = canvasContainer.offsetX
                                canvasContainer.panOffsetY = canvasContainer.offsetY
                            }
                        }
                        
                        // 结束平移
                        onReleased: {
                            if (mouse.button === Qt.MiddleButton || mouse.button === Qt.RightButton) {
                                canvasContainer.isPanning = false
                            }
                        }
                        
                        // 处理平移
                        onMouseXChanged: {
                            if (canvasContainer.isPanning) {
                                canvasContainer.offsetX = canvasContainer.panOffsetX + (mouseX - canvasContainer.panStartX)
                                canvasContainer.offsetY = canvasContainer.panOffsetY + (mouseY - canvasContainer.panStartY)
                                updateCanvasTransform()
                            }
                        }
                        
                        onMouseYChanged: {
                            if (canvasContainer.isPanning) {
                                canvasContainer.offsetX = canvasContainer.panOffsetX + (mouseX - canvasContainer.panStartX)
                                canvasContainer.offsetY = canvasContainer.panOffsetY + (mouseY - canvasContainer.panStartY)
                                updateCanvasTransform()
                            }
                        }
                        
                        // 处理缩放
                        onWheel: {
                            const zoomFactor = wheel.angleDelta.y > 0 ? 1.1 : 0.9
                            const newScale = Math.max(canvasContainer.minScale, Math.min(canvasContainer.maxScale, canvasContainer.scale * zoomFactor))
                            
                            if (newScale !== canvasContainer.scale) {
                                // 计算缩放中心点
                                const mouseXRelative = wheel.x - canvasContainer.offsetX
                                const mouseYRelative = wheel.y - canvasContainer.offsetY
                                
                                // 调整偏移量以保持鼠标位置不变
                                const scaleRatio = newScale / canvasContainer.scale
                                canvasContainer.offsetX = wheel.x - mouseXRelative * scaleRatio
                                canvasContainer.offsetY = wheel.y - mouseYRelative * scaleRatio
                                canvasContainer.scale = newScale
                                
                                updateCanvasTransform()
                                updateStatusBar()
                            }
                        }
                    }
                    
                    // 画布内容
                    Item {
                        id: canvas
                        anchors.fill: parent
                        
                        // 网格背景
                        Rectangle {
                            anchors.fill: parent
                            color: "#F9F9F9"
                            
                            // 网格线
                            Repeater {
                                model: canvas.width / 20
                                Rectangle {
                                    width: 1
                                    height: canvas.height
                                    x: index * 20
                                    color: "#E0E0E0"
                                }
                            }
                            Repeater {
                                model: canvas.height / 20
                                Rectangle {
                                    width: canvas.width
                                    height: 1
                                    y: index * 20
                                    color: "#E0E0E0"
                                }
                            }
                        }
                        
                        // 示例组件
                        Loader {
                            id: component1
                            sourceComponent: canvasComponent
                            x: 100
                            y: 100
                            width: 100
                            height: 100
                            onLoaded: {
                                item.name = "矩形 1"
                                item.color = "#2196F3"
                                item.borderColor = "#1976D2"
                                item.borderWidth = 2
                            }
                        }
                        
                        Loader {
                            id: component2
                            sourceComponent: canvasComponent
                            x: 300
                            y: 200
                            width: 150
                            height: 80
                            onLoaded: {
                                item.name = "矩形 2"
                                item.color = "#4CAF50"
                                item.borderColor = "#388E3C"
                                item.borderWidth = 2
                            }
                        }
                    }
                }
            }
            
            // 右侧属性面板
            Rectangle {
                width: 300
                Layout.fillHeight: true
                color: "#F5F5F5"
                border.color: "#CCCCCC"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    
                    Label {
                        text: "属性面板"
                        font.bold: true
                        padding: 5
                        background: Rectangle { color: "#E0E0E0" }
                    }
                    
                    // 属性编辑器
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        ColumnLayout {
                            spacing: 10
                            padding: 10
                            
                            GroupBox {
                                title: "位置与大小"
                                
                                GridLayout {
                                    columns: 2
                                    spacing: 5
                                    
                                    Label { text: "X:" }
                                    SpinBox { value: 100 }
                                    Label { text: "Y:" }
                                    SpinBox { value: 100 }
                                    Label { text: "宽度:" }
                                    SpinBox { value: 100 }
                                    Label { text: "高度:" }
                                    SpinBox { value: 100 }
                                }
                            }
                            
                            GroupBox {
                                title: "外观"
                                
                                GridLayout {
                                    columns: 2
                                    spacing: 5
                                    
                                    Label { text: "填充色:" }
                                    ColorDialog { id: fillColorDialog }
                                    Label { text: "边框色:" }
                                    ColorDialog { id: borderColorDialog }
                                    Label { text: "边框宽度:" }
                                    SpinBox { value: 2 }
                                }
                            }
                            
                            GroupBox {
                                title: "数据绑定"
                                
                                GridLayout {
                                    columns: 2
                                    spacing: 5
                                    
                                    Label { text: "数据点位:" }
                                    ComboBox {
                                        id: tagComboBox
                                        model: ["选择点位", "tag1", "tag2", "tag3", "tag4", "tag5"]
                                    }
                                    Label { text: "绑定属性:" }
                                    ComboBox {
                                        id: propertyComboBox
                                        model: ["填充色", "位置", "大小", "旋转", "透明度"]
                                    }
                                    Label { text: "绑定方式:" }
                                    ComboBox {
                                        id: bindingTypeComboBox
                                        model: ["实时绑定", "条件绑定", "表达式绑定"]
                                    }
                                    Label { text: "更新频率:" }
                                    ComboBox {
                                        id: updateFrequencyComboBox
                                        model: ["100ms", "200ms", "500ms", "1s", "2s", "5s"]
                                    }
                                    Label { text: "历史数据:" }
                                    CheckBox {
                                        id: historyDataCheckBox
                                        text: "启用"
                                    }
                                    Label { text: "趋势图表:" }
                                    CheckBox {
                                        id: trendChartCheckBox
                                        text: "启用"
                                    }
                                }
                            }
                            
                            GroupBox {
                                title: "绑定配置"
                                
                                ColumnLayout {
                                    spacing: 5
                                    
                                    Label { text: "绑定表达式:" }
                                    TextField {
                                        id: bindingExpressionField
                                        placeholderText: "例如: value > 50 ? 'red' : 'green'"
                                        width: parent.width
                                    }
                                    
                                    Button {
                                        text: "应用绑定"
                                        onClicked: {
                                            applyDataBinding()
                                        }
                                    }
                                    
                                    Button {
                                        text: "解除绑定"
                                        onClicked: {
                                            removeDataBinding()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // 状态栏
        StatusBar {
            RowLayout {
                spacing: 20
                
                Label { text: "就绪" }
                Label { text: "页面: 页面 1" }
                Label { text: "组件: 2" }
                Label { text: "缩放: 100%" }
            }
        }
    }
}
