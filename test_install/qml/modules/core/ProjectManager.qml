import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: projectManager
    visible: false

    // Project properties
    property var currentProject: null
    property var projectTemplates: [
        {
            name: "Empty Project",
            description: "Blank project with no pre-defined components",
            pages: [
                {
                    name: "Main Page",
                    layout: []
                }
            ],
            theme: "Default"
        },
        {
            name: "Control Room Dashboard",
            description: "Complete control room dashboard with multiple pages",
            pages: [
                {
                    name: "Main Overview",
                    layout: [
                        { type: "BasicComponents.TextLabel", x: 20, y: 20, width: 200, height: 40, text: "Control Room Dashboard" },
                        { type: "ChartComponents.TrendChart", x: 50, y: 80, width: 400, height: 300, tagName: "mainTrend" },
                        { type: "IndustrialComponents.Gauge", x: 480, y: 80, width: 200, height: 200, tagName: "pressure" },
                        { type: "IndustrialComponents.Gauge", x: 480, y: 300, width: 200, height: 200, tagName: "temperature" }
                    ]
                },
                {
                    name: "Process Control",
                    layout: [
                        { type: "BasicComponents.TextLabel", x: 20, y: 20, width: 200, height: 40, text: "Process Control" },
                        { type: "IndustrialComponents.Tank", x: 50, y: 80, width: 120, height: 180, tagName: "tank1" },
                        { type: "IndustrialComponents.Pump", x: 200, y: 120, width: 120, height: 120, tagName: "pump1" },
                        { type: "IndustrialComponents.Valve", x: 350, y: 120, width: 100, height: 100, tagName: "valve1" },
                        { type: "IndustrialComponents.IndustrialButton", x: 50, y: 280, width: 120, height: 60, text: "Start", tagName: "startBtn" },
                        { type: "IndustrialComponents.IndustrialButton", x: 190, y: 280, width: 120, height: 60, text: "Stop", tagName: "stopBtn" }
                    ]
                },
                {
                    name: "Alarm Monitoring",
                    layout: [
                        { type: "BasicComponents.TextLabel", x: 20, y: 20, width: 200, height: 40, text: "Alarm Monitoring" },
                        { type: "IndustrialComponents.Indicator", x: 50, y: 80, width: 60, height: 60, tagName: "alarm1" },
                        { type: "BasicComponents.TextLabel", x: 120, y: 80, width: 200, height: 40, text: "High Pressure" },
                        { type: "IndustrialComponents.Indicator", x: 50, y: 160, width: 60, height: 60, tagName: "alarm2" },
                        { type: "BasicComponents.TextLabel", x: 120, y: 160, width: 200, height: 40, text: "High Temperature" },
                        { type: "IndustrialComponents.Indicator", x: 50, y: 240, width: 60, height: 60, tagName: "alarm3" },
                        { type: "BasicComponents.TextLabel", x: 120, y: 240, width: 200, height: 40, text: "Low Level" }
                    ]
                }
            ],
            theme: "Default"
        },
        {
            name: "Energy Management System",
            description: "Energy management system with consumption tracking",
            pages: [
                {
                    name: "Energy Dashboard",
                    layout: [
                        { type: "BasicComponents.TextLabel", x: 20, y: 20, width: 200, height: 40, text: "Energy Management" },
                        { type: "ChartComponents.BarChart", x: 50, y: 80, width: 400, height: 300, tagName: "energyConsumption" },
                        { type: "IndustrialComponents.Indicator", x: 480, y: 80, width: 60, height: 60, tagName: "powerStatus" },
                        { type: "BasicComponents.TextLabel", x: 550, y: 80, width: 100, height: 40, text: "Power Status" },
                        { type: "ChartComponents.TrendChart", x: 50, y: 400, width: 550, height: 300, tagName: "powerTrend" }
                    ]
                }
            ],
            theme: "Default"
        }
    ]

    // Version control properties
    property var versionHistory: []
    property int maxVersionHistory: 50
    property int currentVersionIndex: -1

    // Initialize project manager
    function init() {
        // Initialization code if needed
    }

    // Create new project from template
    function createProjectFromTemplate(templateName) {
        const template = projectTemplates.find(t => t.name === templateName);
        if (!template) return null;

        // Create new project
        const project = {
            name: "New Project",
            description: template.description,
            creationDate: new Date().toISOString(),
            lastModified: new Date().toISOString(),
            pages: JSON.parse(JSON.stringify(template.pages)),
            theme: template.theme,
            versionHistory: []
        };

        currentProject = project;
        saveVersion("Initial project creation");
        return project;
    }

    // Save project
    function saveProject() {
        if (!currentProject) return false;

        currentProject.lastModified = new Date().toISOString();
        saveVersion("Project saved");
        // Here you would typically save to file system
        return true;
    }

    // Open project
    function openProject(projectData) {
        currentProject = projectData;
        versionHistory = projectData.versionHistory || [];
        currentVersionIndex = versionHistory.length - 1;
        return currentProject;
    }

    // Save version for version control
    function saveVersion(description) {
        if (!currentProject) return;

        // Create version snapshot
        const version = {
            id: Date.now(),
            timestamp: new Date().toISOString(),
            description: description,
            snapshot: JSON.parse(JSON.stringify(currentProject.pages))
        };

        // Add to version history
        if (currentVersionIndex < versionHistory.length - 1) {
            // Remove future versions if we're not at the latest
            versionHistory = versionHistory.slice(0, currentVersionIndex + 1);
        }

        versionHistory.push(version);

        // Limit history size
        if (versionHistory.length > maxVersionHistory) {
            versionHistory.shift();
        } else {
            currentVersionIndex++;
        }

        // Update project's version history
        currentProject.versionHistory = versionHistory;
    }

    // Rollback to previous version
    function rollbackToVersion(index) {
        if (!currentProject || index < 0 || index >= versionHistory.length) return false;

        const version = versionHistory[index];
        if (version) {
            currentProject.pages = JSON.parse(JSON.stringify(version.snapshot));
            currentVersionIndex = index;
            return true;
        }
        return false;
    }

    // Get version history
    function getVersionHistory() {
        return versionHistory;
    }

    // Export project for offline use
    function exportProject() {
        if (!currentProject) return null;

        const exportData = {
            project: currentProject,
            exportDate: new Date().toISOString(),
            version: "1.0"
        };

        return JSON.stringify(exportData, null, 2);
    }

    // Import project from offline data
    function importProject(exportData) {
        try {
            const data = JSON.parse(exportData);
            if (data.project) {
                return openProject(data.project);
            }
        } catch (e) {
            console.error("Failed to import project:", e);
        }
        return null;
    }

    // Get project templates
    function getProjectTemplates() {
        return projectTemplates;
    }

    // Add custom project template
    function addProjectTemplate(name, description, pages, theme) {
        const template = {
            name: name,
            description: description,
            pages: pages || [],
            theme: theme || "Default"
        };
        projectTemplates.push(template);
        return template;
    }

    // Remove project template
    function removeProjectTemplate(index) {
        if (index >= 0 && index < projectTemplates.length) {
            projectTemplates.splice(index, 1);
            return true;
        }
        return false;
    }

    // Update project properties
    function updateProjectProperties(properties) {
        if (!currentProject) return false;

        for (const [key, value] of Object.entries(properties)) {
            if (currentProject.hasOwnProperty(key)) {
                currentProject[key] = value;
            }
        }

        currentProject.lastModified = new Date().toISOString();
        saveVersion("Project properties updated");
        return true;
    }

    // Get current project
    function getCurrentProject() {
        return currentProject;
    }

    // Close project
    function closeProject() {
        currentProject = null;
        versionHistory = [];
        currentVersionIndex = -1;
    }

    // Check if project has unsaved changes
    function hasUnsavedChanges() {
        // This would typically compare current state with last saved state
        return false;
    }
}
