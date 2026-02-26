import QtQuick
import QtQuick.Controls

Popup {
    id: infoDialog
    width: 400
    height: 250
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    property string message: ""
    
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    
    background: Rectangle {
        color: "#34495e"
        border.color: "#3498db"
        border.width: 2
        radius: 10
    }
    
    contentItem: Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        Text {
            text: "验收测试结果"
            color: "white"
            font.pixelSize: 20
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Rectangle {
            width: parent.width
            height: 1
            color: "#3498db"
        }
        
        Text {
            text: infoDialog.message
            color: "#ecf0f1"
            font.pixelSize: 14
            wrapMode: Text.WordWrap
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
        }
        
        Item {
            width: parent.width
            height: 20
        }
        
        Button {
            text: "确定"
            anchors.horizontalCenter: parent.horizontalCenter
            
            background: Rectangle {
                color: "#2ecc71"
                radius: 5
            }
            
            contentItem: Text {
                text: parent.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: infoDialog.close()
        }
    }
}