import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Huayan.HMIControls 1.0
import Huayan.HMI 1.0

Window {
    id: mainWindow
    width: 1280
    height: 720
    visible: true
    title: "Huayan HMI 控件演示"
    
    // 布局管理器
    LayoutManager {
        id: layoutManager
        anchors.fill: parent
        editing: false
    }
    
    // 顶部工具栏
    Rectangle {
        id: toolbar
        width: parent.width
        height: 50
        color: "#212121"
        border.bottom: 1
        border.color: "#616161"
        
        RowLayout {
            anchors.fill: parent
            padding: 10
            spacing: 10
            
            Button {
                text: "编辑模式"
                checked: layoutManager.editing
                checkable: true
                onClicked: {
                    layoutManager.editing = !layoutManager.editing
                }
            }
            
            Button {
                text: "保存模板"
                onClicked: {
                    var templateName = "demo_template"
                    layoutManager.saveTemplate(templateName)
                    console.log("模板保存成功:", templateName)
                }
            }
            
            Button {
                text: "加载模板"
                onClicked: {
                    var templateName = "demo_template"
                    layoutManager.loadTemplate(templateName)
                    console.log("模板加载成功:", templateName)
                }
            }
            
            Button {
                text: "清空布局"
                onClicked: {
                    layoutManager.clearControls()
                }
            }
            
            Button {
                text: "添加控件"
                onClicked: {
                    addControlDialog.visible = true
                }
            }
        }
    }
    
    // 控件添加对话框
    Dialog {
        id: addControlDialog
        title: "添加控件"
        width: 400
        height: 300
        modal: true
        visible: false
        
        ColumnLayout {
            anchors.fill: parent
            padding: 20
            spacing: 15
            
            Label {
                text: "选择控件类型"
                font.bold: true
            }
            
            ComboBox {
                id: controlTypeComboBox
                model: [
                    "Button",
                    "IndicatorLight",
                    "Slider",
                    "DIPSwitch",
                    "Dashboard",
                    "ToggleSwitch",
                    "ProgressBar",
                    "NumericDisplay",
                    "TextDisplay",
                    "MultiStateButton"
                ]
                currentIndex: 0
            }
            
            Label {
                text: "控件属性"
                font.bold: true
            }
            
            TextField {
                id: controlNameField
                placeholderText: "控件名称"
            }
            
            RowLayout {
                Button {
                    text: "添加"
                    onClicked: {
                        addControl(controlTypeComboBox.currentText, controlNameField.text)
                        addControlDialog.visible = false
                    }
                }
                
                Button {
                    text: "取消"
                    onClicked: {
                        addControlDialog.visible = false
                    }
                }
            }
        }
    }
    
    // 初始控件布局
    Component.onCompleted: {
        initializeDemoLayout()
    }
    
    // 添加控件函数
    function addControl(type, name) {
        var control = null
        var x = Math.random() * (layoutManager.width - 200)
        var y = Math.random() * (layoutManager.height - 100) + 60 // 避开工具栏
        
        switch (type) {
            case "Button":
                control = Button {
                    x: x
                    y: y
                    width: 120
                    height: 40
                    text: name || "按钮"
                    normalColor: "#4CAF50"
                }
                break
            case "IndicatorLight":
                control = IndicatorLight {
                    x: x
                    y: y
                    size: 50
                    on: Math.random() > 0.5
                }
                break
            case "Slider":
                control = Slider {
                    x: x
                    y: y
                    width: 200
                    height: 40
                    value: 50
                }
                break
            case "DIPSwitch":
                control = DIPSwitch {
                    x: x
                    y: y
                    switchCount: 4
                }
                break
            case "Dashboard":
                control = Dashboard {
                    x: x
                    y: y
                    size: 150
                    value: 75
                    label: "速度"
                    unit: "rpm"
                }
                break
            case "ToggleSwitch":
                control = ToggleSwitch {
                    x: x
                    y: y
                }
                break
            case "ProgressBar":
                control = ProgressBar {
                    x: x
                    y: y
                    width: 200
                    height: 30
                    value: 60
                }
                break
            case "NumericDisplay":
                control = NumericDisplay {
                    x: x
                    y: y
                    width: 150
                    height: 60
                    value: 123.45
                    label: "温度"
                    unit: "°C"
                }
                break
            case "TextDisplay":
                control = TextDisplay {
                    x: x
                    y: y
                    width: 200
                    height: 100
                    text: "设备状态: 正常\n运行时间: 12345秒"
                    label: "状态信息"
                }
                break
            case "MultiStateButton":
                control = MultiStateButton {
                    x: x
                    y: y
                    width: 150
                    height: 40
                    states: ["自动", "手动", "停止"]
                }
                break
        }
        
        if (control) {
            control.parent = layoutManager
        }
    }
    
    // 初始化演示布局
    function initializeDemoLayout() {
        // 按钮
        Button {
            parent: layoutManager
            x: 50
            y: 80
            width: 120
            height: 40
            text: "启动设备"
            normalColor: "#4CAF50"
        }
        
        // 指示灯
        IndicatorLight {
            parent: layoutManager
            x: 200
            y: 80
            size: 50
            on: true
        }
        
        // 滑块
        Slider {
            parent: layoutManager
            x: 280
            y: 80
            width: 200
            height: 40
            value: 50
        }
        
        // 拨码开关
        DIPSwitch {
            parent: layoutManager
            x: 500
            y: 80
            switchCount: 4
        }
        
        // 仪表盘
        Dashboard {
            parent: layoutManager
            x: 600
            y: 80
            size: 150
            value: 75
            label: "速度"
            unit: "rpm"
        }
        
        // 切换开关
        ToggleSwitch {
            parent: layoutManager
            x: 50
            y: 150
        }
        
        // 进度条
        ProgressBar {
            parent: layoutManager
            x: 150
            y: 150
            width: 200
            height: 30
            value: 60
        }
        
        // 数值显示
        NumericDisplay {
            parent: layoutManager
            x: 380
            y: 150
            width: 150
            height: 60
            value: 123.45
            label: "温度"
            unit: "°C"
        }
        
        // 文本显示
        TextDisplay {
            parent: layoutManager
            x: 550
            y: 150
            width: 200
            height: 100
            text: "设备状态: 正常\n运行时间: 12345秒"
            label: "状态信息"
        }
        
        // 多状态按钮
        MultiStateButton {
            parent: layoutManager
            x: 780
            y: 150
            width: 150
            height: 40
            states: ["自动", "手动", "停止"]
        }
    }
}
