#!/bin/bash

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查是否在 bin 目录中存在可执行文件，如果是则使用 bin 目录作为基础目录
if [ -f "$SCRIPT_DIR/bin/SCADASystem" ]; then
    EXECUTABLE_DIR="$SCRIPT_DIR/bin"
else
    EXECUTABLE_DIR="$SCRIPT_DIR"
fi

# 设置库路径，优先使用可执行文件所在目录的 lib 子目录
export LD_LIBRARY_PATH="$EXECUTABLE_DIR/lib:$LD_LIBRARY_PATH"

# Add Qt library path if available
if [ -d "${QT6_DIR}/lib" ]; then
    export LD_LIBRARY_PATH="${QT6_DIR}/lib:$LD_LIBRARY_PATH"
elif [ -d "${QTDIR}/lib" ]; then
    export LD_LIBRARY_PATH="${QTDIR}/lib:$LD_LIBRARY_PATH"
elif [ -d "/opt/Qt/6.8.3/gcc_64/lib" ]; then
    export LD_LIBRARY_PATH="/opt/Qt/6.8.3/gcc_64/lib:$LD_LIBRARY_PATH"
elif [ -d "/usr/lib/x86_64-linux-gnu/qt6" ]; then
    export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu/qt6:$LD_LIBRARY_PATH"
elif [ -d "/usr/local/qt6/lib" ]; then
    export LD_LIBRARY_PATH="/usr/local/qt6/lib:$LD_LIBRARY_PATH"
fi

# Set QML_IMPORT_PATH to include the qml directory
export QML_IMPORT_PATH="$EXECUTABLE_DIR/qml:$QML_IMPORT_PATH"

# Set QT_PLUGIN_PATH to include the plugins directory
export QT_PLUGIN_PATH="$EXECUTABLE_DIR/plugins:$QT_PLUGIN_PATH"

# Set platform-specific environment variables to help with XCB plugin initialization
export QT_QPA_EGLFS_DISABLE_INPUT=1
export QT_QPA_EGLFS_INTEGRATION=none
export QT_QPA_PLATFORM= xcb
export QT_DEBUG_PLUGINS=1

# Run the application
"$EXECUTABLE_DIR/SCADASystem"
