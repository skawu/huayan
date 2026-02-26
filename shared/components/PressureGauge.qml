import QtQuick
import QtQuick.Controls

// 压力仪表组件
Rectangle {
    id: pressureGauge
    width: 120
    height: 120
    color: "#fff"
    border.color: "#ddd"
    border.width: 2
    radius: 8
    
    property string tagName: "pressure"
    property double currentValue: 0.0
    property double minValue: 0.0
    property double maxValue: 20.0
    
    // 组件标题
    Text {
        id: title
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 8
        text: "⚙️ 压力"
        font.pixelSize: 11
        color: "#666"
    }
    
    // 圆形仪表背景
    Rectangle {
        id: gaugeBackground
        anchors.centerIn: parent
        width: 80
        height: 80
        radius: 40
        color: "#f8f9fa"
        border.color: "#dee2e6"
        border.width: 2
        
        // 刻度线
        Repeater {
            model: 12
            Rectangle {
                x: gaugeBackground.width/2 - 1
                y: 5
                width: 2
                height: 10
                color: "#666"
                transform: Rotation {
                    origin.x: 1
                    origin.y: 35
                    angle: index * 30
                }
            }
        }
        
        // 指针
        Rectangle {
            id: needle
            x: gaugeBackground.width/2 - 1
            y: gaugeBackground.height/2 - 30
            width: 2
            height: 30
            color: "#e74c3c"
            transform: Rotation {
                origin.x: 1
                origin.y: 30
                angle: (currentValue / maxValue) * 270 - 135  // 270度量程
            }
        }
        
        // 中心圆点
        Rectangle {
            anchors.centerIn: parent
            width: 8
            height: 8
            radius: 4
            color: "#333"
        }
    }
    
    // 数值显示
    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 8
        text: currentValue.toFixed(2) + "MPa"
        font.pixelSize: 12
        font.bold: true
        color: "#333"
    }
    
    // 模拟数据更新
    Timer {
        interval: 1200
        running: true
        repeat: true
        onTriggered: {
            currentValue = 5 + Math.random() * 10
        }
    }
}