import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Huayan3D 1.0

Window {
    width: 1280
    height: 720
    visible: true
    title: "Huayan 3D 工业可视化"
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        padding: 10
        
        // 标题
        Label {
            text: "Huayan 3D 工业可视化演示"
            font.bold: true
            font.pixelSize: 24
            Layout.alignment: Qt.AlignHCenter
        }
        
        // 3D视图
        Huayan3DView {
            id: huayan3DView
            width: parent.width
            height: parent.height * 0.7
            modelUrl: "qrc:/assets/models/test_model.gltf"
            showFPS: true
            simplificationFactor: 0.5
            maxTextureSize: 1024
        }
        
        // 控制面板
        RowLayout {
            width: parent.width
            spacing: 10
            
            Button {
                text: "加载测试模型"
                onClicked: {
                    huayan3DView.loadModel("qrc:/assets/models/test_model.gltf");
                }
            }
            
            Button {
                text: "绑定测试点位"
                onClicked: {
                    // 绑定测试点位
                    huayan3DView.bindPointToNode("pump1", "pump1");
                    huayan3DView.bindPointToNode("valve1", "valve1");
                    huayan3DView.bindPointToNode("motor1", "motor1");
                }
            }
            
            Button {
                text: "更新点位状态"
                onClicked: {
                    // 模拟更新点位状态
                    var points = {
                        "pump1": Math.random(),
                        "valve1": Math.random(),
                        "motor1": Math.random()
                    };
                    huayan3DView.updatePoints(points);
                }
            }
            
            Button {
                text: "优化模型"
                onClicked: {
                    if (huayan3DView.modelEntity) {
                        var modelLoader = huayan3DView.modelLoader;
                        modelLoader.optimizeModel(huayan3DView.modelEntity, 0.5);
                        modelLoader.compressTextures(huayan3DView.modelEntity, 512);
                    }
                }
            }
        }
        
        // 状态信息
        RowLayout {
            width: parent.width
            spacing: 20
            
            Label {
                text: "绑定点位数量: " + huayan3DView.pointBinder.boundPointCount
            }
            
            Label {
                text: "FPS: " + Math.round(huayan3DView.fps)
            }
            
            Label {
                text: "模型加载状态: " + (huayan3DView.isModelLoaded ? "已加载" : "未加载")
            }
        }
    }
    
    // 模拟点位数据更新
    Timer {
        id: simulationTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            // 随机更新点位值
            var points = {};
            for (var i = 1; i <= 10; i++) {
                points["device" + i] = Math.random();
            }
            // 批量更新点位
            huayan3DView.updatePoints(points);
        }
    }
}
