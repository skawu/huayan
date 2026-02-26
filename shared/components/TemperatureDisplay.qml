import QtQuick
import QtQuick.Controls

// 温度显示器组件
Rectangle {
    id: temperatureDisplay
    width: 150
    height: 100
    color: "#fff"
    border.color: "#ddd"
    border.width: 2
    radius: 8
    
    property string tagName: "temperature"
    property double currentValue: 0.0
    property double minValue: 0.0
    property double maxValue: 200.0
    
    // 组件标题
    Text {
        id: title
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10
        text: "🌡️ 温度"
        font.pixelSize: 12
        color: "#666"
    }
    
    // 温度数值显示
    Text {
        id: valueText
        anchors.centerIn: parent
        text: currentValue.toFixed(1) + "°C"
        font.pixelSize: 24
        font.bold: true
        color: getColorForValue(currentValue)
    }
    
    // 状态指示
    Rectangle {
        id: statusIndicator
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 8
        width: 12
        height: 12
        radius: 6
        color: getStatusColor(currentValue)
    }
    
    // 进度条背景
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        height: 8
        radius: 4
        color: "#eee"
        
        // 进度条
        Rectangle {
            width: parent.width * (currentValue / (maxValue - minValue))
            height: parent.height
            radius: 4
            color: getColorForValue(currentValue)
        }
    }
    
    // 获取颜色函数
    function getColorForValue(value) {
        if (value < 50) return "#3498db"  // 蓝色 - 低温
        if (value < 150) return "#2ecc71" // 绿色 - 正常
        return "#e74c3c"                  // 红色 - 高温
    }
    
    // 获取状态颜色
    function getStatusColor(value) {
        if (value < 50) return "#3498db"  // 蓝色
        if (value < 150) return "#2ecc71" // 绿色
        return "#e74c3c"                  // 红色
    }
    
    // 模拟数据更新
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            currentValue = 50 + Math.random() * 150
        }
    }
}