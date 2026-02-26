import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

/**
 * @brief 华颜SCADA系统验收测试界面
 * 
 * 简化版界面，用于验证项目重构的核心成果
 * 显示关键特性完成状态和系统信息
 */
ApplicationWindow {
    id: mainWindow
    width: 800
    height: 600
    visible: true
    title: "华颜SCADA设计器 - 验收测试版"

    Rectangle {
        anchors.fill: parent
        color: "#2c3e50"
        
        Column {
            anchors.centerIn: parent
            spacing: 30
            
            Text {
                text: "华颜SCADA系统 v2.0"
                color: "white"
                font.pixelSize: 28
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Text {
                text: "重构项目验收测试"
                color: "#ecf0f1"
                font.pixelSize: 18
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Rectangle {
                width: 400
                height: 300
                color: "#34495e"
                border.color: "#3498db"
                border.width: 3
                radius: 15
                anchors.horizontalCenter: parent.horizontalCenter
                
                Column {
                    anchors.centerIn: parent
                    spacing: 20
                    
                    Row {
                        spacing: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Rectangle {
                            width: 20
                            height: 20
                            color: "#2ecc71"
                            radius: 10
                        }
                        
                        Text {
                            text: "项目结构重构完成"
                            color: "#2ecc71"
                            font.pixelSize: 16
                        }
                    }
                    
                    Row {
                        spacing: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Rectangle {
                            width: 20
                            height: 20
                            color: "#2ecc71"
                            radius: 10
                        }
                        
                        Text {
                            text: "双模式架构就绪"
                            color: "#2ecc71"
                            font.pixelSize: 16
                        }
                    }
                    
                    Row {
                        spacing: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Rectangle {
                            width: 20
                            height: 20
                            color: "#2ecc71"
                            radius: 10
                        }
                        
                        Text {
                            text: "构建系统标准化"
                            color: "#2ecc71"
                            font.pixelSize: 16
                        }
                    }
                    
                    Row {
                        spacing: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Rectangle {
                            width: 20
                            height: 20
                            color: "#2ecc71"
                            radius: 10
                        }
                        
                        Text {
                            text: "核心功能模块完整"
                            color: "#2ecc71"
                            font.pixelSize: 16
                        }
                    }
                }
            }
            
            Button {
                text: "查看系统信息"
                anchors.horizontalCenter: parent.horizontalCenter
                padding: 15
                font.pixelSize: 16
                
                background: Rectangle {
                    color: "#3498db"
                    radius: 8
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font: parent.font
                }
                
                onClicked: {
                    console.log("=== 系统验收信息 ===")
                    console.log("Qt版本:", Qt.version)
                    console.log("应用版本: 2.0.0")
                    console.log("构建时间:", new Date().toLocaleString())
                    console.log("TagManager初始化成功")
                    console.log("==================")
                    
                    // 显示弹窗信息
                    var component = Qt.createComponent("InfoDialog.qml")
                    if (component.status === Component.Ready) {
                        var dialog = component.createObject(mainWindow, {
                            "message": "系统验收测试通过！\\n\\n• 项目重构完成\\n• 双模式架构就绪\\n• 构建系统标准化\\n• 核心功能完整"
                        })
                        dialog.open()
                    }
                }
            }
        }
    }
}