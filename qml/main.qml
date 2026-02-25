
import QtQuick
import QtQuick.Window
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 6.2
import "modules/core"
import BasicComponents
import IndustrialComponents
import ControlComponents
import ChartComponents
import ThreeDComponents

Window {
    // 将组件加载器与组件引用放在 Window 内部，避免顶层 property/Loader 导致语法错误
    QtObject {
        id: globalObjects
        property Component componentItem
        property Component canvasComponent
        property Component resizeHandle
    }

    QtObject {
        id: appProxy
        readonly property var appLogic: AppLogic
        function initialize() { if (appProxy.appLogic && appProxy.appLogic.initialize) appProxy.appLogic.initialize(); }
        function newProject() { if (appProxy.appLogic && appProxy.appLogic.newProject) appProxy.appLogic.newProject(); }
        function openProject() { if (appProxy.appLogic && appProxy.appLogic.openProject) appProxy.appLogic.openProject(); }
        function saveProject() { if (appProxy.appLogic && appProxy.appLogic.saveProject) appProxy.appLogic.saveProject(); }
        function saveProjectAs() { if (appProxy.appLogic && appProxy.appLogic.saveProjectAs) appProxy.appLogic.saveProjectAs(); }
        function exportProject() { if (appProxy.appLogic && appProxy.appLogic.exportProject) appProxy.appLogic.exportProject(); }
        function importProject() { if (appProxy.appLogic && appProxy.appLogic.importProject) appProxy.appLogic.importProject(); }
        function createNewPage() { if (appProxy.appLogic && appProxy.appLogic.createNewPage) appProxy.appLogic.createNewPage(); }
        function deleteCurrentPage() { if (appProxy.appLogic && appProxy.appLogic.deleteCurrentPage) appProxy.appLogic.deleteCurrentPage(); }
        function renameCurrentPage() { if (appProxy.appLogic && appProxy.appLogic.renameCurrentPage) appProxy.appLogic.renameCurrentPage(); }
        function switchPage(i) { if (appProxy.appLogic && appProxy.appLogic.switchPage) appProxy.appLogic.switchPage(i); }
        function applyDataBinding() { if (appProxy.appLogic && appProxy.appLogic.applyDataBinding) appProxy.appLogic.applyDataBinding(); }
        function removeDataBinding() { if (appProxy.appLogic && appProxy.appLogic.removeDataBinding) appProxy.appLogic.removeDataBinding(); }
    }

      Loader {
          id: componentsLoader
          source: "parts/components_container.qml"
          asynchronous: false
          onLoaded: {
              var it = componentsLoader.item
              if (it) {
                  if (it.componentItem !== undefined) globalObjects.componentItem = it.componentItem
                  if (it.canvasComponent !== undefined) globalObjects.canvasComponent = it.canvasComponent
                  if (it.resizeHandle !== undefined) globalObjects.resizeHandle = it.resizeHandle
              }
          }
      }

    width: 1440
    height: 900
    visible: true
    title: "Huayan 工业组态软件"
    
    Component.onCompleted: {
        // 在组件完成时注入 components_loader 中的对象引用到 AppLogic 单例
        var it = componentsLoader.item
        if (appProxy && appProxy.appLogic) {
            if (it) {
                appProxy.appLogic.canvas = it.canvas !== undefined ? it.canvas : null
                appProxy.appLogic.canvasContainer = it.canvasContainer !== undefined ? it.canvasContainer : null
                appProxy.appLogic.statusBar = it.statusBar !== undefined ? it.statusBar : null
                appProxy.appLogic.pageModel = it.pageModel !== undefined ? it.pageModel : null
                appProxy.appLogic.propertyPanel = it.propertyPanel !== undefined ? it.propertyPanel : null
                appProxy.appLogic.tagComboBox = it.tagComboBox !== undefined ? it.tagComboBox : null
                appProxy.appLogic.propertyComboBox = it.propertyComboBox !== undefined ? it.propertyComboBox : null
                appProxy.appLogic.bindingTypeComboBox = it.bindingTypeComboBox !== undefined ? it.bindingTypeComboBox : null
                appProxy.appLogic.updateFrequencyComboBox = it.updateFrequencyComboBox !== undefined ? it.updateFrequencyComboBox : null
                appProxy.appLogic.historyDataCheckBox = it.historyDataCheckBox !== undefined ? it.historyDataCheckBox : null
                appProxy.appLogic.trendChartCheckBox = it.trendChartCheckBox !== undefined ? it.trendChartCheckBox : null
                appProxy.appLogic.bindingExpressionField = it.bindingExpressionField !== undefined ? it.bindingExpressionField : null
            }
            appProxy.initialize()
        }
    }
    
    // 主布局
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // 菜单栏
        MenuBar {
            Menu {
                title: "文件"
                MenuItem {
                    text: "新建项目"
                    onClicked: {
                        appProxy.newProject()
                    }
                }
                MenuItem {
                    text: "打开项目"
                    onClicked: {
                        appProxy.openProject()
                    }
                }
                MenuItem {
                    text: "保存项目"
                    onClicked: {
                        appProxy.saveProject()
                    }
                }
                MenuItem {
                    text: "另存为"
                    onClicked: {
                        appProxy.saveProjectAs()
                    }
                }
                MenuSeparator { }
                MenuItem {
                    text: "导出项目"
                    onClicked: {
                        appProxy.exportProject()
                    }
                }
                MenuItem {
                    text: "导入项目"
                    onClicked: {
                        appProxy.importProject()
                    }
                }
                MenuSeparator { }
                MenuItem {
                    text: "退出"
                    onClicked: {
                        Qt.quit()
                    }
                }
            }
            Menu {
                title: "编辑"
                MenuItem { text: "撤销" }
                MenuItem { text: "重做" }
                MenuSeparator { }
                MenuItem { text: "剪切" }
                MenuItem { text: "复制" }
                MenuItem { text: "粘贴" }
                MenuSeparator { }
                MenuItem { text: "删除" }
                MenuItem { text: "全选" }
            }
            Menu {
                title: "视图"
                MenuItem { text: "工具栏" }
                MenuItem { text: "项目浏览器" }
                MenuItem { text: "属性面板" }
                MenuItem { text: "状态栏" }
                MenuSeparator { }
                MenuItem { text: "网格显示" }
                MenuItem { text: "对齐辅助线" }
            }
            Menu {
                title: "工具"
                MenuItem { text: "组件库" }
                MenuItem { text: "布局模板" }
                MenuItem { text: "主题设置" }
                MenuItem { text: "选项" }
            }
            Menu {
                title: "帮助"
                MenuItem { text: "用户手册" }
                MenuItem { text: "关于" }
            }
        }
        
        // 工具栏
        ToolBar {
            RowLayout {
                spacing: 5
                
                ToolButton { text: "新建" }
                ToolButton { text: "打开" }
                ToolButton { text: "保存" }
                ToolSeparator { }
                ToolButton { text: "撤销" }
                ToolButton { text: "重做" }
                ToolSeparator { }
                ToolButton { text: "剪切" }
                ToolButton { text: "复制" }
                ToolButton { text: "粘贴" }
                ToolSeparator { }
                ToolButton { text: "放大" }
                ToolButton { text: "缩小" }
                ToolButton { text: "适应窗口" }
            }
        }
        
        // 主工作区
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 1
            
            // 左侧项目浏览器
            Rectangle {
                Layout.preferredWidth: 250
                Layout.fillHeight: true
                color: "#F5F5F5"
                border.color: "#CCCCCC"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    
                      Label {
                          text: "项目浏览器"
                          font.bold: true
                          Layout.margins: 5
                          background: Rectangle { color: "#E0E0E0" }
                      }
                    
                    // 项目结构和组件库
                    TabView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        Tab {
                            title: "项目"
                            
                              ColumnLayout {
                                  spacing: 5
                                  anchors.margins: 5
                                
                                // 页面管理工具栏
                                RowLayout {
                                    spacing: 5
                                    
                                    Button {
                                        text: "新建页面"
                                        onClicked: {
                                            appProxy.createNewPage()
                                        }
                                    }
                                    Button {
                                        text: "删除页面"
                                        onClicked: {
                                            appProxy.deleteCurrentPage()
                                        }
                                    }
                                    Button {
                                        text: "重命名页面"
                                        onClicked: {
                                            appProxy.renameCurrentPage()
                                        }
                                    }
                                }
                                
                                // 页面列表
                                ListView {
                                    id: pageListView
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    
                                    model: ListModel {
                                        id: pageModel
                                        ListElement { name: "页面 1"; type: "page"; active: true }
                                        ListElement { name: "页面 2"; type: "page"; active: false }
                                    }
                                    
                                    delegate: Item {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: 30
                                        
                                        Rectangle {
                                            anchors.fill: parent
                                            color: model.active ? "#E3F2FD" : "transparent"
                                            border.color: model.active ? "#2196F3" : "transparent"
                                            border.width: 1
                                        }
                                        
                                        Text {
                                            text: name
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            anchors.leftMargin: 10
                                            color: model.active ? "#1976D2" : "#000000"
                                            font.bold: model.active
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                appProxy.switchPage(index)
                                            }
                                        }
                                    }
                                }
                                
                                // 项目结构
                                GroupBox {
                                    title: "项目结构"
                                    
                                    ListView {
                                        model: ListModel {
                                            ListElement { name: "数据点位"; type: "tags" }
                                            ListElement { name: "报警管理"; type: "alarms" }
                                            ListElement { name: "趋势图表"; type: "trends" }
                                            ListElement { name: "报表"; type: "reports" }
                                        }
                                        
                                        delegate: Item {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            height: 25
                                            
                                            Text {
                                                text: name
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.left: parent.left
                                                anchors.leftMargin: 10
                                            }
                                            
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    if (model.type === "alarms") {
                                                        showAlarmManager()
                                                    } else if (model.type === "trends") {
                                                        showTrendCharts()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        Tab {
                            title: "组件库"
                            
                              ColumnLayout {
                                  spacing: 10
                                  anchors.margins: 5
                                
                                // 组件分类
                                RowLayout {
                                    spacing: 5
                                    
                                    Button { text: "基础组件" }
                                    Button { text: "工业组件" }
                                    Button { text: "控制组件" }
                                    Button { text: "图表组件" }
                                    Button { text: "3D组件" }
                                }
                                
                                // 组件列表
                                  GridLayout {
                                      columns: 2
                                      rowSpacing: 10
                                      columnSpacing: 10
                                    
                                    // 基础组件
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "Indicator"
                                            item.type = "BasicComponents.Indicator"
                                        }
                                    }
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "PushButton"
                                            item.type = "BasicComponents.PushButton"
                                        }
                                    }
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "TextLabel"
                                            item.type = "BasicComponents.TextLabel"
                                        }
                                    }
                                    
                                    // 工业组件
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "Valve"
                                            item.type = "IndustrialComponents.Valve"
                                        }
                                    }
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "Tank"
                                            item.type = "IndustrialComponents.Tank"
                                        }
                                    }
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "Motor"
                                            item.type = "IndustrialComponents.Motor"
                                        }
                                    }
                                    
                                    // 控制组件
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "Slider"
                                            item.type = "ControlComponents.Slider"
                                        }
                                    }
                                    Loader {
                                        sourceComponent: componentItem
                                        onLoaded: {
                                            item.name = "Knob"
                                            item.type = "ControlComponents.Knob"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // 中央画布区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#FFFFFF"
                border.color: "#CCCCCC"
                border.width: 1
                
                // 画布容器
                Item {
                    id: canvasContainer
                    anchors.fill: parent
                    
                    // 画布变换属性
                    property real scale: 1.0
                    property real minScale: 0.1
                    property real maxScale: 5.0
                    property real offsetX: 0
                    property real offsetY: 0
                    property bool isPanning: false
                    property real panStartX: 0
                    property real panStartY: 0
                    property real panOffsetX: 0
                    property real panOffsetY: 0
                    
                    // 鼠标区域
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                        
                        // 开始平移
                        onPressed: {
                            if (mouse.button === Qt.MiddleButton || mouse.button === Qt.RightButton) {
                                canvasContainer.isPanning = true
                                canvasContainer.panStartX = mouse.x
                                canvasContainer.panStartY = mouse.y
                                canvasContainer.panOffsetX = canvasContainer.offsetX
                                canvasContainer.panOffsetY = canvasContainer.offsetY
                            }
                        }
                        
                        // 结束平移
                        onReleased: {
                            if (mouse.button === Qt.MiddleButton || mouse.button === Qt.RightButton) {
                                canvasContainer.isPanning = false
                            }
                        }
                        
                        // 处理平移
                        onMouseXChanged: {
                            if (canvasContainer.isPanning) {
                                canvasContainer.offsetX = canvasContainer.panOffsetX + (mouseX - canvasContainer.panStartX)
                                canvasContainer.offsetY = canvasContainer.panOffsetY + (mouseY - canvasContainer.panStartY)
                                appProxy.updateCanvasTransform()
                            }
                        }
                        
                        onMouseYChanged: {
                            if (canvasContainer.isPanning) {
                                canvasContainer.offsetX = canvasContainer.panOffsetX + (mouseX - canvasContainer.panStartX)
                                canvasContainer.offsetY = canvasContainer.panOffsetY + (mouseY - canvasContainer.panStartY)
                                appProxy.updateCanvasTransform()
                            }
                        }
                        
                        // 处理缩放
                        onWheel: {
                            const zoomFactor = wheel.angleDelta.y > 0 ? 1.1 : 0.9
                            const newScale = Math.max(canvasContainer.minScale, Math.min(canvasContainer.maxScale, canvasContainer.scale * zoomFactor))
                            
                            if (newScale !== canvasContainer.scale) {
                                // 计算缩放中心点
                                const mouseXRelative = wheel.x - canvasContainer.offsetX
                                const mouseYRelative = wheel.y - canvasContainer.offsetY
                                
                                // 调整偏移量以保持鼠标位置不变
                                const scaleRatio = newScale / canvasContainer.scale
                                canvasContainer.offsetX = wheel.x - mouseXRelative * scaleRatio
                                canvasContainer.offsetY = wheel.y - mouseYRelative * scaleRatio
                                canvasContainer.scale = newScale
                                
                                appProxy.updateCanvasTransform()
                                appProxy.updateStatusBar()
                            }
                        }
                    }
                    
                    // 画布内容
                    Item {
                        id: canvas
                        anchors.fill: parent
                        
                        // 网格背景
                        Rectangle {
                            anchors.fill: parent
                            color: "#F9F9F9"
                            
                            // 网格线
                            Repeater {
                                model: canvas.width / 20
                                Rectangle {
                                    width: 1
                                    height: canvas.height
                                    x: index * 20
                                    color: "#E0E0E0"
                                }
                            }
                            Repeater {
                                model: canvas.height / 20
                                Rectangle {
                                    width: canvas.width
                                    height: 1
                                    y: index * 20
                                    color: "#E0E0E0"
                                }
                            }
                        }
                        
                        // 示例组件
                        Loader {
                            id: component1
                            sourceComponent: canvasComponent
                            x: 100
                            y: 100
                            width: 100
                            height: 100
                            onLoaded: {
                                item.name = "矩形 1"
                                item.color = "#2196F3"
                                item.borderColor = "#1976D2"
                                item.borderWidth = 2
                            }
                        }
                        
                        Loader {
                            id: component2
                            sourceComponent: canvasComponent
                            x: 300
                            y: 200
                            width: 150
                            height: 80
                            onLoaded: {
                                item.name = "矩形 2"
                                item.color = "#4CAF50"
                                item.borderColor = "#388E3C"
                                item.borderWidth = 2
                            }
                        }
                    }
                }
            }
            
            // 右侧属性面板
            Rectangle {
                Layout.preferredWidth: 300
                Layout.fillHeight: true
                color: "#F5F5F5"
                border.color: "#CCCCCC"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    
                      Label {
                          text: "属性面板"
                          font.bold: true
                          Layout.margins: 5
                          background: Rectangle { color: "#E0E0E0" }
                      }
                    
                    // 属性编辑器
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                            ColumnLayout {
                                spacing: 10
                                anchors.margins: 10
                            
                            GroupBox {
                                title: "位置与大小"
                                
                                  GridLayout {
                                      columns: 2
                                      rowSpacing: 5
                                      columnSpacing: 5
                                    
                                    Label { text: "X:" }
                                    SpinBox { value: 100 }
                                    Label { text: "Y:" }
                                    SpinBox { value: 100 }
                                    Label { text: "宽度:" }
                                    SpinBox { value: 100 }
                                    Label { text: "高度:" }
                                    SpinBox { value: 100 }
                                }
                            }
                            
                            GroupBox {
                                title: "外观"
                                
                                  GridLayout {
                                      columns: 2
                                      rowSpacing: 5
                                      columnSpacing: 5
                                    
                                    Label { text: "填充色:" }
                                    ColorDialog { id: fillColorDialog }
                                    Label { text: "边框色:" }
                                    ColorDialog { id: borderColorDialog }
                                    Label { text: "边框宽度:" }
                                    SpinBox { value: 2 }
                                }
                            }
                            
                            GroupBox {
                                title: "数据绑定"
                                
                                  GridLayout {
                                      columns: 2
                                      rowSpacing: 5
                                      columnSpacing: 5
                                    
                                    Label { text: "数据点位:" }
                                    ComboBox {
                                        id: tagComboBox
                                        model: ["选择点位", "tag1", "tag2", "tag3", "tag4", "tag5"]
                                    }
                                    Label { text: "绑定属性:" }
                                    ComboBox {
                                        id: propertyComboBox
                                        model: ["填充色", "位置", "大小", "旋转", "透明度"]
                                    }
                                    Label { text: "绑定方式:" }
                                    ComboBox {
                                        id: bindingTypeComboBox
                                        model: ["实时绑定", "条件绑定", "表达式绑定"]
                                    }
                                    Label { text: "更新频率:" }
                                    ComboBox {
                                        id: updateFrequencyComboBox
                                        model: ["100ms", "200ms", "500ms", "1s", "2s", "5s"]
                                    }
                                    Label { text: "历史数据:" }
                                    CheckBox {
                                        id: historyDataCheckBox
                                        text: "启用"
                                    }
                                    Label { text: "趋势图表:" }
                                    CheckBox {
                                        id: trendChartCheckBox
                                        text: "启用"
                                    }
                                }
                            }
                            
                            GroupBox {
                                title: "绑定配置"
                                
                                ColumnLayout {
                                    spacing: 5
                                    
                                    Label { text: "绑定表达式:" }
                                    TextField {
                                        id: bindingExpressionField
                                        placeholderText: "例如: value > 50 ? 'red' : 'green'"
                                        Layout.fillWidth: true
                                    }
                                    
                                    Button {
                                        text: "应用绑定"
                                        onClicked: {
                                            applyDataBinding()
                                        }
                                    }
                                    
                                    Button {
                                        text: "解除绑定"
                                        onClicked: {
                                            removeDataBinding()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // 状态栏
        StatusBar {
            RowLayout {
                spacing: 20
                
                Label { text: "就绪" }
                Label { text: "页面: 页面 1" }
                Label { text: "组件: 2" }
                Label { text: "缩放: 100%" }
            }
        }
    }
}
