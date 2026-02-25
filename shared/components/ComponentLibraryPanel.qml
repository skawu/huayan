import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * @brief 工业组件库面板
 * 
 * 提供可拖拽的工业组件选择面板：
 * - 分类展示各种工业监控组件
 * - 支持鼠标拖拽创建新组件
 * - 实时预览组件外观
 * - 组件搜索和过滤功能
 */
Rectangle {
    id: componentLibrary
    
    width: 250
    color: "#f8f9fa"
    border.color: "#dee2e6"
    border.width: 1
    
    // ==================== 属性定义 ====================
    property var componentTypes: [
        {
            "name": "文本显示器",
            "type": "text_display",
            "icon": "T",
            "color": "#4CAF50",
            "description": "显示文本和数值信息"
        },
        {
            "name": "按钮控制器",
            "type": "button_control", 
            "icon": "🔘",
            "color": "#2196F3",
            "description": "控制开关和操作按钮"
        },
        {
            "name": "进度条",
            "type": "progress_bar",
            "icon": "📊",
            "color": "#FF9800",
            "description": "显示数值进度和状态"
        },
        {
            "name": "仪表盘",
            "type": "gauge",
            "icon": "⏱️",
            "color": "#9C27B0",
            "description": "圆形仪表显示测量值"
        },
        {
            "name": "LED指示灯",
            "type": "led_indicator",
            "icon": "💡",
            "color": "#F44336",
            "description": "状态指示和报警显示"
        },
        {
            "name": "趋势图",
            "type": "trend_chart",
            "icon": "📈",
            "color": "#00BCD4",
            "description": "实时数据趋势显示"
        }
    ]
    
    property alias currentIndex: listView.currentIndex
    property string searchText: ""
    
    // ==================== 信号定义 ====================
    signal componentSelected(string componentType, point startPosition)
    signal componentDragged(string componentType, point position)
    
    // ==================== 标题区域 ====================
    Rectangle {
        id: header
        height: 40
        color: "#e9ecef"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        
        Text {
            anchors.centerIn: parent
            text: "组件库"
            font.pixelSize: 16
            font.bold: true
            color: "#495057"
        }
    }
    
    // ==================== 搜索区域 ====================
    TextField {
        id: searchField
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.margins: 10
        height: 30
        placeholderText: "搜索组件..."
        selectByMouse: true
        
        onTextChanged: {
            searchText = text.toLowerCase()
        }
    }
    
    // ==================== 组件列表 ====================
    ScrollView {
        id: scrollView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: searchField.bottom
        anchors.bottom: parent.bottom
        anchors.margins: 10
        
        ListView {
            id: listView
            model: filteredComponents
            spacing: 8
            clip: true
            
            delegate: ComponentLibraryItem {
                width: ListView.view.width
                componentData: modelData
                onDragStarted: {
                    componentLibrary.componentSelected(modelData.type, Qt.point(mouseX, mouseY))
                }
                onDragUpdated: {
                    componentLibrary.componentDragged(modelData.type, Qt.point(mouseX, mouseY))
                }
            }
            
            // 空状态显示
            Label {
                anchors.centerIn: parent
                text: "未找到匹配的组件"
                color: "#6c757d"
                visible: listView.count === 0
            }
        }
    }
    
    // ==================== 过滤后的组件模型 ====================
    property var filteredComponents: {
        if (searchText === "") {
            return componentTypes
        }
        return componentTypes.filter(function(item) {
            return item.name.toLowerCase().includes(searchText) || 
                   item.description.toLowerCase().includes(searchText)
        })
    }
    
    // ==================== 公共方法 ====================
    
    /**
     * @brief 获取指定类型的组件信息
     */
    function getComponentInfo(componentType) {
        for (var i = 0; i < componentTypes.length; i++) {
            if (componentTypes[i].type === componentType) {
                return componentTypes[i]
            }
        }
        return null
    }
    
    /**
     * @brief 刷新组件列表
     */
    function refresh() {
        listView.model = filteredComponents
    }
}

// ==================== 组件项委托 ====================
Component {
    id: componentItemDelegate
    
    Rectangle {
        width: parent.width
        height: 60
        color: mouseArea.containsMouse ? "#e3f2fd" : "#ffffff"
        border.color: mouseArea.pressed ? "#1976d2" : "#dee2e6"
        border.width: 1
        radius: 4
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            
            // 组件图标
            Rectangle {
                width: 36
                height: 36
                color: modelData.color
                radius: 18
                Layout.alignment: Qt.AlignVCenter
                
                Text {
                    anchors.centerIn: parent
                    text: modelData.icon
                    font.pixelSize: 18
                }
            }
            
            // 组件信息
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                Text {
                    text: modelData.name
                    font.pixelSize: 14
                    font.bold: true
                    color: "#212529"
                    elide: Text.ElideRight
                }
                
                Text {
                    text: modelData.description
                    font.pixelSize: 11
                    color: "#6c757d"
                    elide: Text.ElideRight
                }
            }
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            onPressed: {
                parent.border.width = 2
            }
            
            onReleased: {
                parent.border.width = 1
            }
            
            onExited: {
                parent.border.width = 1
            }
            
            onClicked: {
                console.log("选择了组件:", modelData.name)
            }
        }
    }
}