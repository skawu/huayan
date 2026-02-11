import QtQuick 2.15
import QtQuick.Controls 2.15
import HYIndustrialComponents 1.0

Rectangle {
    width: 800
    height: 600
    color: "#f0f0f0"
    
    Column {
        anchors.centerIn: parent
        spacing: 20
        
        Text {
            text: "工业组件示例"
            font.pointSize: 24
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        // 阀门示例
        Row {
            spacing: 20
            
            Text {
                text: "阀门示例:"
                font.pointSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }
            
            HYValve {
                width: 100
                height: 100
                open: true
            }
            
            HYValve {
                width: 100
                height: 100
                open: false
            }
        }
        
        // 储罐示例
        Row {
            spacing: 20
            
            Text {
                text: "储罐示例:"
                font.pointSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }
            
            HYTank {
                width: 100
                height: 150
                level: 75
            }
        }
        
        // 电机示例
        Row {
            spacing: 20
            
            Text {
                text: "电机示例:"
                font.pointSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }
            
            HYMotor {
                width: 100
                height: 100
                running: true
            }
            
            HYMotor {
                width: 100
                height: 100
                running: false
            }
        }
        
        // 仪表盘示例
        Row {
            spacing: 20
            
            Text {
                text: "仪表盘示例:"
                font.pointSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }
            
            HYGauge {
                width: 150
                height: 150
                value: 65
                minValue: 0
                maxValue: 100
                unit: "%"
            }
        }
        
        // 工业按钮示例
        Row {
            spacing: 20
            
            Text {
                text: "工业按钮示例:"
                font.pointSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }
            
            HYIndustrialButton {
                width: 120
                height: 60
                text: "启动"
                state: "normal"
                onClicked: console.log("启动按钮被点击")
            }
            
            HYIndustrialButton {
                width: 120
                height: 60
                text: "停止"
                state: "pressed"
                onClicked: console.log("停止按钮被点击")
            }
        }
        
        // 工业指示器示例
        Row {
            spacing: 20
            
            Text {
                text: "工业指示器示例:"
                font.pointSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }
            
            HYIndustrialIndicator {
                width: 80
                height: 80
                state: "normal"
                text: "运行"
            }
            
            HYIndustrialIndicator {
                width: 80
                height: 80
                state: "warning"
                text: "警告"
            }
            
            HYIndustrialIndicator {
                width: 80
                height: 80
                state: "error"
                text: "错误"
            }
        }
    }
}
