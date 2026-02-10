import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: userFeedbackManager
    visible: false

    // Properties
    property var notifications: []
    property int maxNotifications: 5
    property var dialogStack: []

    // Initialize user feedback manager
    function init() {
        // Initialization code if needed
    }

    // Show notification
    function showNotification(title, message, type, duration) {
        const notification = {
            id: Date.now(),
            title: title,
            message: message,
            type: type || "info", // info, success, warning, error
            duration: duration || 3000,
            timestamp: new Date().toISOString()
        };

        // Add to notifications
        notifications.push(notification);

        // Limit notifications
        if (notifications.length > maxNotifications) {
            notifications.shift();
        }

        // Auto-remove after duration
        setTimeout(function() {
            removeNotification(notification.id);
        }, notification.duration);

        return notification;
    }

    // Remove notification
    function removeNotification(notificationId) {
        const index = notifications.findIndex(n => n.id === notificationId);
        if (index >= 0) {
            notifications.splice(index, 1);
            return true;
        }
        return false;
    }

    // Clear all notifications
    function clearNotifications() {
        notifications = [];
    }

    // Get notifications
    function getNotifications() {
        return notifications;
    }

    // Show dialog
    function showDialog(title, message, type, buttons, callback) {
        const dialog = {
            id: Date.now(),
            title: title,
            message: message,
            type: type || "info", // info, confirm, error, warning
            buttons: buttons || ["OK"],
            callback: callback,
            timestamp: new Date().toISOString()
        };

        dialogStack.push(dialog);
        return dialog;
    }

    // Close dialog
    function closeDialog(dialogId, result) {
        const index = dialogStack.findIndex(d => d.id === dialogId);
        if (index >= 0) {
            const dialog = dialogStack[index];
            dialogStack.splice(index, 1);

            // Call callback if provided
            if (dialog.callback) {
                dialog.callback(result);
            }
            return true;
        }
        return false;
    }

    // Show confirmation dialog
    function showConfirmDialog(title, message, confirmText, cancelText, callback) {
        return showDialog(
            title,
            message,
            "confirm",
            [confirmText || "Yes", cancelText || "No"],
            callback
        );
    }

    // Show error dialog
    function showErrorDialog(title, message, callback) {
        return showDialog(
            title,
            message,
            "error",
            ["OK"],
            callback
        );
    }

    // Show warning dialog
    function showWarningDialog(title, message, callback) {
        return showDialog(
            title,
            message,
            "warning",
            ["OK"],
            callback
        );
    }

    // Show success dialog
    function showSuccessDialog(title, message, callback) {
        return showDialog(
            title,
            message,
            "success",
            ["OK"],
            callback
        );
    }

    // Show input dialog
    function showInputDialog(title, message, defaultValue, callback) {
        const dialog = {
            id: Date.now(),
            title: title,
            message: message,
            type: "input",
            defaultValue: defaultValue || "",
            callback: callback,
            timestamp: new Date().toISOString()
        };

        dialogStack.push(dialog);
        return dialog;
    }

    // Get dialog stack
    function getDialogStack() {
        return dialogStack;
    }

    // Show operation in progress
    function showBusyIndicator(message) {
        // Implementation would create a busy indicator
        console.log("Busy: " + message);
        return Date.now();
    }

    // Hide operation in progress
    function hideBusyIndicator(indicatorId) {
        // Implementation would remove the busy indicator
        console.log("Busy indicator hidden:", indicatorId);
    }

    // Show toast message
    function showToast(message, duration) {
        // Implementation would create a toast message
        console.log("Toast: " + message);
        setTimeout(function() {
            console.log("Toast hidden");
        }, duration || 2000);
    }

    // Show progress dialog
    function showProgressDialog(title, message, maxValue) {
        const dialog = {
            id: Date.now(),
            title: title,
            message: message,
            type: "progress",
            value: 0,
            maxValue: maxValue || 100,
            timestamp: new Date().toISOString()
        };

        dialogStack.push(dialog);
        return dialog;
    }

    // Update progress dialog
    function updateProgressDialog(dialogId, value, message) {
        const dialog = dialogStack.find(d => d.id === dialogId);
        if (dialog) {
            dialog.value = value;
            if (message) {
                dialog.message = message;
            }
            return true;
        }
        return false;
    }

    // Log error
    function logError(message, error) {
        console.error(message, error);
        showNotification("Error", message, "error", 5000);
    }

    // Log warning
    function logWarning(message) {
        console.warn(message);
        showNotification("Warning", message, "warning", 4000);
    }

    // Log info
    function logInfo(message) {
        console.log(message);
        showNotification("Info", message, "info", 3000);
    }

    // Log success
    function logSuccess(message) {
        console.log(message);
        showNotification("Success", message, "success", 3000);
    }

    // Handle operation result
    function handleOperationResult(success, successMessage, errorMessage) {
        if (success) {
            logSuccess(successMessage);
            return true;
        } else {
            logError(errorMessage);
            return false;
        }
    }
}
