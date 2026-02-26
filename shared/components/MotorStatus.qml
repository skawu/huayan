import QtQuick
import QtQuick.Controls

// 电机状态指示器组件
Rectangle {
    id: motorStatus
    width: 140
    height: 90
    color: "#fff"
    border.color: "#ddd"
    border.width: 2
    radius: 8
    
    property string tagName: "motor_status"
    property string currentValue: "停止"
    property var statusOptions: ["运行", "停止", "故障"]
    
    // 组件标题
    Text {
        id: title
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10
        text: "⚡ 电机状态"
        font.pixelSize: 12
        color: "#666"
    }
    
    // 状态指示灯
    Rectangle {
        id: statusLight
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.margins: 10
        width: 20
        height: 20
        radius: 10
        color: getStatusColor(currentValue)
        
        // 闪烁效果（故障状态）
        SequentialAnimation on opacity {
            running: currentValue === "故障"
            loops: Animation.Infinite
            NumberAnimation { from: 1.0; to: 0.3; duration: 500 }
            NumberAnimation { from: 0.3; to: 1.0; duration: 500 }
        }
    }
    
    // 状态文本
    Text {
        anchors.left: statusLight.right
        anchors.verticalCenter: statusLight.verticalCenter
        anchors.leftMargin: 10
        text: currentValue
        font.pixelSize: 16
        font.bold: true
        color: getStatusColor(currentValue)
    }
    
    // 控制按钮
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 10
        spacing: 8
        
        Button {
            text: "启动"
            width: 50
            height: 25
            enabled: currentValue !== "运行"
            
            background: Rectangle {
                color: enabled ? "#2ecc71" : "#bdc3c7"
                radius: 3
            }
            
            onClicked: {
                currentValue = "运行"
            }
        }
        
        Button {
            text: "停止"
            width: 50
            height: 25
            enabled: currentValue === "运行"
            
            background: Rectangle {
                color: enabled ? "#e74c3c" : "#bdc3c7"
                radius: 3
            }
            
            onClicked: {
                currentValue = "停止"
            }
        }
    }
    
    // 获取状态颜色
    function getStatusColor(status) {
        switch(status) {
            case "运行": return "#2ecc71"
            case "停止": return "#f39c12"
            case "故障": return "#e74c3c"
            default: return "#95a5a6"
        }
    }
    
    // 模拟状态变化
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            var randomIndex = Math.floor(Math.random() * statusOptions.length)
            currentValue = statusOptions[randomIndex]
        }
    }
}