import QtQuick 2.15
import QtQuick.Controls 2.15
import HYBasicComponents 1.0

Rectangle {
    width: 800
    height: 600
    color: "#f0f0f0"
    
    Column {
        anchors.centerIn: parent
        spacing: 20
        
        Text {
            text: "基础组件示例"
            font.pointSize: 24
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        // 按钮示例
        Row {
            spacing: 20
            
            Text {
                text: "按钮示例:"
                font.pointSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }
            
            HYPushButton {
                text: "普通按钮"
                width: 120
                height: 40
                onClicked: console.log("普通按钮被点击")
            }
            
            HYPushButton {
                text: "禁用按钮"
                width: 120
                height: 40
                enabled: false
            }
        }
        
        // 指示器示例
        Row {
            spacing: 20
            
            Text {
                text: "指示器示例:"
                font.pointSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }
            
            HYIndicator {
                width: 50
                height: 50
                value: true
                color: "#4CAF50"
            }
            
            HYIndicator {
                width: 50
                height: 50
                value: false
                color: "#F44336"
            }
        }
        
        // 文本标签示例
        Row {
            spacing: 20
            
            Text {
                text: "文本标签示例:"
                font.pointSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }
            
            HYTextLabel {
                text: "静态文本"
                width: 120
                height: 40
                color: "#333333"
            }
        }
    }
}
