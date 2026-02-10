import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: pageManager
    
    // 页面数据
    property var pages: [
        { id: 1, name: "页面 1", components: [] }
    ]
    
    property int currentPageIndex: 0
    property var pageModel: null
    
    // 初始化
    function initialize() {
        console.log("PageManager initialized")
    }
    
    // 重置页面
    function resetPages() {
        pages = [
            { id: 1, name: "页面 1", components: [] }
        ]
        currentPageIndex = 0
        console.log("Pages reset")
    }
    
    // 新建页面
    function createNewPage() {
        const newPageId = pages.length + 1
        const newPageName = "页面 " + newPageId
        
        const newPage = {
            id: newPageId,
            name: newPageName,
            components: []
        }
        
        pages.push(newPage)
        
        if (pageModel) {
            pageModel.append({ name: newPageName, type: "page", active: false })
        }
        
        switchPage(pages.length - 1)
        console.log("Page created:", newPageName)
        return newPage
    }
    
    // 删除页面
    function deletePage(index) {
        if (pages.length <= 1) {
            console.log("Cannot delete last page")
            return false
        }
        
        if (pageModel) {
            pageModel.remove(index)
        }
        
        pages.splice(index, 1)
        
        if (currentPageIndex >= index) {
            currentPageIndex = Math.max(0, currentPageIndex - 1)
        }
        
        switchPage(currentPageIndex)
        console.log("Page deleted at index:", index)
        return true
    }
    
    // 重命名页面
    function renamePage(index, newName) {
        if (index >= 0 && index < pages.length) {
            pages[index].name = newName
            if (pageModel) {
                pageModel.set(index, { name: newName, type: "page", active: index === currentPageIndex })
            }
            console.log("Page renamed:", newName)
            return true
        }
        return false
    }
    
    // 切换页面
    function switchPage(index) {
        if (index >= 0 && index < pages.length) {
            // 更新模型中的活动状态
            if (pageModel) {
                for (let i = 0; i < pageModel.count; i++) {
                    pageModel.set(i, { active: i === index })
                }
            }
            
            currentPageIndex = index
            console.log("Switched to page:", pages[index].name)
            return true
        }
        return false
    }
    
    // 保存当前页面
    function saveCurrentPage(components) {
        if (currentPageIndex >= 0 && currentPageIndex < pages.length) {
            pages[currentPageIndex].components = components
            console.log("Current page saved:", pages[currentPageIndex].name)
            return true
        }
        return false
    }
    
    // 保存所有页面
    function saveAllPages() {
        console.log("All pages saved")
        return true
    }
    
    // 加载页面组件
    function loadPageComponents(index) {
        if (index >= 0 && index < pages.length) {
            console.log("Loading components for page:", pages[index].name)
            return pages[index].components
        }
        return []
    }
    
    // 获取当前页面
    function getCurrentPage() {
        if (currentPageIndex >= 0 && currentPageIndex < pages.length) {
            return pages[currentPageIndex]
        }
        return null
    }
    
    // 设置页面模型
    function setPageModel(model) {
        pageModel = model
        console.log("Page model set")
    }
}