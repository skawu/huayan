import QtQuick 2.15
import QtQuick3D 1.15
import QtQuick3D.Extras 1.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Huayan3D 1.0

Item {
    id: root
    
    // 可自定义属性
    property int width: 800
    property int height: 600
    property string modelUrl: ""
    property bool showFPS: true
    property real simplificationFactor: 0.5
    property int maxTextureSize: 1024
    
    // 内部属性
    property Qt3DCore::QEntity modelEntity: null
    property bool isModelLoaded: false
    property string selectedDevice: ""
    property real fps: 0
    
    // 组件
    Scene3D {
        id: scene3D
        anchors.fill: parent
        focus: true
        aspects: ["input", "logic", "render"]
        
        Entity {
            id: rootEntity
            
            // 相机
            Camera {
                id: camera
                projectionType: CameraLens.PerspectiveProjection
                fieldOfView: 45
                nearPlane : 0.1
                farPlane : 1000.0
                position: Qt.vector3d(0, 5, 10)
                upVector: Qt.vector3d(0, 1, 0)
                viewCenter: Qt.vector3d(0, 0, 0)
            }
            
            // 相机控制器
            OrbitCameraController {
                id: cameraController
                camera: camera
                linearSpeed: 50.0
                lookSpeed: 180.0
                zoomLimit: Qt.vector2d(0.1, 1000.0)
            }
            
            // 方向光
            DirectionalLight {
                id: directionalLight
                color: Qt.rgba(1, 1, 1, 1)
                intensity: 1
                worldDirection: Qt.vector3d(0, -1, 0)
            }
            
            // 环境光
            AmbientLight {
                id: ambientLight
                color: Qt.rgba(0.5, 0.5, 0.5, 1)
                intensity: 0.5
            }
            
            // 模型容器
            Entity {
                id: modelContainer
            }
            
            // 光线投射器（用于设备选择）
            RayCaster {
                id: rayCaster
                camera: camera
                runMode: RayCaster.Continuous
                onHitChanged: {
                    if (hits.length > 0) {
                        // 处理点击事件
                        handleRayCastHit(hits[0]);
                    }
                }
            }
        }
    }
    
    // 设备信息弹窗
    Dialog {
        id: deviceDialog
        title: "设备参数"
        width: 400
        height: 300
        modal: true
        visible: false
        
        ColumnLayout {
            anchors.fill: parent
            padding: 20
            spacing: 10
            
            Label {
                id: deviceNameLabel
                text: "设备: " + selectedDevice
                font.bold: true
            }
            
            Label {
                id: deviceStatusLabel
                text: "状态: 正常"
            }
            
            Label {
                id: deviceValueLabel
                text: "值: 0.0"
            }
            
            Rectangle {
                id: statusIndicator
                width: 20
                height: 20
                radius: 10
                color: "green"
                Layout.alignment: Qt.AlignLeft
            }
        }
        
        Button {
            text: "关闭"
            onClicked: deviceDialog.visible = false
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 20
        }
    }
    
    // FPS显示
    Text {
        id: fpsText
        visible: showFPS
        text: "FPS: " + Math.round(fps)
        color: "white"
        font.pixelSize: 14
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10
        
        Rectangle {
            anchors.fill: parent
            color: "rgba(0, 0, 0, 0.5)"
            z: -1
        }
    }
    
    // 模型加载器
    ModelLoader {
        id: modelLoader
        onModelLoaded: {
            modelEntity = entity;
            isModelLoaded = true;
            
            // 优化模型
            if (simplificationFactor > 0) {
                modelLoader.optimizeModel(modelEntity, simplificationFactor);
            }
            
            // 压缩纹理
            if (maxTextureSize > 0) {
                modelLoader.compressTextures(modelEntity, maxTextureSize);
            }
        }
    }
    
    // 点位绑定器
    DPointBinder {
        id: pointBinder
        onNodeClicked: {
            selectedDevice = tagName;
            deviceNameLabel.text = "设备: " + tagName;
            deviceStatusLabel.text = "状态: " + (status === DPointBinder.Normal ? "正常" : 
                                                  status === DPointBinder.Warning ? "警告" : 
                                                  status === DPointBinder.Error ? "错误" : "离线");
            deviceValueLabel.text = "值: " + value.toFixed(2);
            statusIndicator.color = color;
            deviceDialog.visible = true;
        }
    }
    
    // 定时器用于计算FPS
    Timer {
        id: fpsTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            fps = scene3D.fps;
        }
    }
    
    // 初始化
    Component.onCompleted: {
        if (modelUrl) {
            loadModel(modelUrl);
        }
    }
    
    // 加载模型
    function loadModel(url) {
        if (modelEntity) {
            // 移除旧模型
            modelEntity.destroy();
            modelEntity = null;
        }
        
        // 加载新模型
        if (url.endsWith(".gltf") || url.endsWith(".glb")) {
            modelLoader.loadGltfModel(Qt.url(url), modelContainer);
        } else if (url.endsWith(".obj")) {
            modelLoader.loadObjModel(Qt.url(url), modelContainer);
        }
    }
    
    // 绑定点位到模型节点
    function bindPointToNode(tagName, nodeName) {
        // 查找节点
        var node = findNode(modelEntity, nodeName);
        if (node) {
            pointBinder.bindTagToNode(tagName, node);
        }
    }
    
    // 查找节点
    function findNode(parentEntity, nodeName) {
        if (!parentEntity) return null;
        
        // 检查当前节点
        if (parentEntity.objectName === nodeName) {
            return parentEntity;
        }
        
        // 递归查找子节点
        for (var i = 0; i < parentEntity.children.length; i++) {
            var child = parentEntity.children[i];
            if (child instanceof Qt3DCore.QEntity) {
                var foundNode = findNode(child, nodeName);
                if (foundNode) {
                    return foundNode;
                }
            }
        }
        
        return null;
    }
    
    // 处理光线投射命中
    function handleRayCastHit(hit) {
        // 查找命中的节点对应的点位
        var node = hit.entity;
        if (node) {
            // 这里需要根据实际的节点命名规则或映射关系找到对应的点位
            // 示例：假设节点名称就是点位名称
            var tagName = node.objectName;
            if (tagName) {
                pointBinder.nodeClicked(tagName, pointBinder.getNodeStatus(tagName), 0.0);
            }
        }
    }
    
    // 批量更新点位值
    function updatePoints(points) {
        pointBinder.updatePointValues(points);
    }
}
