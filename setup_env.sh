#!/bin/bash

# Huayan SCADA 环境配置脚本
# 自动配置Qt6开发环境

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检测Qt安装路径
detect_qt_path() {
    local possible_paths=(
        "/opt/Qt/6.8.3/gcc_64"
        "/usr/local/Qt/6.8.3/gcc_64"
        "/home/$USER/Qt/6.8.3/gcc_64"
        "/opt/Qt6"
        "/usr/local/Qt6"
    )
    
    for path in "${possible_paths[@]}"; do
        if [ -d "$path" ] && [ -f "$path/bin/qmake" ]; then
            echo "$path"
            return 0
        fi
    done
    
    # 尝试使用pkg-config查找
    if command -v pkg-config &> /dev/null; then
        local qt_path=$(pkg-config --variable=prefix Qt6Core 2>/dev/null)
        if [ -n "$qt_path" ]; then
            echo "$qt_path"
            return 0
        fi
    fi
    
    return 1
}

# 配置环境变量
setup_environment() {
    local qt_path=$1
    
    log_info "配置Qt6环境: $qt_path"
    
    # 设置环境变量
    export QTDIR="$qt_path"
    export PATH="$qt_path/bin:$PATH"
    
    # 设置库路径
    if [ -d "$qt_path/lib" ]; then
        export LD_LIBRARY_PATH="$qt_path/lib:$LD_LIBRARY_PATH"
    fi
    
    # 设置QML路径
    if [ -d "$qt_path/qml" ]; then
        export QML2_IMPORT_PATH="$qt_path/qml:$QML2_IMPORT_PATH"
    fi
    
    # 设置插件路径
    if [ -d "$qt_path/plugins" ]; then
        export QT_PLUGIN_PATH="$qt_path/plugins:$QT_PLUGIN_PATH"
    fi
    
    # 验证配置
    if command -v qmake6 &> /dev/null; then
        log_info "Qt6 qmake6 可用: $(qmake6 -v | head -1)"
    elif command -v qmake &> /dev/null; then
        log_info "Qt6 qmake 可用: $(qmake -v | head -1)"
    else
        log_error "无法找到可用的qmake命令"
        return 1
    fi
    
    # 验证CMake可以找到Qt
    if command -v cmake &> /dev/null; then
        log_info "CMake版本: $(cmake --version | head -1)"
    else
        log_error "未找到CMake"
        return 1
    fi
    
    return 0
}

# 生成环境配置文件
generate_config_file() {
    local qt_path=$1
    local config_file="$HOME/.huayan_scada_env"
    
    cat > "$config_file" << EOF
# Huayan SCADA Environment Configuration
# Generated on $(date)

export QTDIR="$qt_path"
export PATH="$qt_path/bin:\$PATH"

if [ -d "$qt_path/lib" ]; then
    export LD_LIBRARY_PATH="$qt_path/lib:\$LD_LIBRARY_PATH"
fi

if [ -d "$qt_path/qml" ]; then
    export QML2_IMPORT_PATH="$qt_path/qml:\$QML2_IMPORT_PATH"
fi

if [ -d "$qt_path/plugins" ]; then
    export QT_PLUGIN_PATH="$qt_path/plugins:\$QT_PLUGIN_PATH"
fi

# Alias for convenience
alias scada-build='./build.sh'
alias scada-clean='./clean.sh'
alias scada-run='./scada_launcher.sh'
EOF
    
    log_info "环境配置文件已生成: $config_file"
    echo "请运行以下命令加载环境:"
    echo "  source $config_file"
}

# 主函数
main() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}Huayan SCADA 环境配置工具${NC}"
    echo -e "${BLUE}================================${NC}"
    
    # 检测Qt路径
    local qt_path=$(detect_qt_path)
    if [ $? -ne 0 ]; then
        log_error "未找到Qt6安装路径"
        log_info "请手动指定Qt6路径，或安装Qt6开发包"
        echo "Ubuntu/Debian: sudo apt install qt6-base-dev qt6-declarative-dev"
        echo "CentOS/RHEL: sudo yum install qt6-qtbase-devel qt6-qtdeclarative-devel"
        exit 1
    fi
    
    log_info "检测到Qt6路径: $qt_path"
    
    # 配置环境
    if setup_environment "$qt_path"; then
        log_info "环境配置成功！"
        generate_config_file "$qt_path"
        
        echo -e "${BLUE}================================${NC}"
        log_info "环境配置完成"
        echo "现在可以运行构建命令:"
        echo "  ./build.sh --all"
        echo ""
        echo "或者加载环境配置后使用别名:"
        echo "  source ~/.huayan_scada_env"
        echo "  scada-build --all"
        echo -e "${BLUE}================================${NC}"
    else
        log_error "环境配置失败"
        exit 1
    fi
}

# 执行主函数
main "$@"