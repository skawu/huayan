import QtQuick 2.15

/**
 * @brief 文本标签组件
 * 
 * 用于显示标签文本和对应的值，支持与数据标签关联。
 * 可用于显示设备状态、参数值等信息。
 * 
 * @property labelText 标签文本，默认为"Label"
 * @property valueText 显示的值文本，默认为空字符串
 * @property tagName 关联的数据标签名称，默认为空字符串
 * @property tagValue 关联的数据标签值，默认为null
 * @property showValue 是否显示值文本，默认为true
 * @property fontSize 字体大小，默认为14
 * @property showBackground 是否显示背景，默认为false
 * 
 * @signal 无自定义信号
 * 
 * @example 基本用法
 * ```qml
 * TextLabel {
 *     labelText: "温度"
 *     valueText: "25.5°C"
 *     width: 150
 *     height: 30
 * }
 * ```
 * 
 * @example 关联数据标签
 * ```qml
 * TextLabel {
 *     labelText: "压力"
 *     tagName: "Tank_Pressure"
 *     showBackground: true
 *     width: 180
 *     height: 35
 * }
 * ```
 */
Rectangle {
    id: textLabel
    width: 200
    height: 40
    color: "transparent"
    border.color: "#666"
    border.width: 1
    radius: 4

    /**
     * @brief 标签文本
     * 
     * 显示在左侧的标签文本，用于标识显示的值。
     */
    property string labelText: "Label"
    
    /**
     * @brief 值文本
     * 
     * 显示在右侧的实际值文本，可通过tagValue自动更新。
     */
    property string valueText: ""
    
    /**
     * @brief 数据标签名称
     * 
     * 关联的数据标签名称，用于从标签系统获取数据。
     */
    property string tagName: ""
    
    /**
     * @brief 数据标签值
     * 
     * 关联的数据标签值，当值变化时会自动更新valueText。
     */
    property var tagValue: null
    
    /**
     * @brief 是否显示值文本
     * 
     * 控制是否显示右侧的值文本部分。
     */
    property bool showValue: true
    
    /**
     * @brief 字体大小
     * 
     * 标签和值文本的字体大小。
     */
    property int fontSize: 14

    /**
     * @brief 当标签值变化时更新显示文本
     * 
     * 当tagValue属性变化且tagName不为空时，自动更新valueText。
     */
    onTagValueChanged: {
        if (tagName !== "") {
            valueText = String(tagValue);
        }
    }

    // Main layout
    Row {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // Label text
        Text {
            text: labelText
            font.pixelSize: fontSize
            font.bold: true
            color: "#333"
            verticalAlignment: Text.AlignVCenter
        }

        // Value text (if enabled)
        Text {
            visible: showValue
            text: valueText
            font.pixelSize: fontSize
            color: "#2196F3"
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            // Add ellipsis if text is too long
            elide: Text.ElideRight
            maximumWidth: parent.width - 80
        }
    }

    /**
     * @brief 是否显示背景
     * 
     * 控制是否显示浅灰色背景以提高可见性。
     */
    property bool showBackground: false
    
    /**
     * @brief 当背景显示状态变化时更新颜色
     * 
     * 根据showBackground属性的值切换背景颜色。
     */
    onShowBackgroundChanged: {
        color = showBackground ? "#F5F5F5" : "transparent";
    }
}
