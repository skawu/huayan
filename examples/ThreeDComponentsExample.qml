import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import HYThreeDComponents 1.0

/**
 * @brief 3D组件示例
 * 
 * 展示Huayan SCADA系统中3D组件的使用，包括：
 * 1. 3D场景创建与管理
 * 2. 3D模型加载与交互
 * 3. 相机控制与视角调整
 * 4. 设备参数绑定
 * 5. 3D模型旋转/缩放交互
 */
Rectangle {
    width: 1000
    height: 700
    color: "#f0f0f0"
    
    // 设备参数
    property real rotationSpeed: 0.5
    property real modelScale: 1.0
    property bool autoRotate: true
    property real deviceTemperature: 25.5
    property real devicePressure: 3.5
    property bool deviceRunning: true
    
    // 3D模型状态
    property real modelRotationX: 0
    property real modelRotationY: 0
    property real modelRotationZ: 0
    property real modelScaleFactor: 1.0
    
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        Text {
            text: "Huayan 3D组件示例"
            font.pointSize: 24
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Row {
            spacing: 20
            
            // 3D场景区域
            Column {
                spacing: 10
                
                Text {
                    text: "3D场景示例"
                    font.pointSize: 16
                    font.bold: true
                }
                
                HYThreeDScene {
                    id: hyThreeDScene
                    width: 500
                    height: 400
                    
                    // 添加一个简单的立方体
                    Component.onCompleted: {
                        addCube();
                    }
                }
            }
            
            // 控制面板
            Column {
                width: 400
                spacing: 15
                
                Text {
                    text: "控制面板"
                    font.pointSize: 16
                    font.bold: true
                }
                
                // 模型交互控制
                GroupBox {
                    title: "模型交互控制"
                    width: parent.width
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        
                        Row {
                            spacing: 10
                            
                            Text {
                                text: "旋转速度:"
                                width: 100
                            }
                            
                            Slider {
                                id: rotationSpeedSlider
                                from: 0
                                to: 2
                                value: rotationSpeed
                                onValueChanged: {
                                    rotationSpeed = value
                                }
                            }
                            
                            Text {
                                text: rotationSpeed.toFixed(1)
                                width: 40
                            }
                        }
                        
                        Row {
                            spacing: 10
                            
                            Text {
                                text: "模型缩放:"
                                width: 100
                            }
                            
                            Slider {
                                id: scaleSlider
                                from: 0.1
                                to: 2
                                value: modelScale
                                onValueChanged: {
                                    modelScale = value
                                    modelScaleFactor = value
                                }
                            }
                            
                            Text {
                                text: modelScale.toFixed(1)
                                width: 40
                            }
                        }
                        
                        Row {
                            spacing: 10
                            
                            Text {
                                text: "自动旋转:"
                                width: 100
                            }
                            
                            Switch {
                                checked: autoRotate
                                onCheckedChanged: {
                                    autoRotate = checked
                                }
                            }
                        }
                    }
                }
                
                // 设备参数
                GroupBox {
                    title: "设备参数"
                    width: parent.width
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        
                        Row {
                            spacing: 10
                            
                            Text {
                                text: "温度:"
                                width: 100
                            }
                            
                            Text {
                                text: deviceTemperature.toFixed(1) + " °C"
                                font.bold: true
                                color: deviceTemperature > 30 ? "#F44336" : "#333333"
                            }
                        }
                        
                        Row {
                            spacing: 10
                            
                            Text {
                                text: "压力:"
                                width: 100
                            }
                            
                            Text {
                                text: devicePressure.toFixed(1) + " bar"
                                font.bold: true
                                color: devicePressure > 5 ? "#F44336" : "#333333"
                            }
                        }
                        
                        Row {
                            spacing: 10
                            
                            Text {
                                text: "设备状态:"
                                width: 100
                            }
                            
                            Text {
                                text: deviceRunning ? "运行中" : "停止"
                                font.bold: true
                                color: deviceRunning ? "#4CAF50" : "#F44336"
                            }
                        }
                    }
                }
                
                // 控制按钮
                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Button {
                        text: "重置视角"
                        onClicked: {
                            hyThreeDScene.resetView();
                        }
                        background: Rectangle {
                            color: "#2196F3"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font.pointSize: 12
                            font.bold: true
                        }
                    }
                    
                    Button {
                        text: "加载模型"
                        onClicked: {
                            // 这里可以添加模型加载逻辑
                            console.log("加载模型");
                        }
                        background: Rectangle {
                            color: "#4CAF50"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font.pointSize: 12
                            font.bold: true
                        }
                    }
                }
            }
        }
        
        // 模型加载器示例
        GroupBox {
            title: "模型加载器示例"
            width: parent.width
            
            Row {
                spacing: 20
                anchors.fill: parent
                anchors.margins: 10
                
                Text {
                    text: "3D模型加载与设备参数绑定:"
                    font.pointSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                HYModelLoader {
                    id: hyModelLoader
                    width: 600
                    height: 300
                    modelPath: "path/to/model.glb"
                    
                    // 模型加载完成后的回调
                    onModelLoaded: {
                        console.log("模型加载完成");
                    }
                    
                    // 模型旋转/缩放交互
                    MouseArea {
                        anchors.fill: parent
                        drag {
                            enabled: true
                            axis: Drag.XAndY
                        }
                        
                        onDragUpdated: {
                            modelRotationY += drag.deltaX * 0.01
                            modelRotationX += drag.deltaY * 0.01
                        }
                    }
                }
            }
        }
    }
    
    // 模型自动旋转
    Timer {
        interval: 50
        running: autoRotate
        repeat: true
        
        onTriggered: {
            modelRotationY += rotationSpeed * 0.01
        }
    }
    
    // 设备参数模拟更新
    Timer {
        interval: 2000
        running: true
        repeat: true
        
        onTriggered: {
            // 模拟温度变化
            deviceTemperature = Math.max(20, Math.min(40, deviceTemperature + (Math.random() * 2 - 1)))
            
            // 模拟压力变化
            devicePressure = Math.max(1, Math.min(8, devicePressure + (Math.random() * 0.4 - 0.2)))
            
            // 随机模拟设备状态变化
            if (Math.random() > 0.98) {
                deviceRunning = !deviceRunning
            }
        }
    }
}
