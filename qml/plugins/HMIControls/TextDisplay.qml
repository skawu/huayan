import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    
    // 可自定义属性
    property color backgroundColor: "#212121"
    property color textColor: "#FFFFFF"
    property color borderColor: "#616161"
    property int borderWidth: 1
    property int cornerRadius: 4
    
    // 文本属性
    property string text: ""
    property string label: ""
    property color labelColor: "#9E9E9E"
    property int fontSize: 14
    property bool bold: false
    property bool italic: false
    property bool wordWrap: true
    property Text.AlignHorizontal horizontalAlignment: Text.AlignLeft
    property Text.AlignVertical verticalAlignment: Text.AlignTop
    
    // 设备点位绑定
    property string tagName: ""
    property bool bindToTag: false
    property string tagValue: ""
    
    // 背景
    Rectangle {
        id: background
        anchors.fill: parent
        radius: cornerRadius
        color: backgroundColor
        border.width: borderWidth
        border.color: borderColor
    }
    
    // 标签显示
    Text {
        id: labelText
        text: label
        color: labelColor
        font.pixelSize: root.height * 0.25
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 8
    }
    
    // 文本显示
    Text {
        id: displayText
        text: root.text
        color: textColor
        font.pixelSize: fontSize
        font.bold: bold
        font.italic: italic
        wrapMode: wordWrap ? Text.WordWrap : Text.NoWrap
        horizontalAlignment: horizontalAlignment
        verticalAlignment: verticalAlignment
        
        anchors.top: labelText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8
    }
    
    // 点位值变化处理
    onTagValueChanged: {
        if (bindToTag) {
            root.text = tagValue
        }
    }
    
    // 文本变化信号
    signal textChanged(string newText)
    
    // 文本变化处理
    onTextChanged: {
        root.textChanged(text)
    }
    
    // 默认尺寸
    implicitWidth: 200
    implicitHeight: 100
    Layout.preferredWidth: 200
    Layout.preferredHeight: 100
}
