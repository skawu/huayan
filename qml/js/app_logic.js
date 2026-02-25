// 全部为纯 JavaScript，供 main.qml 通过 Qt.include 加载

// 更新画布变换
function updateCanvasTransform() {
    if (canvas) {
        canvas.transformOrigin = Item.TopLeft
        canvas.scale = canvasContainer.scale
        canvas.x = canvasContainer.offsetX
        canvas.y = canvasContainer.offsetY
    }
}

// 更新状态栏
function updateStatusBar() {
    const pageLabel = statusBar.findChild(Label, "pageLabel")
    if (pageLabel) {
        pageLabel.text = "页面: " + (pages[currentPageIndex] ? pages[currentPageIndex].name : "无")
    }
    const componentLabel = statusBar.findChild(Label, "componentLabel")
    if (componentLabel) {
        componentLabel.text = "组件: " + canvas.children.length
    }
    const scaleLabel = statusBar.findChild(Label, "scaleLabel")
    if (scaleLabel) {
        scaleLabel.text = "缩放: " + Math.round(canvasContainer.scale * 100) + "%"
    }
}

// 更新属性面板
function updatePropertyPanel(component) {
    if (!component) return
    const xSpinBox = propertyPanel.findChild(SpinBox, "xSpinBox")
    const ySpinBox = propertyPanel.findChild(SpinBox, "ySpinBox")
    const widthSpinBox = propertyPanel.findChild(SpinBox, "widthSpinBox")
    const heightSpinBox = propertyPanel.findChild(SpinBox, "heightSpinBox")
    if (xSpinBox) xSpinBox.value = component.x
    if (ySpinBox) ySpinBox.value = component.y
    if (widthSpinBox) widthSpinBox.value = component.width
    if (heightSpinBox) heightSpinBox.value = component.height
}

// CanvasComponent 工厂函数
function createCanvasComponent(name, x, y, width, height, color) {
    const component = canvasComponent.createObject(canvas)
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

// 数据绑定管理
var dataBindings = {}

// 应用数据绑定
function applyDataBinding() {
    const selectedComponent = getSelectedComponent()
    if (!selectedComponent) {
        showNotification("请先选择一个组件", "warning")
        return
    }
    const tagName = tagComboBox.currentText
    if (tagName === "选择点位") {
        showNotification("请选择一个数据点位", "warning")
        return
    }
    const property = propertyComboBox.currentText
    const bindingType = bindingTypeComboBox.currentText
    const updateFrequency = updateFrequencyComboBox.currentText
    const historyEnabled = historyDataCheckBox.checked
    const trendEnabled = trendChartCheckBox.checked
    const expression = bindingExpressionField.text
    const bindingConfig = {
        component: selectedComponent,
        tagName: tagName,
        property: property,
        bindingType: bindingType,
        updateFrequency: updateFrequency,
        historyEnabled: historyEnabled,
        trendEnabled: trendEnabled,
        expression: expression
    }
    const componentId = getComponentId(selectedComponent)
    dataBindings[componentId] = bindingConfig
    startDataUpdate(componentId, bindingConfig)
    showNotification("数据绑定成功", "success")
}

// 移除数据绑定
function removeDataBinding() {
    const selectedComponent = getSelectedComponent()
    if (!selectedComponent) {
        showNotification("请先选择一个组件", "warning")
        return
    }
    const componentId = getComponentId(selectedComponent)
    if (dataBindings[componentId]) {
        stopDataUpdate(componentId)
        delete dataBindings[componentId]
        showNotification("数据绑定已解除", "success")
    } else {
        showNotification("该组件没有数据绑定", "info")
    }
}

// 启动/停止/更新 数据绑定（简化实现）
function startDataUpdate(componentId, bindingConfig) {
    const updateInterval = getUpdateIntervalMs(bindingConfig.updateFrequency)
    bindingConfig.timer = setInterval(function() {
        updateComponentFromData(bindingConfig)
    }, updateInterval)
}

function stopDataUpdate(componentId) {
    const bindingConfig = dataBindings[componentId]
    if (bindingConfig && bindingConfig.timer) {
        clearInterval(bindingConfig.timer)
        bindingConfig.timer = null
    }
}

function updateComponentFromData(bindingConfig) {
    if (!bindingConfig || !bindingConfig.component) return
    const tagValue = getSimulatedTagValue(bindingConfig.tagName)
    switch (bindingConfig.bindingType) {
        case "实时绑定":
            updateComponentProperty(bindingConfig.component, bindingConfig.property, tagValue)
            break
        case "条件绑定":
        case "表达式绑定":
            if (bindingConfig.expression) {
                const result = evaluateExpression(bindingConfig.expression, tagValue)
                updateComponentProperty(bindingConfig.component, bindingConfig.property, result)
            }
            break
    }
}

function updateComponentProperty(component, property, value) {
    switch (property) {
        case "填充色":
            if (typeof value === "number") {
                component.color = value > 50 ? "#F44336" : "#4CAF50"
            } else if (typeof value === "string") {
                component.color = value
            }
            break
        case "位置":
            if (typeof value === "number") {
                component.x = 100 + value * 2
            }
            break
        case "大小":
            if (typeof value === "number") {
                component.width = 100 + value * 0.5
                component.height = 100 + value * 0.5
            }
            break
        case "旋转":
            if (typeof value === "number") {
                component.rotation = value
            }
            break
        case "透明度":
            if (typeof value === "number") {
                component.opacity = value / 100
            }
            break
    }
}

function getSimulatedTagValue(tagName) {
    const tagValues = {
        "tag1": Math.random() * 100,
        "tag2": Math.random() * 50 + 50,
        "tag3": Math.random() * 360,
        "tag4": Math.random() * 100,
        "tag5": Math.random() > 0.5 ? 1 : 0
    }
    return tagValues[tagName] || 0
}

function evaluateExpression(expression, value) {
    try {
        const evalExpression = expression.replace(/value/g, value)
        return eval(evalExpression)
    } catch (e) {
        console.error("表达式评估错误:", e)
        return value
    }
}

function getUpdateIntervalMs(frequency) {
    const intervals = {
        "100ms": 100,
        "200ms": 200,
        "500ms": 500,
        "1s": 1000,
        "2s": 2000,
        "5s": 5000
    }
    return intervals[frequency] || 1000
}

function getSelectedComponent() {
    for (let i = 0; i < canvas.children.length; i++) {
        const child = canvas.children[i]
        if (child.item && child.item.selected) {
            return child.item
        }
    }
    return null
}

function getComponentId(component) {
    return component.name + "_" + Date.now()
}

function showNotification(message, type) {
    console.log(type + ": " + message)
}

function initializeTags() {
    console.log("数据点位初始化完成")
}

function initialize() {
    initializeTags()
    updateCanvasTransform()
    updateStatusBar()
}

var currentPageIndex = 0
var pages = [
    { id: 1, name: "页面 1", components: [] },
    { id: 2, name: "页面 2", components: [] }
]

function createNewPage() {
    const newPageId = pages.length + 1
    const newPageName = "页面 " + newPageId
    const newPage = { id: newPageId, name: newPageName, components: [] }
    pages.push(newPage)
    pageModel.append({ name: newPageName, type: "page", active: false })
    switchPage(pages.length - 1)
    showNotification("页面创建成功", "success")
}

function deleteCurrentPage() {
    if (pages.length <= 1) {
        showNotification("至少需要保留一个页面", "warning")
        return
    }
    pageModel.remove(currentPageIndex)
    pages.splice(currentPageIndex, 1)
    switchPage(0)
    showNotification("页面删除成功", "success")
}

function renameCurrentPage() {
    const newName = prompt("请输入新的页面名称:", pages[currentPageIndex].name)
    if (newName && newName.trim() !== "") {
        pages[currentPageIndex].name = newName
        pageModel.set(currentPageIndex, { name: newName, type: "page", active: true })
        showNotification("页面重命名成功", "success")
    }
}

function switchPage(index) {
    for (let i = 0; i < pageModel.count; i++) {
        pageModel.set(i, { active: false })
    }
    pageModel.set(index, { active: true })
    currentPageIndex = index
    updateStatusBar()
    clearCanvas()
    loadPageComponents(index)
    showNotification("已切换到页面 " + pages[index].name, "info")
}

function clearCanvas() {
    for (let i = canvas.children.length - 1; i >= 0; i--) {
        canvas.children[i].destroy()
    }
}

function loadPageComponents(pageIndex) {
    const page = pages[pageIndex]
    if (!page) return
    page.components.forEach(function(componentData) {
        createCanvasComponent(
            componentData.name,
            componentData.x,
            componentData.y,
            componentData.width,
            componentData.height,
            componentData.color
        )
    })
}

function saveCurrentPage() {
    const page = pages[currentPageIndex]
    if (!page) return
    page.components = []
    for (let i = 0; i < canvas.children.length; i++) {
        const child = canvas.children[i]
        if (child.item) {
            page.components.push({
                name: child.item.name,
                x: child.x,
                y: child.y,
                width: child.width,
                height: child.height,
                color: child.item.color
            })
        }
    }
    showNotification("页面保存成功", "success")
}

var currentProject = {
    name: "未命名项目",
    version: "1.0",
    created: new Date().toISOString(),
    modified: new Date().toISOString(),
    pages: pages
}

function newProject() {
    if (confirm("新建项目将清除当前项目内容，是否继续？")) {
        pages = [ { id: 1, name: "页面 1", components: [] } ]
        pageModel.clear()
        pageModel.append({ name: "页面 1", type: "page", active: true })
        currentPageIndex = 0
        clearCanvas()
        currentProject = { name: "未命名项目", version: "1.0", created: new Date().toISOString(), modified: new Date().toISOString(), pages: pages }
        showNotification("项目创建成功", "success")
    }
}

function openProject() {
    const projectName = prompt("请输入项目名称:", "示例项目")
    if (projectName) {
        pages = [ { id: 1, name: "主页面", components: [] }, { id: 2, name: "监控页面", components: [] } ]
        pageModel.clear()
        pages.forEach(function(page, index) { pageModel.append({ name: page.name, type: "page", active: index === 0 }) })
        currentPageIndex = 0
        clearCanvas()
        showNotification("项目加载成功", "success")
    }
}

function saveProject() {
    pages.forEach(function(page, index) { const oldIndex = currentPageIndex; switchPage(index); saveCurrentPage() })
    switchPage(currentPageIndex)
    currentProject.modified = new Date().toISOString()
    currentProject.pages = pages
    showNotification("项目保存成功", "success")
}

function saveProjectAs() {
    const newProjectName = prompt("请输入新的项目名称:", currentProject.name)
    if (newProjectName) {
        currentProject.name = newProjectName
        saveProject()
        showNotification("项目另存为成功", "success")
    }
}

function exportProject() {
    saveProject()
    const projectJson = JSON.stringify(currentProject, null, 2)
    console.log("项目导出:", projectJson)
    showNotification("项目导出成功", "success")
}

function importProject() {
    const projectJson = prompt("请粘贴项目JSON:", "{\"name\": \"导入项目\", \"pages\": [...]}")
    if (projectJson) {
        try {
            const importedProject = JSON.parse(projectJson)
            if (importedProject.pages) {
                pages = importedProject.pages
                pageModel.clear()
                pages.forEach(function(page, index) { pageModel.append({ name: page.name, type: "page", active: index === 0 }) })
                currentPageIndex = 0
                clearCanvas()
                showNotification("项目导入成功", "success")
            }
        } catch (e) {
            showNotification("项目导入失败: " + e.message, "error")
        }
    }
}

var alarms = [ { id: 1, tagName: "tag1", message: "温度过高", level: "high", status: "active", time: new Date().toISOString() }, { id: 2, tagName: "tag2", message: "压力异常", level: "medium", status: "active", time: new Date().toISOString() }, { id: 3, tagName: "tag3", message: "流量过低", level: "low", status: "confirmed", time: new Date().toISOString() } ]

function showAlarmManager() {
    const alarmHtml = `...` // abbreviated for brevity in this helper file
    console.log("报警管理界面:", alarmHtml)
    showNotification("报警管理器已打开", "info")
}

function confirmAlarm(alarmId) { const alarm = alarms.find(a => a.id === alarmId); if (alarm) { alarm.status = "confirmed"; showNotification("报警已确认", "success") } }

function addAlarm(tagName, message, level) { const newAlarm = { id: alarms.length + 1, tagName: tagName, message: message, level: level, status: "active", time: new Date().toISOString() }; alarms.push(newAlarm); showNotification("新报警: " + message, "error") }

var trendCharts = [ { id: 1, name: "温度趋势", tags: ["tag1"], type: "real-time" }, { id: 2, name: "压力趋势", tags: ["tag2"], type: "historical" }, { id: 3, name: "多参数趋势", tags: ["tag1", "tag2", "tag3"], type: "real-time" } ]

function showTrendCharts() { console.log("趋势图表管理界面"); showNotification("趋势图表管理器已打开", "info") }

function viewTrend(trendId) { const trend = trendCharts.find(t => t.id === trendId); if (trend) { console.log("查看趋势图表:", trend.name); showNotification("趋势图表: " + trend.name, "info") } }

function createTrend() { const trendName = prompt("请输入趋势图表名称:", "新趋势"); if (trendName) { const newTrend = { id: trendCharts.length + 1, name: trendName, tags: ["tag1"], type: "real-time" }; trendCharts.push(newTrend); showNotification("趋势图表创建成功", "success") } }
