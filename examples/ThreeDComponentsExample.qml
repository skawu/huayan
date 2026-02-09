import QtQuick 2.15
import QtQuick.Controls 2.15
import ThreeDComponents 1.0

Rectangle {
    width: 800
    height: 600
    color: "#f0f0f0"
    
    title: "3D组件示例"
    
    Column {
        anchors.centerIn: parent
        spacing: 20
        
        Text {
            text: "3D组件示例"
            font.pointSize: 24
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        // 3D场景示例
        Row {
            spacing: 20
            
            Text {
                text: "3D场景示例:"
                font.pointSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }
            
            ThreeDScene {
                width: 400
                height: 300
                
                // 添加一个简单的立方体
                Component.onCompleted: {
                    addCube();
                }
            }
        }
        
        // 模型加载器示例
        Row {
            spacing: 20
            
            Text {
                text: "模型加载器示例:"
                font.pointSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }
            
            ModelLoader {
                width: 400
                height: 300
                modelPath: "path/to/model.glb"
                
                // 模型加载完成后的回调
                onModelLoaded: {
                    console.log("模型加载完成");
                }
            }
        }
        
        // 相机控制器示例
        Row {
            spacing: 20
            
            Text {
                text: "相机控制器示例:"
                font.pointSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }
            
            CameraController {
                width: 400
                height: 300
                
                // 相机初始位置
                initialPosition: Qt.vector3d(0, 0, 10)
                
                // 目标点
                targetPosition: Qt.vector3d(0, 0, 0)
            }
        }
    }
}
