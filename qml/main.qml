import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ThreeDComponents 1.0

Window {
    width: 1280
    height: 720
    visible: true
    title: "Huayan 3D 工业可视化"
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        Layout.margins: 10
        
        // 标题
        Label {
            text: "Huayan 3D 工业可视化演示"
            font.bold: true
            font.pixelSize: 24
            Layout.alignment: Qt.AlignHCenter
        }
        
        // 3D视图
        ThreeDScene {
            id: threeDScene
            width: parent.width
            height: parent.height * 0.7
        }
        
        // 控制面板
        RowLayout {
            width: parent.width
            spacing: 10
            
            Button {
                text: "加载测试模型"
                onClicked: {
                    // 加载测试模型
                }
            }
            
            Button {
                text: "绑定测试点位"
                onClicked: {
                    // 绑定测试点位
                }
            }
            
            Button {
                text: "更新点位状态"
                onClicked: {
                    // 模拟更新点位状态
                }
            }
            
            Button {
                text: "优化模型"
                onClicked: {
                    // 优化模型
                }
            }
        }
        
        // 状态信息
        RowLayout {
            width: parent.width
            spacing: 20
            
            Label {
                text: "3D场景已加载"
            }
        }
    }
}
