import QtQuick 2.15
import QtQuick.Controls 2.15

/**
 * @brief 基础工业组件 - 所有工业组件的基类
 * 
 * 提供工业组件的通用属性和行为，包括：
 * - 标签绑定机制
 * - 状态管理
 * - 样式统一
 * - 交互处理
 */
Item {
    id: baseComponent
    
    // ==================== 公共属性 ====================
    
    /** @property 组件唯一标识符 */
    property string componentId: ""
    
    /** @property 显示标签文本 */
    property string labelText: ""
    
    /** @property 绑定的数据标签名称 */
    property string boundTag: ""
    
    /** @property 组件启用状态 */
    property bool enabled: true
    
    /** @property 组件可见性 */
    property bool visible: true
    
    /** @property 组件大小 */
    property real componentWidth: 100
    property real componentHeight: 100
    
    /** @property 组件位置 */
    property real componentX: 0
    property real componentY: 0
    
    // ==================== 状态管理 ====================
    
    /** @property 当前值 */
    property var currentValue: null
    
    /** @property 连接状态 */
    property bool isConnected: false
    
    /** @property 报警状态 */
    property bool isInAlarm: false
    
    /** @property 维护模式 */
    property bool maintenanceMode: false
    
    // ==================== 样式配置 ====================
    
    /** @property 主题配置 */
    property var theme: IndustrialTheme
    
    /** @property 颜色配置 */
    property color normalColor: theme.primaryColor
    property color alarmColor: "#ff4444"
    property color maintenanceColor: "#ffbb33"
    property color disabledColor: "#cccccc"
    
    /** @property 字体配置 */
    property int fontSize: 12
    property string fontFamily: "Arial"
    
    // ==================== 交互属性 ====================
    
    /** @property 是否可选择 */
    property bool selectable: true
    
    /** @property 是否可拖拽 */
    property bool draggable: false
    
    /** @property 是否可编辑 */
    property bool editable: false
    
    /** @property 工具提示文本 */
    property string tooltip: ""
    
    // ==================== 信号定义 ====================
    
    /** @signal 组件被点击 */
    signal clicked()
    
    /** @signal 值发生变化 */
    signal valueChanged(var newValue, var oldValue)
    
    /** @signal 状态发生变化 */
    signal statusChanged(string statusType, bool newState)
    
    /** @signal 右键菜单请求 */
    signal contextMenuRequested(int x, int y)
    
    // ==================== 内部属性 ====================
    
    /** @private 当前显示颜色 */
    property color displayColor: getColorByState()
    
    /** @private 鼠标悬停状态 */
    property bool hovered: false
    
    // ==================== 组件初始化 ====================
    
    Component.onCompleted: {
        initializeComponent()
        setupBindings()
    }
    
    // ==================== 公共方法 ====================
    
    /**
     * @brief 更新组件值
     * @param {variant} newValue 新值
     */
    function updateValue(newValue) {
        if (newValue !== currentValue) {
            var oldValue = currentValue
            currentValue = newValue
            valueChanged(newValue, oldValue)
        }
    }
    
    /**
     * @brief 设置连接状态
     * @param {bool} connected 是否连接
     */
    function setConnectionStatus(connected) {
        if (connected !== isConnected) {
            isConnected = connected
            statusChanged("connection", connected)
        }
    }
    
    /**
     * @brief 设置报警状态
     * @param {bool} inAlarm 是否报警
     */
    function setAlarmStatus(inAlarm) {
        if (inAlarm !== isInAlarm) {
            isInAlarm = inAlarm
            statusChanged("alarm", inAlarm)
        }
    }
    
    /**
     * @brief 获取组件状态信息
     * @return {object} 状态对象
     */
    function getStatusInfo() {
        return {
            "id": componentId,
            "enabled": enabled,
            "visible": visible,
            "connected": isConnected,
            "inAlarm": isInAlarm,
            "maintenance": maintenanceMode,
            "value": currentValue,
            "boundTag": boundTag
        }
    }
    
    /**
     * @brief 应用配置
     * @param {object} config 配置对象
     */
    function applyConfiguration(config) {
        if (config.componentId) componentId = config.componentId
        if (config.labelText) labelText = config.labelText
        if (config.boundTag) boundTag = config.boundTag
        if (config.enabled !== undefined) enabled = config.enabled
        if (config.width) componentWidth = config.width
        if (config.height) componentHeight = config.height
        if (config.x) componentX = config.x
        if (config.y) componentY = config.y
        // 应用更多配置...
    }
    
    // ==================== 内部方法 ====================
    
    /**
     * @private 初始化组件
     */
    function initializeComponent() {
        // 设置组件尺寸
        width = componentWidth
        height = componentHeight
        x = componentX
        y = componentY
        
        // 初始化默认值
        if (currentValue === null) {
            currentValue = getDefaultInitialValue()
        }
        
        console.log("BaseComponent initialized:", componentId)
    }
    
    /**
     * @private 设置数据绑定
     */
    function setupBindings() {
        if (boundTag) {
            // 这里应该连接到标签管理器
            // tagManager.tagValueChanged.connect(onTagValueChanged)
        }
    }
    
    /**
     * @private 根据状态获取颜色
     * @return {color} 显示颜色
     */
    function getColorByState() {
        if (!enabled) return disabledColor
        if (maintenanceMode) return maintenanceColor
        if (isInAlarm) return alarmColor
        return normalColor
    }
    
    /**
     * @private 获取默认初始值
     * @return {variant} 默认值
     */
    function getDefaultInitialValue() {
        // 子类应该重写此方法
        return null
    }
    
    /**
     * @private 标签值变化处理
     * @param {string} tagName 标签名称
     * @param {variant} newValue 新值
     */
    function onTagValueChanged(tagName, newValue) {
        if (tagName === boundTag) {
            updateValue(newValue)
        }
    }
    
    // ==================== 交互处理 ====================
    
    MouseArea {
        anchors.fill: parent
        enabled: selectable || draggable
        hoverEnabled: true
        cursorShape: selectable ? Qt.PointingHandCursor : Qt.ArrowCursor
        
        onEntered: {
            hovered = true
            if (tooltip && !maintenanceMode) {
                // 显示工具提示
                showTooltip(tooltip)
            }
        }
        
        onExited: {
            hovered = false
            if (tooltip) {
                hideTooltip()
            }
        }
        
        onClicked: {
            if (selectable && enabled) {
                clicked()
            }
        }
        
        onRightClicked: {
            if (enabled) {
                contextMenuRequested(mouseX, mouseY)
            }
        }
        
        onPressed: {
            if (draggable && enabled) {
                startDrag()
            }
        }
    }
    
    // ==================== 状态指示 ====================
    
    // 连接状态指示器
    Rectangle {
        id: connectionIndicator
        width: 8
        height: 8
        radius: 4
        color: isConnected ? "#4CAF50" : "#F44336"
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 2
        visible: showStatusIndicators
    }
    
    // 报警状态指示器
    Rectangle {
        id: alarmIndicator
        width: 8
        height: 8
        radius: 4
        color: isInAlarm ? "#FF5722" : "transparent"
        border.color: isInAlarm ? "white" : "transparent"
        border.width: 1
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 2
        visible: showStatusIndicators && isInAlarm
    }
    
    // 维护模式遮罩
    Rectangle {
        anchors.fill: parent
        color: "#44FFBB33"
        visible: maintenanceMode && enabled
        opacity: 0.7
    }
    
    // 禁用状态遮罩
    Rectangle {
        anchors.fill: parent
        color: "#88CCCCCC"
        visible: !enabled
    }
    
    // ==================== 可配置属性 ====================
    
    /** @property 是否显示状态指示器 */
    property bool showStatusIndicators: true
    
    /** @property 动画持续时间 */
    property int animationDuration: 200
    
    /** @property 是否启用动画效果 */
    property bool animationsEnabled: true
    
    // ==================== 动画效果 ====================
    
    Behavior on displayColor {
        enabled: animationsEnabled
        ColorAnimation {
            duration: animationDuration
            easing.type: Easing.InOutQuad
        }
    }
    
    Behavior on opacity {
        enabled: animationsEnabled
        NumberAnimation {
            duration: animationDuration
            easing.type: Easing.InOutQuad
        }
    }
    
    // ==================== 工具方法 ====================
    
    /**
     * @private 显示工具提示
     */
    function showTooltip(text) {
        // 实现工具提示显示逻辑
        console.log("Tooltip:", text)
    }
    
    /**
     * @private 隐藏工具提示
     */
    function hideTooltip() {
        // 实现工具提示隐藏逻辑
    }
    
    /**
     * @private 开始拖拽
     */
    function startDrag() {
        // 实现拖拽逻辑
        console.log("Drag started for:", componentId)
    }
}