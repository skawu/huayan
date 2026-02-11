#!/bin/bash

# Huayan工业SCADA系统打包脚本
# 生成包含Qt依赖的自包含安装包

set -e

echo "=== Huayan工业SCADA系统打包脚本 ==="

# 检查参数
if [ $# -ne 1 ]; then
    echo "用法: $0 <构建类型>"
    echo "构建类型: Release | Debug"
    exit 1
fi

BUILD_TYPE=$1
BUILD_DIR="build_${BUILD_TYPE}"
INSTALL_DIR="bin_${BUILD_TYPE}"

# 创建构建目录
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

# 配置项目
echo "正在配置项目..."
cmake .. -DCMAKE_BUILD_TYPE=${BUILD_TYPE}

# 构建项目
echo "正在构建项目..."
make -j$(nproc)

# 安装项目到临时目录
echo "正在安装项目..."
cmake --install . --prefix ../${INSTALL_DIR}

# 复制Qt依赖
echo "正在复制Qt依赖..."

# 检查Qt安装路径
QT_PATH=$(qmake6 -query QT_INSTALL_PREFIX)
if [ -z "${QT_PATH}" ]; then
    echo "错误: 未找到Qt安装路径"
    exit 1
fi

echo "找到Qt安装路径: ${QT_PATH}"

# 创建lib目录
mkdir -p ../${INSTALL_DIR}/lib

# 复制Qt核心库
QT_LIBS=("Core" "Gui" "Quick" "Network" "SerialBus" "Sql" "Charts" "QuickControls2" "Qml" "Widgets")

for lib in "${QT_LIBS[@]}"; do
    if [ -f "${QT_PATH}/lib/libQt6${lib}.so.6" ]; then
        cp -L "${QT_PATH}/lib/libQt6${lib}.so.6"* ../${INSTALL_DIR}/lib/
    elif [ -f "${QT_PATH}/bin/Qt6${lib}.dll" ]; then
        cp "${QT_PATH}/bin/Qt6${lib}.dll" ../${INSTALL_DIR}/lib/
    fi
done

# 复制Qt平台插件
mkdir -p ../${INSTALL_DIR}/plugins/platforms
if [ -d "${QT_PATH}/plugins/platforms" ]; then
    cp -r "${QT_PATH}/plugins/platforms"/* ../${INSTALL_DIR}/plugins/platforms/
fi

# 复制Qt QML插件
mkdir -p ../${INSTALL_DIR}/qml
if [ -d "${QT_PATH}/qml" ]; then
    cp -r "${QT_PATH}/qml/Qt" ../${INSTALL_DIR}/qml/
    cp -r "${QT_PATH}/qml/QtQuick" ../${INSTALL_DIR}/qml/
    cp -r "${QT_PATH}/qml/QtCharts" ../${INSTALL_DIR}/qml/
    cp -r "${QT_PATH}/qml/QtQuickControls2" ../${INSTALL_DIR}/qml/
fi

# 创建运行脚本
cat > ../${INSTALL_DIR}/run.sh << 'EOF'
#!/bin/bash

# Huayan工业SCADA系统运行脚本

# 设置环境变量
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$PWD/lib"
export QT_QPA_PLATFORM_PLUGIN_PATH="$PWD/plugins/platforms"
export QML2_IMPORT_PATH="$PWD/qml"

# 运行应用程序
./SCADASystem
EOF

chmod +x ../${INSTALL_DIR}/run.sh

# 创建Windows运行脚本
cat > ../${INSTALL_DIR}/run.bat << 'EOF'
@echo off

rem Huayan工业SCADA系统运行脚本

rem 设置环境变量
set PATH=%PATH%;%~dp0lib
set QT_QPA_PLATFORM_PLUGIN_PATH=%~dp0plugins/platforms
set QML2_IMPORT_PATH=%~dp0qml

rem 运行应用程序
%~dp0SCADASystem.exe
EOF

# 打包成压缩文件
cd ..
echo "正在创建压缩包..."

if [ "$(uname)" = "Linux" ]; then
    if [ "$(uname -m)" = "aarch64" ]; then
        tar -czf "huayan-${BUILD_TYPE}-arm64.tar.gz" "${INSTALL_DIR}"
    else
        tar -czf "huayan-${BUILD_TYPE}-x86_64.tar.gz" "${INSTALL_DIR}"
    fi
elif [ "$(uname)" = "WindowsNT" ]; then
    7z a "huayan-${BUILD_TYPE}-x86_64.zip" "${INSTALL_DIR}"
fi

echo "=== 打包完成 ==="
echo "安装包已生成:"
ls -la huayan-*.tar.gz huayan-*.zip 2>/dev/null

# 清理临时目录
# rm -rf ${BUILD_DIR} ${INSTALL_DIR}

echo "=== 脚本执行完成 ==="
