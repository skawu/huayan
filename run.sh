#!/bin/bash

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 如果尚未安装则尝试自动安装到工程的 bin 目录
if [ ! -f "$SCRIPT_DIR/bin/SCADASystem" ]; then
    if [ -f "$SCRIPT_DIR/build.sh" ]; then
        echo "未检测到已安装的可执行文件，尝试执行 ./build.sh --install 来安装到 bin/ ..."
        (cd "$SCRIPT_DIR" && ./build.sh --install) || echo "自动安装失败，继续尝试直接运行构建产物"
    fi
fi

# 决定可执行文件所在目录（优先使用安装目录 bin/，其次工程根目录和 build/）
if [ -f "$SCRIPT_DIR/bin/SCADASystem" ]; then
    EXECUTABLE_DIR="$SCRIPT_DIR/bin"
elif [ -f "$SCRIPT_DIR/SCADASystem" ]; then
    EXECUTABLE_DIR="$SCRIPT_DIR"
elif [ -f "$SCRIPT_DIR/build/SCADASystem" ]; then
    EXECUTABLE_DIR="$SCRIPT_DIR/build"
else
    echo "未找到可执行文件 SCADASystem，请先构建或安装（执行 ./build.sh --install）"
    exit 1
fi

echo "使用可执行文件目录: $EXECUTABLE_DIR"

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
export QT_DEBUG_PLUGINS=1

# Try different platform backends in order of preference
if [ -z "$QT_QPA_PLATFORM" ]; then
    # Try to detect appropriate platform
    if command -v xset &> /dev/null; then
        # X11 environment detected
        export QT_QPA_PLATFORM=xcb
    elif [ -n "$WAYLAND_DISPLAY" ]; then
        # Wayland environment
        export QT_QPA_PLATFORM=wayland
    else
        # Fallback to xcb or offscreen
        export QT_QPA_PLATFORM=xcb
    fi
fi

# Additional environment variables for compatibility
export QT_ENABLE_HIGHDPI_SCALING=1
export QT_AUTO_SCREEN_SCALE_FACTOR=1

# Print environment for debugging
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo "QML_IMPORT_PATH: $QML_IMPORT_PATH"
echo "QT_PLUGIN_PATH: $QT_PLUGIN_PATH"

# Run the application
"$EXECUTABLE_DIR/SCADASystem"