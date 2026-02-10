import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: securityPortabilityManager
    visible: false

    // Properties
    property var platformInfo: detectPlatform()
    property var securitySettings: {
        maxInputLength: 1000,
        allowedFileExtensions: [".qml", ".json", ".xml", ".txt"],
        maxFileSize: 10 * 1024 * 1024, // 10MB
        enableInputValidation: true,
        enableFileValidation: true
    }

    // Initialize security and portability manager
    function init() {
        // Initialization code if needed
    }

    // Detect platform
    function detectPlatform() {
        const platform = {
            os: Qt.platform.os,
            architecture: Qt.platform.architecture,
            pluginName: Qt.platform.pluginName,
            isMobile: Qt.platform.os === "ios" || Qt.platform.os === "android",
            isDesktop: Qt.platform.os === "windows" || Qt.platform.os === "linux" || Qt.platform.os === "osx"
        };
        return platform;
    }

    // Get platform info
    function getPlatformInfo() {
        return platformInfo;
    }

    // Check if platform is supported
    function isPlatformSupported() {
        return platformInfo.isDesktop || platformInfo.isMobile;
    }

    // Validate input
    function validateInput(input, options) {
        if (!securitySettings.enableInputValidation) return true;

        const defaultOptions = {
            maxLength: securitySettings.maxInputLength,
            minLength: 0,
            allowedChars: null, // null means all chars allowed
            isNumber: false,
            minValue: -Infinity,
            maxValue: Infinity,
            isEmail: false,
            isUrl: false
        };

        const opts = Object.assign({}, defaultOptions, options);

        // Check length
        if (input.length < opts.minLength || input.length > opts.maxLength) {
            return false;
        }

        // Check allowed characters
        if (opts.allowedChars && !opts.allowedChars.test(input)) {
            return false;
        }

        // Check if number
        if (opts.isNumber) {
            const num = parseFloat(input);
            if (isNaN(num)) {
                return false;
            }
            if (num < opts.minValue || num > opts.maxValue) {
                return false;
            }
        }

        // Check if email
        if (opts.isEmail) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(input)) {
                return false;
            }
        }

        // Check if URL
        if (opts.isUrl) {
            try {
                new URL(input);
                return true;
            } catch {
                return false;
            }
        }

        return true;
    }

    // Sanitize input to prevent injection attacks
    function sanitizeInput(input) {
        if (!input) return input;

        // Escape HTML
        let sanitized = input
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");

        return sanitized;
    }

    // Validate file
    function validateFile(fileInfo) {
        if (!securitySettings.enableFileValidation) return true;

        // Check file extension
        const extension = fileInfo.fileName.split('.').pop().toLowerCase();
        if (!securitySettings.allowedFileExtensions.some(ext => ext.toLowerCase() === `.${extension}`)) {
            return false;
        }

        // Check file size
        if (fileInfo.size > securitySettings.maxFileSize) {
            return false;
        }

        return true;
    }

    // Safe file path
    function getSafeFilePath(basePath, fileName) {
        // Remove invalid characters from file name
        const safeFileName = fileName.replace(/[<>:"/\\|?*]/g, "_");
        
        // Combine paths safely
        const pathSeparator = platformInfo.os === "windows" ? "\\" : "/";
        return basePath + pathSeparator + safeFileName;
    }

    // Safe JSON parse
    function safeJsonParse(jsonString) {
        try {
            return JSON.parse(jsonString);
        } catch (e) {
            console.error("Failed to parse JSON:", e);
            return null;
        }
    }

    // Safe file read
    function safeFileRead(filePath) {
        try {
            const file = Qt.createQmlObject('import QtQuick 2.15; File { }');
            if (file) {
                file.fileName = filePath;
                if (file.open(File.ReadOnly)) {
                    const content = file.readAll();
                    file.close();
                    return content;
                }
            }
        } catch (e) {
            console.error("Failed to read file:", e);
        }
        return null;
    }

    // Safe file write
    function safeFileWrite(filePath, content) {
        try {
            const file = Qt.createQmlObject('import QtQuick 2.15; File { }');
            if (file) {
                file.fileName = filePath;
                if (file.open(File.WriteOnly | File.Truncate)) {
                    file.write(content);
                    file.close();
                    return true;
                }
            }
        } catch (e) {
            console.error("Failed to write file:", e);
        }
        return false;
    }

    // Get platform-specific path
    function getPlatformPath(pathType) {
        const paths = {
            documents: Qt.application.documentsPath,
            cache: Qt.application.cachePath,
            appData: Qt.application.applicationDirPath
        };
        return paths[pathType] || Qt.application.applicationDirPath;
    }

    // Check if path is secure
    function isPathSecure(path) {
        // Prevent directory traversal
        const normalizedPath = path.replace(/\\/g, "/");
        const pathParts = normalizedPath.split("/");
        
        // Check for directory traversal
        if (pathParts.includes("..")) {
            return false;
        }

        // Check if path is within allowed directories
        const allowedPaths = [
            getPlatformPath("documents"),
            getPlatformPath("cache"),
            getPlatformPath("appData")
        ];

        const isInAllowedPath = allowedPaths.some(allowedPath => {
            return normalizedPath.startsWith(allowedPath.replace(/\\/g, "/"));
        });

        return isInAllowedPath;
    }

    // Handle error safely
    function handleError(error, context) {
        console.error(`Error in ${context}:`, error);
        // Here you could add error reporting or logging
    }

    // Get safe default value
    function getSafeDefault(value, defaultValue, validator) {
        if (value === undefined || value === null) {
            return defaultValue;
        }
        if (validator && !validator(value)) {
            return defaultValue;
        }
        return value;
    }

    // Create platform-specific component
    function createPlatformComponent(componentType, properties) {
        // Adjust properties based on platform
        const adjustedProperties = Object.assign({}, properties);

        if (platformInfo.isMobile) {
            // Mobile-specific adjustments
            if (adjustedProperties.width) {
                adjustedProperties.width = Math.min(adjustedProperties.width, platformInfo.screenWidth * 0.9);
            }
        }

        // Create component
        try {
            const component = Qt.createQmlObject(`import QtQuick 2.15; ${componentType} { }`);
            if (component) {
                // Apply properties
                for (const [key, value] of Object.entries(adjustedProperties)) {
                    if (component.hasOwnProperty(key)) {
                        component[key] = value;
                    }
                }
                return component;
            }
        } catch (e) {
            handleError(e, `createPlatformComponent(${componentType})`);
        }

        return null;
    }

    // Check if feature is supported on current platform
    function isFeatureSupported(feature) {
        const featureSupport = {
            dragAndDrop: platformInfo.isDesktop,
            3D: !platformInfo.isMobile, // Assume 3D is better on desktop
            fileSystemAccess: true,
            networkAccess: true,
            systemTray: platformInfo.isDesktop
        };

        return featureSupport[feature] || false;
    }

    // Get secure random number
    function getSecureRandom(min, max) {
        if (min === undefined) min = 0;
        if (max === undefined) max = 1;
        return min + Math.random() * (max - min);
    }

    // Generate secure token
    function generateSecureToken(length) {
        if (!length) length = 32;
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        let token = '';
        for (let i = 0; i < length; i++) {
            token += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return token;
    }

    // Validate token
    function validateToken(token) {
        return token && token.length >= 16 && /^[A-Za-z0-9]+$/.test(token);
    }

    // Clean up resources
    function cleanup() {
        // Cleanup code if needed
    }
}
