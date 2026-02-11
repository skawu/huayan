import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Styles 1.4

/**
 * @file IndustrialTheme.qml
 * @brief 工业风格主题定义
 * 
 * 定义了现代扁平化工业设计的颜色和样式，包括低饱和度灰/蓝主色调，高对比度操作按钮
 * 适配工业屏强光环境下的可视性
 */

Theme {
    // 主色调 - 低饱和度灰/蓝
    property color primaryColor: "#34495E"      // 深蓝灰色
    property color secondaryColor: "#3498DB"    // 亮蓝色
    property color accentColor: "#E74C3C"        // 高对比度红色
    
    // 背景色
    property color backgroundColor: "#F5F6FA"    // 浅灰色背景
    property color surfaceColor: "#FFFFFF"       // 白色表面
    property color cardColor: "#FFFFFF"          // 卡片背景
    
    // 文本色
    property color textPrimary: "#2C3E50"         // 主文本色
    property color textSecondary: "#7F8C8D"       // 次要文本色
    property color textLight: "#FFFFFF"          // 亮色文本
    
    // 状态色
    property color successColor: "#27AE60"        // 成功色
    property color warningColor: "#F39C12"        // 警告色
    property color errorColor: "#E74C3C"          // 错误色
    property color infoColor: "#3498DB"           // 信息色
    
    // 边框色
    property color borderColor: "#E0E0E0"         // 边框色
    property color borderLight: "#F0F0F0"         // 浅色边框
    
    // 阴影
    property color shadowColor: "rgba(0, 0, 0, 0.1)" // 阴影色
    
    // 按钮样式
    Button {
        background: Rectangle {
            color: control.pressed ? Qt.darker(secondaryColor, 1.2) : control.hovered ? Qt.lighter(secondaryColor, 1.1) : secondaryColor
            border.color: Qt.darker(secondaryColor, 1.3)
            border.width: 1
            radius: 4
        }
        contentItem: Text {
            text: control.text
            color: textLight
            font.pixelSize: 14
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        implicitWidth: Math.max(100, contentItem.implicitWidth + 20)
        implicitHeight: 48 // 确保按钮尺寸≥48×48px，适配工业级大屏触控
    }
    
    // 卡片样式
    Rectangle {
        default property alias content: contentItem
        
        color: cardColor
        border.color: borderColor
        border.width: 1
        radius: 8
        
        // 阴影效果
        layer.enabled: true
        layer.effect: DropShadow {
            color: shadowColor
            radius: 4
            samples: 8
            offset.x: 0
            offset.y: 2
        }
        
        Item {
            id: contentItem
            anchors.fill: parent
            anchors.margins: 16
        }
    }
    
    // 输入框样式
    TextField {
        background: Rectangle {
            color: surfaceColor
            border.color: control.focused ? secondaryColor : borderColor
            border.width: 1
            radius: 4
        }
        contentItem: TextInput {
            color: textPrimary
            font.pixelSize: 14
            leftPadding: 12
            rightPadding: 12
        }
        implicitHeight: 40
    }
    
    // 标题样式
    Text {
        property int headingLevel: 1
        
        font.pixelSize: {
            switch (headingLevel) {
                case 1: return 24;
                case 2: return 20;
                case 3: return 18;
                case 4: return 16;
                default: return 14;
            }
        }
        font.bold: headingLevel <= 3
        color: textPrimary
    }
    
    // 面板样式
    Rectangle {
        property alias title: titleText.text
        
        color: surfaceColor
        border.color: borderColor
        border.width: 1
        radius: 4
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            
            Rectangle {
                color: primaryColor
                Layout.fillWidth: true
                height: 40
                
                Text {
                    id: titleText
                    anchors.centerIn: parent
                    color: textLight
                    font.pixelSize: 16
                    font.bold: true
                }
            }
            
            Item {
                id: panelContent
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                default property alias content: panelContent.children
            }
        }
    }
    
    // 状态指示器样式
    Rectangle {
        property bool active: false
        property color activeColor: successColor
        property color inactiveColor: textSecondary
        
        color: active ? activeColor : inactiveColor
        radius: width / 2
        implicitWidth: 20
        implicitHeight: 20
        
        // 脉冲动画效果
        Behavior on active {
            NumberAnimation {
                duration: 300
            }
        }
    }
}
