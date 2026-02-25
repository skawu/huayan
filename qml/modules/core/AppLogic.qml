import QtQuick 2.15

pragma Singleton

QtObject {
    id: appLogic

    // 引用到主 QML 中的对象（由 main.qml 在 Loader.onLoaded 时注入）
    property var canvas: null
    property var canvasContainer: null
    property var statusBar: null
    property var pageModel: null
    property var propertyPanel: null
    property var tagComboBox: null
    property var propertyComboBox: null
    property var bindingTypeComboBox: null
    property var updateFrequencyComboBox: null
    property var historyDataCheckBox: null
    property var trendChartCheckBox: null
    property var bindingExpressionField: null

    // 数据绑定存储
    property var dataBindings: ({})

    function updateCanvasTransform() {
        if (appLogic.canvas) {
            appLogic.canvas.transformOrigin = Item.TopLeft
            appLogic.canvas.scale = appLogic.canvasContainer.scale
            appLogic.canvas.x = appLogic.canvasContainer.offsetX
            appLogic.canvas.y = appLogic.canvasContainer.offsetY
        }
    }

    function updateStatusBar() {
        if (!appLogic.statusBar) return
        var pageLabel = appLogic.statusBar.findChild ? appLogic.statusBar.findChild(Label, "pageLabel") : null
        if (pageLabel) pageLabel.text = "页面: " + (pages && pages[currentPageIndex] ? pages[currentPageIndex].name : "无")
        var componentLabel = appLogic.statusBar.findChild ? appLogic.statusBar.findChild(Label, "componentLabel") : null
        if (componentLabel) componentLabel.text = "组件: " + (appLogic.canvas ? appLogic.canvas.children.length : 0)
        var scaleLabel = appLogic.statusBar.findChild ? appLogic.statusBar.findChild(Label, "scaleLabel") : null
        if (scaleLabel) scaleLabel.text = "缩放: " + Math.round((appLogic.canvasContainer ? appLogic.canvasContainer.scale : 1) * 100) + "%"
    }

    // 其余函数直接迁移自原始 js（略有调整以通过 appLogic 的属性访问 QML 对象）
    function createCanvasComponent(name, x, y, width, height, color) {
        if (!globalObjects || !globalObjects.canvasComponent) return null
        var component = globalObjects.canvasComponent.createObject(appLogic.canvas)
        if (component) {
            component.name = name
            component.x = x
            component.y = y
            component.width = width
            component.height = height
            component.color = color
            return component
        }
        return null
    }

    function getSelectedComponent() {
        if (!appLogic.canvas) return null
        for (var i = 0; i < appLogic.canvas.children.length; i++) {
            var child = appLogic.canvas.children[i]
            if (child.item && child.item.selected) return child.item
        }
        return null
    }

    function getComponentId(component) { return component.name + "_" + Date.now() }

    function showNotification(message, type) { console.log(type + ": " + message) }

    // 以下为数据绑定相关（保留简单 setInterval 实现）
    function applyDataBinding() {
        var selectedComponent = getSelectedComponent()
        if (!selectedComponent) { showNotification("请先选择一个组件", "warning"); return }
        var tagName = appLogic.tagComboBox ? appLogic.tagComboBox.currentText : ""
        if (tagName === "选择点位") { showNotification("请选择一个数据点位", "warning"); return }
        var property = appLogic.propertyComboBox ? appLogic.propertyComboBox.currentText : ""
        var bindingType = appLogic.bindingTypeComboBox ? appLogic.bindingTypeComboBox.currentText : "实时绑定"
        var updateFrequency = appLogic.updateFrequencyComboBox ? appLogic.updateFrequencyComboBox.currentText : "1s"
        var historyEnabled = appLogic.historyDataCheckBox ? appLogic.historyDataCheckBox.checked : false
        var trendEnabled = appLogic.trendChartCheckBox ? appLogic.trendChartCheckBox.checked : false
        var expression = appLogic.bindingExpressionField ? appLogic.bindingExpressionField.text : ""
        var bindingConfig = { component: selectedComponent, tagName: tagName, property: property, bindingType: bindingType, updateFrequency: updateFrequency, historyEnabled: historyEnabled, trendEnabled: trendEnabled, expression: expression }
        var componentId = getComponentId(selectedComponent)
        appLogic.dataBindings[componentId] = bindingConfig
        startDataUpdate(componentId, bindingConfig)
        showNotification("数据绑定成功", "success")
    }

    function removeDataBinding() {
        var selectedComponent = getSelectedComponent()
        if (!selectedComponent) { showNotification("请先选择一个组件", "warning"); return }
        var componentId = getComponentId(selectedComponent)
        if (appLogic.dataBindings[componentId]) {
            stopDataUpdate(componentId)
            delete appLogic.dataBindings[componentId]
            showNotification("数据绑定已解除", "success")
        } else {
            showNotification("该组件没有数据绑定", "info")
        }
    }

    function getUpdateIntervalMs(frequency) {
        var intervals = { "100ms":100, "200ms":200, "500ms":500, "1s":1000, "2s":2000, "5s":5000 }
        return intervals[frequency] || 1000
    }

    function startDataUpdate(componentId, bindingConfig) {
        var updateInterval = getUpdateIntervalMs(bindingConfig.updateFrequency)
        bindingConfig.timer = setInterval(function() { updateComponentFromData(bindingConfig) }, updateInterval)
    }

    function stopDataUpdate(componentId) {
        var bindingConfig = appLogic.dataBindings[componentId]
        if (bindingConfig && bindingConfig.timer) { clearInterval(bindingConfig.timer); bindingConfig.timer = null }
    }

    function updateComponentFromData(bindingConfig) {
        if (!bindingConfig || !bindingConfig.component) return
        var tagValue = getSimulatedTagValue(bindingConfig.tagName)
        switch (bindingConfig.bindingType) {
            case "实时绑定": updateComponentProperty(bindingConfig.component, bindingConfig.property, tagValue); break
            default:
                if (bindingConfig.expression) {
                    var result = evaluateExpression(bindingConfig.expression, tagValue)
                    updateComponentProperty(bindingConfig.component, bindingConfig.property, result)
                }
                break
        }
    }

    function updateComponentProperty(component, property, value) {
        switch (property) {
            case "填充色":
                if (typeof value === "number") component.color = value > 50 ? "#F44336" : "#4CAF50"
                else if (typeof value === "string") component.color = value
                break
            case "位置": if (typeof value === "number") component.x = 100 + value * 2; break
            case "大小": if (typeof value === "number") { component.width = 100 + value * 0.5; component.height = 100 + value * 0.5 } break
            case "旋转": if (typeof value === "number") component.rotation = value; break
            case "透明度": if (typeof value === "number") component.opacity = value / 100; break
        }
    }

    function getSimulatedTagValue(tagName) {
        var tagValues = { "tag1": Math.random()*100, "tag2": Math.random()*50+50, "tag3": Math.random()*360, "tag4": Math.random()*100, "tag5": Math.random()>0.5?1:0 }
        return tagValues[tagName] || 0
    }

    function evaluateExpression(expression, value) {
        try { var evalExpression = expression.replace(/value/g, value); return eval(evalExpression) } catch (e) { console.error("表达式评估错误:", e); return value }
    }

    // 页面管理相关
    property int currentPageIndex: 0
    property var pages: [ { id:1, name: "页面 1", components: [] }, { id:2, name: "页面 2", components: [] } ]

    function createNewPage() {
        var newPageId = appLogic.pages.length + 1
        var newPageName = "页面 " + newPageId
        var newPage = { id: newPageId, name: newPageName, components: [] }
        appLogic.pages.push(newPage)
        if (appLogic.pageModel) appLogic.pageModel.append({ name: newPageName, type: "page", active: false })
        switchPage(appLogic.pages.length - 1)
        showNotification("页面创建成功", "success")
    }

    function deleteCurrentPage() {
        if (appLogic.pages.length <= 1) { showNotification("至少需要保留一个页面", "warning"); return }
        if (appLogic.pageModel) appLogic.pageModel.remove(appLogic.currentPageIndex)
        appLogic.pages.splice(appLogic.currentPageIndex, 1)
        switchPage(0)
        showNotification("页面删除成功", "success")
    }

    function renameCurrentPage() {
        // rename via prompt not available in Qt Quick (leave as no-op or implement dialog)
        showNotification("页面重命名功能暂未实现交互式输入", "info")
    }

    function switchPage(index) {
        if (!appLogic.pageModel) { appLogic.currentPageIndex = index; return }
        for (var i = 0; i < appLogic.pageModel.count; i++) appLogic.pageModel.set(i, { active: false })
        appLogic.pageModel.set(index, { active: true })
        appLogic.currentPageIndex = index
        updateStatusBar()
        clearCanvas()
        loadPageComponents(index)
        showNotification("已切换到页面 " + appLogic.pages[index].name, "info")
    }

    function clearCanvas() {
        if (!appLogic.canvas) return
        for (var i = appLogic.canvas.children.length - 1; i >= 0; i--) appLogic.canvas.children[i].destroy()
    }

    function loadPageComponents(pageIndex) {
        var page = appLogic.pages[pageIndex]
        if (!page) return
        page.components.forEach(function(componentData) {
            createCanvasComponent(componentData.name, componentData.x, componentData.y, componentData.width, componentData.height, componentData.color)
        })
    }

    function saveCurrentPage() {
        var page = appLogic.pages[appLogic.currentPageIndex]
        if (!page) return
        page.components = []
        if (!appLogic.canvas) return
        for (var i = 0; i < appLogic.canvas.children.length; i++) {
            var child = appLogic.canvas.children[i]
            if (child.item) page.components.push({ name: child.item.name, x: child.x, y: child.y, width: child.width, height: child.height, color: child.item.color })
        }
        showNotification("页面保存成功", "success")
    }

    function newProject() {
        // simplified non-interactive implementation
        appLogic.pages = [ { id:1, name: "页面 1", components: [] } ]
        if (appLogic.pageModel) { appLogic.pageModel.clear(); appLogic.pageModel.append({ name: "页面 1", type: "page", active: true }) }
        appLogic.currentPageIndex = 0
        clearCanvas()
        showNotification("项目创建成功", "success")
    }

    function openProject() { showNotification("项目加载模拟完成", "info") }
    function saveProject() { showNotification("项目保存模拟完成", "success") }
    function saveProjectAs() { showNotification("项目另存为模拟完成", "success") }
    function exportProject() { showNotification("项目导出模拟完成", "success") }
    function importProject() { showNotification("项目导入模拟完成", "success") }

    function initialize() {
        // 可在此初始化数据点位/状态
        updateCanvasTransform()
        updateStatusBar()
    }
}
