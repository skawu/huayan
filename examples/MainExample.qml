import QtQuick 2.15
import QtQuick.Controls 2.15
import BasicComponents 1.0
import IndustrialComponents 1.0
import ThreeDComponents 1.0

Rectangle {
    width: 1000
    height: 800
    color: "#f0f0f0"
    
    title: "华颜工业SCADA系统组件示例"
    
    // 标签栏
    TabView {
        anchors.fill: parent
        
        // 基础组件标签
        Tab {
            title: "基础组件"
            
            Rectangle {
                anchors.fill: parent
                color: "#ffffff"
                
                BasicComponentsExample {
                    anchors.fill: parent
                    anchors.margins: 20
                }
            }
        }
        
        // 工业组件标签
        Tab {
            title: "工业组件"
            
            Rectangle {
                anchors.fill: parent
                color: "#ffffff"
                
                IndustrialComponentsExample {
                    anchors.fill: parent
                    anchors.margins: 20
                }
            }
        }
        
        // 3D组件标签
        Tab {
            title: "3D组件"
            
            Rectangle {
                anchors.fill: parent
                color: "#ffffff"
                
                ThreeDComponentsExample {
                    anchors.fill: parent
                    anchors.margins: 20
                }
            }
        }
        
        // 完整系统示例标签
        Tab {
            title: "完整系统示例"
            
            Rectangle {
                anchors.fill: parent
                color: "#ffffff"
                
                Column {
                    anchors.centerIn: parent
                    spacing: 20
                    
                    Text {
                        text: "完整系统示例"
                        font.pointSize: 24
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "此示例展示了一个完整的工业控制系统，包括："
                        font.pointSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "1. 设备连接与数据采集"
                        font.pointSize: 14
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "2. 实时数据可视化"
                        font.pointSize: 14
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "3. 报警和事件管理"
                        font.pointSize: 14
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "4. 历史数据查询与分析"
                        font.pointSize: 14
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "5. 3D数字孪生场景"
                        font.pointSize: 14
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}
