import QtQuick 2.15
import QtQuick.Layouts 1.15
import Huayan.HMIControls 1.0

Item {
    id: root
    
    // 可自定义属性
    property color selectionColor: "#2196F3"
    property color dragColor: "#1976D2"
    property int selectionBorderWidth: 2
    property int resizeHandleSize: 8
    
    // 状态属性
    property bool editing: false
    property var selectedItem: null
    property var draggedItem: null
    property var dragOffset: Qt.point(0, 0)
    
    // 模板管理
    property string currentTemplate: ""
    property var templates: []
    
    // 背景
    Rectangle {
        id: background
        anchors.fill: parent
        color: "transparent"
        
        // 网格背景
        Canvas {
            id: grid
            anchors.fill: parent
            
            onPaint: {
                var ctx = getContext("2d")
                var gridSize = 20
                
                // 清除画布
                ctx.clearRect(0, 0, width, height)
                
                // 绘制网格
                ctx.strokeStyle = "#BDBDBD"
                ctx.lineWidth = 0.5
                
                // 垂直线
                for (var x = 0; x <= width; x += gridSize) {
                    ctx.beginPath()
                    ctx.moveTo(x, 0)
                    ctx.lineTo(x, height)
                    ctx.stroke()
                }
                
                // 水平线
                for (var y = 0; y <= height; y += gridSize) {
                    ctx.beginPath()
                    ctx.moveTo(0, y)
                    ctx.lineTo(width, y)
                    ctx.stroke()
                }
            }
        }
    }
    
    // 选择框
    Rectangle {
        id: selectionBox
        visible: selectedItem !== null && editing
        border.width: selectionBorderWidth
        border.color: selectionColor
        color: "transparent"
        
        // 位置和尺寸
        x: selectedItem ? selectedItem.x - 4 : 0
        y: selectedItem ? selectedItem.y - 4 : 0
        width: selectedItem ? selectedItem.width + 8 : 0
        height: selectedItem ? selectedItem.height + 8 : 0
        
        // 调整手柄
        Repeater {
            model: [
                { x: 0, y: 0 },
                { x: 0.5, y: 0 },
                { x: 1, y: 0 },
                { x: 0, y: 0.5 },
                { x: 1, y: 0.5 },
                { x: 0, y: 1 },
                { x: 0.5, y: 1 },
                { x: 1, y: 1 }
            ]
            
            Rectangle {
                width: resizeHandleSize
                height: resizeHandleSize
                color: selectionColor
                border.width: 1
                border.color: "#FFFFFF"
                
                x: parent.x + modelData.x * parent.width - width / 2
                y: parent.y + modelData.y * parent.height - height / 2
                
                // 调整手柄交互
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.SizeFDiagCursor
                    
                    onPressed: {
                        draggedItem = selectedItem
                        dragOffset = Qt.point(mouse.x - x, mouse.y - y)
                    }
                    
                    onMouseXChanged: {
                        if (draggedItem && mouse.pressed) {
                            draggedItem.width = Math.max(20, mouse.x - draggedItem.x + dragOffset.x)
                        }
                    }
                    
                    onMouseYChanged: {
                        if (draggedItem && mouse.pressed) {
                            draggedItem.height = Math.max(20, mouse.y - draggedItem.y + dragOffset.y)
                        }
                    }
                }
            }
        }
    }
    
    // 拖拽处理
    MouseArea {
        id: dragArea
        anchors.fill: parent
        enabled: editing
        
        onPressed: {
            // 查找被点击的项目
            var clickedItem = null
            var items = root.children
            
            for (var i = items.length - 1; i >= 0; i--) {
                var item = items[i]
                if (item !== background && item !== selectionBox && 
                    mouse.x >= item.x && mouse.x <= item.x + item.width && 
                    mouse.y >= item.y && mouse.y <= item.y + item.height) {
                    clickedItem = item
                    break
                }
            }
            
            if (clickedItem) {
                selectedItem = clickedItem
                draggedItem = clickedItem
                dragOffset = Qt.point(mouse.x - clickedItem.x, mouse.y - clickedItem.y)
            } else {
                selectedItem = null
                draggedItem = null
            }
        }
        
        onMouseXChanged: {
            if (draggedItem && mouse.pressed) {
                draggedItem.x = mouse.x - dragOffset.x
            }
        }
        
        onMouseYChanged: {
            if (draggedItem && mouse.pressed) {
                draggedItem.y = mouse.y - dragOffset.y
            }
        }
        
        onReleased: {
            draggedItem = null
        }
    }
    
    // 模板管理方法
    function saveTemplate(name) {
        if (!name) {
            return false
        }
        
        // 收集所有控件信息
        var controls = []
        var items = root.children
        
        for (var i = 0; i < items.length; i++) {
            var item = items[i]
            if (item !== background && item !== selectionBox) {
                controls.push({
                    type: item.toString().split('QQuickItem_QML_')[1] || 'Item',
                    x: item.x,
                    y: item.y,
                    width: item.width,
                    height: item.height,
                    properties: collectProperties(item)
                })
            }
        }
        
        // 保存模板
        var template = {
            name: name,
            controls: controls,
            timestamp: Date.now()
        }
        
        // 检查是否已存在
        var existingIndex = -1
        for (var j = 0; j < templates.length; j++) {
            if (templates[j].name === name) {
                existingIndex = j
                break
            }
        }
        
        if (existingIndex >= 0) {
            templates[existingIndex] = template
        } else {
            templates.push(template)
        }
        
        currentTemplate = name
        root.templateSaved(name)
        return true
    }
    
    function loadTemplate(name) {
        // 查找模板
        var template = null
        for (var i = 0; i < templates.length; i++) {
            if (templates[i].name === name) {
                template = templates[i]
                break
            }
        }
        
        if (!template) {
            return false
        }
        
        // 清空现有控件
        clearControls()
        
        // 加载控件
        for (var j = 0; j < template.controls.length; j++) {
            var control = template.controls[j]
            createControl(control)
        }
        
        currentTemplate = name
        root.templateLoaded(name)
        return true
    }
    
    function deleteTemplate(name) {
        for (var i = 0; i < templates.length; i++) {
            if (templates[i].name === name) {
                templates.splice(i, 1)
                if (currentTemplate === name) {
                    currentTemplate = ""
                }
                root.templateDeleted(name)
                return true
            }
        }
        return false
    }
    
    function clearControls() {
        var items = root.children
        var itemsToRemove = []
        
        for (var i = 0; i < items.length; i++) {
            var item = items[i]
            if (item !== background && item !== selectionBox) {
                itemsToRemove.push(item)
            }
        }
        
        for (var j = 0; j < itemsToRemove.length; j++) {
            itemsToRemove[j].destroy()
        }
        
        selectedItem = null
    }
    
    function createControl(controlInfo) {
        // 根据类型创建控件
        var control = null
        
        switch (controlInfo.type) {
            case "Button":
                control = Button {}
                break
            case "IndicatorLight":
                control = IndicatorLight {}
                break
            case "Slider":
                control = Slider {}
                break
            case "DIPSwitch":
                control = DIPSwitch {}
                break
            case "Dashboard":
                control = Dashboard {}
                break
            case "ToggleSwitch":
                control = ToggleSwitch {}
                break
            case "ProgressBar":
                control = ProgressBar {}
                break
            case "NumericDisplay":
                control = NumericDisplay {}
                break
            case "TextDisplay":
                control = TextDisplay {}
                break
            case "MultiStateButton":
                control = MultiStateButton {}
                break
            default:
                return null
        }
        
        // 设置属性
        control.x = controlInfo.x
        control.y = controlInfo.y
        control.width = controlInfo.width
        control.height = controlInfo.height
        
        // 设置其他属性
        if (controlInfo.properties) {
            for (var prop in controlInfo.properties) {
                if (control.hasOwnProperty(prop)) {
                    control[prop] = controlInfo.properties[prop]
                }
            }
        }
        
        // 添加到布局
        control.parent = root
        return control
    }
    
    function collectProperties(item) {
        var properties = {}
        
        // 收集常用属性
        var commonProperties = ["text", "label", "unit", "value", "minValue", "maxValue", "decimalPlaces"]
        
        for (var i = 0; i < commonProperties.length; i++) {
            var prop = commonProperties[i]
            if (item.hasOwnProperty(prop)) {
                properties[prop] = item[prop]
            }
        }
        
        return properties
    }
    
    // 信号
    signal templateSaved(string name)
    signal templateLoaded(string name)
    signal templateDeleted(string name)
    signal itemSelected(var item)
    signal itemMoved(var item, real x, real y)
    signal itemResized(var item, real width, real height)
    
    // 信号处理
    onSelectedItemChanged: {
        root.itemSelected(selectedItem)
    }
    
    // 默认尺寸
    implicitWidth: 800
    Layout.preferredWidth: 800
    height: 600
}
