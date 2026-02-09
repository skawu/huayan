import QtQuick 2.15
import QtQuick.Controls 2.15
import BasicComponents 1.0
import IndustrialComponents 1.0
import ThreeDComponents 1.0
import ChartComponents 1.0

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
                
                WaterTreatmentSystemExample {
                    anchors.fill: parent
                    anchors.margins: 10
                }
            }
        }
    }
}
