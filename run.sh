#!/bin/bash

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set QML_IMPORT_PATH to include the qml directory
export QML_IMPORT_PATH="$SCRIPT_DIR/qml:$QML_IMPORT_PATH"

# Set QT_PLUGIN_PATH to include the plugins directory
export QT_PLUGIN_PATH="$SCRIPT_DIR/plugins:$QT_PLUGIN_PATH"

# Set platform-specific environment variables to help with XCB plugin initialization
export QT_QPA_EGLFS_DISABLE_INPUT=1
export QT_QPA_EGLFS_INTEGRATION=none
export QT_QPA_PLATFORM= xcb
export QT_DEBUG_PLUGINS=1

# Run the application
"$SCRIPT_DIR/SCADASystem"
