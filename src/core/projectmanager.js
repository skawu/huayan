import QtQuick 2.15

pragma Singleton

QtObject {
    id: projectManager
    
    // 项目属性
    property string projectName: "未命名项目"
    property string projectPath: ""
    property string projectVersion: "1.0.0"
    property date createdAt: new Date()
    property date lastModified: new Date()
    
    // 项目配置
    property var configuration: ({
        "screens": [],
        "components": [],
        "tags": [],
        "connections": [],
        "settings": {
            "updateInterval": 500,
            "theme": "industrial_dark",
            "language": "zh-CN",
            "fullscreen": false
        }
    })
    
    // 项目状态
    property bool isProjectLoaded: false
    property bool isProjectModified: false
    
    // 信号定义
    signal projectCreated()
    signal projectLoaded(string path)
    signal projectSaved(string path)
    signal projectModified()
    
    // 创建新项目
    function createNewProject(name) {
        projectName = name || "未命名项目"
        projectPath = ""
        projectVersion = "1.0.0"
        createdAt = new Date()
        lastModified = new Date()
        isProjectLoaded = true
        isProjectModified = false
        
        // 初始化空配置
        configuration = {
            "screens": [],
            "components": [],
            "tags": [],
            "connections": [],
            "settings": {
                "updateInterval": 500,
                "theme": "industrial_dark",
                "language": "zh-CN",
                "fullscreen": false
            }
        }
        
        console.log("创建新项目:", projectName)
        projectCreated()
    }
    
    // 加载项目
    function loadProject(filePath) {
        try {
            // 模拟从文件加载项目
            const fileContent = loadFromFile(filePath)
            const projectData = JSON.parse(fileContent)
            
            projectName = projectData.project.name
            projectPath = filePath
            projectVersion = projectData.project.version
            createdAt = new Date(projectData.project.created)
            lastModified = new Date(projectData.project.modified)
            configuration = projectData.configuration
            
            isProjectLoaded = true
            isProjectModified = false
            
            console.log("项目加载成功:", projectName)
            projectLoaded(filePath)
            
        } catch (error) {
            console.error("项目加载失败:", error)
            return false
        }
        return true
    }
    
    // 保存项目
    function saveProject(filePath) {
        if (!filePath && !projectPath) {
            console.warn("没有指定保存路径")
            return false
        }
        
        const savePath = filePath || projectPath
        lastModified = new Date()
        
        const projectData = {
            "project": {
                "name": projectName,
                "version": projectVersion,
                "created": createdAt.toISOString(),
                "modified": lastModified.toISOString()
            },
            "configuration": configuration
        }
        
        try {
            const jsonData = JSON.stringify(projectData, null, 2)
            saveToFile(savePath, jsonData)
            
            projectPath = savePath
            isProjectModified = false
            
            console.log("项目保存成功:", savePath)
            projectSaved(savePath)
            
        } catch (error) {
            console.error("项目保存失败:", error)
            return false
        }
        return true
    }
    
    // 导出项目为运行时包
    function exportProject(outputPath) {
        if (!isProjectLoaded) {
            console.warn("没有可导出的项目")
            return false
        }
        
        const exportData = {
            "runtime": {
                "projectName": projectName,
                "version": projectVersion,
                "exportDate": new Date().toISOString()
            },
            "screens": configuration.screens,
            "components": configuration.components,
            "tags": configuration.tags,
            "settings": configuration.settings
        }
        
        try {
            const jsonData = JSON.stringify(exportData, null, 2)
            const exportPath = outputPath || projectName + ".hyruntime"
            saveToFile(exportPath, jsonData)
            
            console.log("项目导出成功:", exportPath)
            return true
            
        } catch (error) {
            console.error("项目导出失败:", error)
            return false
        }
    }
    
    // 导入运行时包
    function importRuntimePackage(packagePath) {
        try {
            const fileContent = loadFromFile(packagePath)
            const runtimeData = JSON.parse(fileContent)
            
            projectName = runtimeData.runtime.projectName
            projectVersion = runtimeData.runtime.version
            configuration.screens = runtimeData.screens
            configuration.components = runtimeData.components
            configuration.tags = runtimeData.tags
            configuration.settings = runtimeData.settings
            
            isProjectLoaded = true
            isProjectModified = false
            
            console.log("运行时包导入成功:", projectName)
            return true
            
        } catch (error) {
            console.error("运行时包导入失败:", error)
            return false
        }
    }
    
    // 标记项目已修改
    function markAsModified() {
        if (isProjectLoaded && !isProjectModified) {
            isProjectModified = true
            projectModified()
        }
    }
    
    // 添加屏幕
    function addScreen(screenData) {
        if (!configuration.screens) {
            configuration.screens = []
        }
        configuration.screens.push(screenData)
        markAsModified()
    }
    
    // 添加组件
    function addComponent(componentData) {
        if (!configuration.components) {
            configuration.components = []
        }
        configuration.components.push(componentData)
        markAsModified()
    }
    
    // 添加标签
    function addTag(tagData) {
        if (!configuration.tags) {
            configuration.tags = []
        }
        configuration.tags.push(tagData)
        markAsModified()
    }
    
    // 获取项目统计信息
    function getProjectStats() {
        return {
            "screenCount": configuration.screens ? configuration.screens.length : 0,
            "componentCount": configuration.components ? configuration.components.length : 0,
            "tagCount": configuration.tags ? configuration.tags.length : 0,
            "lastModified": lastModified,
            "isModified": isProjectModified
        }
    }
    
    // 验证项目完整性
    function validateProject() {
        const issues = []
        
        if (!configuration.screens || configuration.screens.length === 0) {
            issues.push("项目缺少屏幕定义")
        }
        
        if (!configuration.tags || configuration.tags.length === 0) {
            issues.push("项目缺少标签定义")
        }
        
        // 验证组件引用的有效性
        if (configuration.components) {
            for (const component of configuration.components) {
                if (component.bindings) {
                    for (const bindingKey in component.bindings) {
                        const tagName = component.bindings[bindingKey]
                        if (!configuration.tags.some(tag => tag.name === tagName)) {
                            issues.push(`组件 "${component.id}" 引用了不存在的标签 "${tagName}"`)
                        }
                    }
                }
            }
        }
        
        return {
            "isValid": issues.length === 0,
            "issues": issues
        }
    }
    
    // 私有辅助函数
    function loadFromFile(filePath) {
        // 实际实现中这里应该是文件读取逻辑
        // 目前返回模拟数据
        return JSON.stringify({
            "project": {
                "name": "示例项目",
                "version": "1.0.0",
                "created": "2026-02-25T10:00:00Z",
                "modified": "2026-02-25T10:00:00Z"
            },
            "configuration": {
                "screens": [],
                "components": [],
                "tags": [],
                "settings": {
                    "updateInterval": 500,
                    "theme": "industrial_dark"
                }
            }
        })
    }
    
    function saveToFile(filePath, content) {
        // 实际实现中这里应该是文件写入逻辑
        console.log("保存到文件:", filePath)
        console.log("内容长度:", content.length)
    }
}