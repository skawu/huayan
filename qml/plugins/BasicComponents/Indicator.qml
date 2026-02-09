import QtQuick 2.15
import QtQuick.Controls 2.15

/**
 * @file Indicator.qml
 * @brief 指示器组件
 * 
 * 一个圆形的状态指示器，用于显示布尔值状态，支持标签绑定和动画效果
 */

/**
 * @qmltype Indicator
 * @brief 状态指示器组件
 * 
 * 圆形的状态指示器，用于显示开/关状态，支持颜色自定义、标签绑定和动画效果
 * 
 * @qmlproperty bool active - 是否激活，默认为false
 * @qmlproperty color activeColor - 激活状态的颜色，默认为绿色("#4CAF50")
 * @qmlproperty color inactiveColor - 非激活状态的颜色，默认为深灰色("#333")
 * @qmlproperty string tagName - 绑定的标签名称，默认为空
 * @qmlproperty var tagValue - 绑定的标签值，默认为null
 * 
 * @qmlsignal activeChanged() - 激活状态变化时触发
 * @qmlsignal tagValueChanged() - 标签值变化时触发
 * 
 * @example
 * Indicator {
 *     width: 50
 *     height: 50
 *     active: true
 *     activeColor: "#4CAF50"
 *     inactiveColor: "#333"
 *     tagName: "Motor1_Running"
 * }
 */

Rectangle {
    id: indicator
    width: 50
    height: 50
    radius: width / 2
    color: "#333"
    border.width: 2
    border.color: "#666"

    /**
     * @brief 是否激活
     * 控制指示器的激活状态，true为激活，false为非激活
     */
    property bool active: false
    
    /**
     * @brief 激活状态的颜色
     * 指示器激活时显示的颜色
     */
    property color activeColor: "#4CAF50"
    
    /**
     * @brief 非激活状态的颜色
     * 指示器非激活时显示的颜色
     */
    property color inactiveColor: "#333"
    
    /**
     * @brief 绑定的标签名称
     * 用于绑定到标签系统的标签名称
     */
    property string tagName: ""
    
    /**
     * @brief 绑定的标签值
     * 用于绑定到标签系统的标签值，会自动转换为布尔值
     */
    property var tagValue: null

    /**
     * @brief 内部激活状态
     * 跟踪实际的激活状态，避免标签值和手动设置的冲突
     */
    property bool _internalActive: active

    /**
     * @brief 激活状态变化处理
     * 当active属性变化时更新内部状态和视觉效果
     */
    onActiveChanged: {
        _internalActive = active;
        updateVisualState();
    }

    /**
     * @brief 标签值变化处理
     * 当tagValue变化时更新激活状态
     */
    onTagValueChanged: {
        if (tagName !== "") {
            active = Boolean(tagValue);
        }
    }

    /**
     * @brief 更新视觉状态
     * 根据内部激活状态更新指示器的视觉效果
     */
    function updateVisualState() {
        color = _internalActive ? activeColor : inactiveColor;
        // 添加动画效果提供视觉反馈
        scale = 0.9;
        animateScale(1.0);
    }

    /**
     * @brief 缩放动画
     * 为指示器添加缩放动画效果
     * @param targetScale 目标缩放比例
     */
    function animateScale(targetScale) {
        Qt.createQmlObject('import QtQuick 2.15; NumberAnimation { target: indicator; property: "scale"; to: ' + targetScale + '; duration: 100 }', indicator);
    }

    // 内部发光效果
    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: width / 2
        color: indicator.color
        opacity: 0.7
    }

    /**
     * @brief 组件完成初始化
     * 组件创建完成时初始化视觉状态
     */
    Component.onCompleted: {
        updateVisualState();
    }
}
