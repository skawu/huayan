import QtQuick 2.15
import QtQuick.Controls 2.15

/**
 * @brief 可拖拽的工业组件基类
 * 
 * 提供工业监控组件的基础功能：
 * - 拖拽移动功能
 * - 基础属性编辑
 * - 组件选择状态
 * - 简单的数据绑定接口
 */
Item {
    id: draggableComponent
    
    // ==================== 基础属性 ====================
    property string componentId: "component_" + Math.random().toString(36).substr(2, 9)
    property string componentName: "工业组件"
    property string componentType: "base"
    
    // 位置和尺寸
    property real componentX: 0
    property real componentY: 0
    property real componentWidth: 120
    property real componentHeight: 80
    
    // 状态属性
    property bool selected: false
    property bool draggable: true
    property bool resizable: true
    
    // 数据绑定
    property string boundTag: ""
    property var currentValue: null
    
    // 样式属性
    property color backgroundColor: "#f0f0f0"
    property color borderColor: selected ? "#007acc" : "#cccccc"
    property int borderWidth: selected ? 2 : 1
    property int borderRadius: 4
    
    // ==================== 信号定义 ====================
    signal moved(real newX, real newY)
    signal resized(real newWidth, real newHeight)
    signal selectedChanged(bool isSelected)
    signal doubleClicked()
    
    // ==================== 内部属性 ====================
    property bool isDragging: false
    property point dragStartPos
    property point mousePressPos
    
    // ==================== 组件初始化 ====================
    Component.onCompleted: {
        x = componentX
        y = componentY
        width = componentWidth
        height = componentHeight
        console.log("工业组件初始化:", componentId, componentName)
    }
    
    // ==================== 公共方法 ====================
    
    /**
     * @brief 移动组件到指定位置
     */
    function moveTo(newX, newY) {
        x = newX
        y = newY
        componentX = newX
        componentY = newY
        moved(newX, newY)
    }
    
    /**
     * @brief 调整组件尺寸
     */
    function resize(newWidth, newHeight) {
        width = Math.max(50, newWidth)
        height = Math.max(30, newHeight)
        componentWidth = width
        componentHeight = height
        resized(width, height)
    }
    
    /**
     * @brief 设置选中状态
     */
    function setSelected(isSelected) {
        if (selected !== isSelected) {
            selected = isSelected
            selectedChanged(isSelected)
        }
    }
    
    /**
     * @brief 获取组件配置信息
     */
    function getConfig() {
        return {
            "id": componentId,
            "name": componentName,
            "type": componentType,
            "x": x,
            "y": y,
            "width": width,
            "height": height,
            "boundTag": boundTag,
            "backgroundColor": backgroundColor
        }
    }
    
    /**
     * @brief 应用配置信息
     */
    function applyConfig(config) {
        if (config.id) componentId = config.id
        if (config.name) componentName = config.name
        if (config.x !== undefined) moveTo(config.x, y)
        if (config.y !== undefined) moveTo(x, config.y)
        if (config.width !== undefined) resize(config.width, height)
        if (config.height !== undefined) resize(width, config.height)
        if (config.boundTag) boundTag = config.boundTag
        if (config.backgroundColor) backgroundColor = config.backgroundColor
    }
    
    // ==================== 视觉表现 ====================
    Rectangle {
        anchors.fill: parent
        color: backgroundColor
        border.color: borderColor
        border.width: borderWidth
        radius: borderRadius
        
        // 选中时的视觉反馈
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "#007acc"
            border.width: selected ? 1 : 0
            radius: borderRadius
            opacity: selected ? 0.3 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
        
        // 组件标题
        Text {
            id: titleLabel
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 4
            text: componentName
            font.pixelSize: 10
            color: "#333333"
            elide: Text.ElideRight
            width: parent.width - 8
        }
        
        // 当前值显示
        Text {
            anchors.centerIn: parent
            text: currentValue !== null ? currentValue.toString() : "--"
            font.pixelSize: 14
            font.bold: true
            color: "#666666"
        }
        
        // 尺寸调整手柄（选中时显示）
        Rectangle {
            width: 8
            height: 8
            color: "#007acc"
            visible: selected && resizable
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            
            MouseArea {
                anchors.fill: parent
                anchors.margins: -2
                cursorShape: Qt.SizeFDiagCursor
                
                onPressed: {
                    mouse.accepted = true
                }
                
                onPositionChanged: {
                    if (pressed) {
                        var newWidth = Math.max(50, draggableComponent.width + mouse.x)
                        var newHeight = Math.max(30, draggableComponent.height + mouse.y)
                        resize(newWidth, newHeight)
                    }
                }
            }
        }
    }
    
    // ==================== 交互处理 ====================
    MouseArea {
        anchors.fill: parent
        drag.target: draggableComponent
        drag.axis: Drag.XAndYAxis
        drag.minimumX: 0
        drag.minimumY: 0
        drag.smoothed: false
        
        onPressed: {
            mousePressPos = Qt.point(mouse.x, mouse.y)
            if (draggable) {
                isDragging = true
                dragStartPos = Qt.point(draggableComponent.x, draggableComponent.y)
            }
        }
        
        onReleased: {
            if (isDragging) {
                isDragging = false
                // 更新位置属性
                componentX = draggableComponent.x
                componentY = draggableComponent.y
                moved(componentX, componentY)
            }
        }
        
        onDoubleClicked: {
            doubleClicked()
        }
        
        onClicked: {
            // 点击选择组件
            setSelected(true)
        }
        
        // 拖拽时的视觉反馈
        drag.onActiveChanged: {
            if (drag.active) {
                // 拖拽开始时的处理
                z = 1000  // 置顶显示
            } else {
                // 拖拽结束时的处理
                z = 1  // 恢复层级
            }
        }
    }
    
    // ==================== 数据绑定处理 ====================
    Connections {
        target: typeof tagManager !== 'undefined' ? tagManager : null
        enabled: boundTag && tagManager
        
        function onTagValueChanged(tagName, newValue) {
            if (tagName === boundTag) {
                currentValue = newValue
            }
        }
    }
    
    // ==================== 动画效果 ====================
    Behavior on x {
        enabled: !isDragging
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
    
    Behavior on y {
        enabled: !isDragging
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
}