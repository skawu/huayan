import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    
    // 可自定义属性
    property int switchCount: 4
    property color onColor: "#4CAF50"
    property color offColor: "#9E9E9E"
    property color borderColor: "#616161"
    property int switchSize: 30
    property int spacing: 10
    
    // 状态属性
    property var switchStates: []
    property bool enabled: true
    
    // 设备点位绑定
    property string tagName: ""
    property bool bindToTag: false
    property int tagValue: 0
    
    // 尺寸计算
    width: switchCount * (switchSize + spacing) - spacing
    height: switchSize
    
    // 初始化开关状态
    Component.onCompleted: {
        for (var i = 0; i < switchCount; i++) {
            switchStates.push(false)
        }
    }
    
    // 开关组件
    Repeater {
        model: switchCount
        
        Item {
            x: index * (switchSize + spacing)
            width: switchSize
            height: switchSize
            
            Rectangle {
                id: switchBody
                anchors.fill: parent
                radius: 4
                color: root.enabled ? (root.switchStates[index] ? onColor : offColor) : "#BDBDBD"
                border.width: 1
                border.color: borderColor
                
                // 开关拨片
                Rectangle {
                    id: switchToggle
                    width: parent.width * 0.6
                    height: parent.height * 0.8
                    radius: 2
                    color: "#FFFFFF"
                    border.width: 1
                    border.color: borderColor
                    
                    // 位置动画
                    anchors.verticalCenter: parent.verticalCenter
                    x: root.switchStates[index] ? parent.width * 0.3 : parent.width * 0.1
                    
                    Behavior on x {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }
                
                // 点击处理
                MouseArea {
                    anchors.fill: parent
                    enabled: root.enabled
                    
                    onClicked: {
                        root.switchStates[index] = !root.switchStates[index]
                        root.updateTagValue()
                        root.switchToggled(index, root.switchStates[index])
                    }
                }
            }
        }
    }
    
    // 更新点位值
    function updateTagValue() {
        var value = 0
        for (var i = 0; i < switchCount; i++) {
            if (switchStates[i]) {
                value += Math.pow(2, i)
            }
        }
        
        if (bindToTag && tagName !== "") {
            tagValue = value
        }
    }
    
    // 点位值变化处理
    onTagValueChanged: {
        if (bindToTag) {
            for (var i = 0; i < switchCount; i++) {
                switchStates[i] = (tagValue & Math.pow(2, i)) !== 0
            }
        }
    }
    
    // 信号
    signal switchToggled(int index, bool state)
    signal valueChanged(int newValue)
    
    // 状态变化处理
    onSwitchStatesChanged: {
        root.updateTagValue()
        root.valueChanged(tagValue)
    }
}
