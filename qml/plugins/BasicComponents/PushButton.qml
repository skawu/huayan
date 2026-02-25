import QtQuick 2.15

/**
 * @file PushButton.qml
 * @brief 按钮组件
 * 
 * 一个可定制的按钮组件，支持普通模式和切换模式，支持标签绑定
 */

/**
 * @qmltype PushButton
 * @brief 按钮组件
 * 
 * 可定制的按钮组件，支持普通点击模式和切换模式，支持标签绑定和自定义样式
 * 
 * @qmlproperty string text - 按钮文本，默认为"Button"
 * @qmlproperty string tagName - 绑定的标签名称，默认为空
 * @qmlproperty var tagValue - 绑定的标签值，默认为null
 * @qmlproperty bool toggleMode - 是否为切换模式，默认为false
 * @qmlproperty bool checked - 切换模式下的选中状态，默认为false
 * 
 * @qmlsignal buttonClicked(var value) - 按钮点击时触发，参数为按钮状态值
 * 
 * @example
 * // 普通按钮
 * PushButton {
 *     width: 120
 *     height: 40
 *     text: "Click Me"
 *     onClicked: console.log("Button clicked")
 * }
 * 
 * // 切换按钮
 * PushButton {
 *     width: 120
 *     height: 40
 *     text: "Toggle"
 *     toggleMode: true
 *     checked: false
 *     tagName: "Motor1_Running"
 *     onButtonClicked: function(value) {
 *         console.log("Button toggled:", value)
 *     }
 * }
 */

Button {
    id: pushButton
    width: 120
    height: 40
    text: "Button"
    font.pixelSize: 14
    font.bold: true

    /**
     * @brief 绑定的标签名称
     * 用于绑定到标签系统的标签名称
     */
    property string tagName: ""
    
    /**
     * @brief 绑定的标签值
     * 用于绑定到标签系统的标签值
     */
    property var tagValue: null
    
    /**
     * @brief 是否为切换模式
     * true为切换模式，点击会切换状态；false为普通模式，点击只触发一次
     */
    property bool toggleMode: false
    
    /**
     * @brief 切换模式下的选中状态
     * 只在toggleMode为true时有效
     */
    property bool checked: false

    /**
     * @brief 标签值变化处理
     * 当tagValue变化时更新按钮状态
     */
    onTagValueChanged: {
        if (tagName !== "") {
            if (toggleMode) {
                checked = Boolean(tagValue);
            }
        }
    }

    /**
     * @brief 按钮点击处理
     * 处理按钮点击事件，根据模式触发不同的行为
     */
    onClicked: {
        if (toggleMode) {
            checked = !checked;
            // 触发标签值变化信号
            if (tagName !== "") {
                buttonClicked(checked);
            }
        } else {
            // 触发按钮点击信号
            buttonClicked(true);
        }
    }

    /**
     * @brief 按钮背景样式
     * 定义按钮的背景样式，根据按钮状态显示不同颜色
     */
    background: Rectangle {
        color: pushButton.down ? "#2196F3" : pushButton.checked ? "#1976D2" : "#2196F3"
        border.color: "#1976D2"
        border.width: 1
        radius: 4
    }

    /**
     * @brief 按钮内容
     * 定义按钮的文本显示样式
     */
    contentItem: Text {
        text: pushButton.text
        font: pushButton.font
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    /**
     * @brief 按钮点击信号
     * 按钮点击时触发，参数为按钮状态值
     * @param value 按钮状态值，普通模式下为true，切换模式下为切换后的状态
     */
    signal buttonClicked(var value)
}
