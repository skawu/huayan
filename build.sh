#!/bin/bash

# Huayan SCADA System Build Script (修订版)
# 明确使用Qt安装包自带的构建工具

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认参数
BUILD_TYPE="Release"
CLEAN_BUILD=false
BUILD_ALL=false
BUILD_DESIGNER=false
BUILD_RUNTIME=false
BUILD_SHARED=false
VERBOSE=false

# 路径配置
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
INSTALL_DIR="$PROJECT_ROOT/bin"
LOG_FILE="$PROJECT_ROOT/build.log"

# 显示帮助信息
show_help() {
    echo -e "${BLUE}Huayan SCADA System 构建脚本${NC}"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "构建选项:"
    echo "  --all              构建所有组件（默认）"
    echo "  --designer         仅构建设计器"
    echo "  --runtime          仅构建运行时"
    echo "  --shared           仅构建共享库"
    echo "  --clean            清理构建目录"
    echo ""
    echo "配置选项:"
    echo "  --debug            构建调试版本"
    echo "  --release          构建发布版本（默认）"
    echo "  --verbose          显示详细构建信息"
    echo "  --install-dir DIR  指定安装目录（默认: $INSTALL_DIR）"
    echo ""
    echo "其他选项:"
    echo "  -h, --help         显示此帮助信息"
    echo "  --version          显示版本信息"
}

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# 检查Qt环境
check_qt_environment() {
    log_info "检查Qt环境..."
    
    if [ -z "$QTDIR" ]; then
        log_error "QTDIR环境变量未设置"
        log_info "请先运行环境配置脚本:"
        log_info "  source setup_env.sh"
        exit 1
    fi
    
    if [ ! -d "$QTDIR" ]; then
        log_error "Qt目录不存在: $QTDIR"
        exit 1
    fi
    
    log_info "Qt环境检查通过: $QTDIR"
}

# 检查依赖
check_dependencies() {
    log_info "检查构建依赖..."
    
    # 检查Qt工具
    if ! command -v "$QTDIR/bin/qmake" &> /dev/null; then
        log_error "未找到 Qt qmake: $QTDIR/bin/qmake"
        exit 1
    fi
    
    # 检查CMake（优先使用Qt自带的）
    local cmake_path=""
    if [ -f "$QTDIR/bin/cmake" ]; then
        cmake_path="$QTDIR/bin/cmake"
        log_info "使用Qt自带CMake: $cmake_path"
    elif command -v cmake &> /dev/null; then
        cmake_path="cmake"
        log_warn "使用系统CMake，建议使用Qt自带版本"
    else
        log_error "未找到 CMake"
        exit 1
    fi
    
    # 检查编译器
    if ! command -v g++ &> /dev/null; then
        log_error "未找到 GCC 编译器"
        exit 1
    fi
    
    log_info "依赖检查通过"
    echo "CMake路径: $cmake_path"
}

# 清理构建目录
clean_build() {
    log_info "清理构建目录..."
    rm -rf "$BUILD_DIR"
    rm -rf "$INSTALL_DIR"
    mkdir -p "$BUILD_DIR" "$INSTALL_DIR"
    log_info "清理完成"
}

# 构建共享组件
build_shared() {
    log_info "构建共享组件..."
    
    local shared_build_dir="$BUILD_DIR/shared"
    mkdir -p "$shared_build_dir"
    cd "$shared_build_dir"
    
    # 使用Qt环境中的CMake
    local cmake_cmd="${QTDIR}/bin/cmake"
    if [ ! -f "$cmake_cmd" ]; then
        cmake_cmd="cmake"  # 回退到系统CMake
    fi
    
    # 构建共享库（INTERFACE库只需要配置，不需要编译）
    if [ -f "$PROJECT_ROOT/shared/CMakeLists.txt" ]; then
        "$cmake_cmd" "$PROJECT_ROOT/shared" \
            -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
            -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
            -DCMAKE_PREFIX_PATH="$QTDIR" \
            ${VERBOSE:+-DCMAKE_VERBOSE_MAKEFILE=ON}
        
        # INTERFACE库不需要make和make install
        log_info "共享组件配置完成（INTERFACE库）"
    else
        log_warn "共享组件 CMakeLists.txt 不存在，跳过构建"
    fi
}

# 构建设计器
build_designer() {
    log_info "构建设计器..."
    
    local designer_build_dir="$BUILD_DIR/designer"
    mkdir -p "$designer_build_dir"
    cd "$designer_build_dir"
    
    # 使用Qt环境中的CMake
    local cmake_cmd="${QTDIR}/bin/cmake"
    if [ ! -f "$cmake_cmd" ]; then
        cmake_cmd="cmake"  # 回退到系统CMake
    fi
    
    # 构建设计器应用
    if [ -f "$PROJECT_ROOT/designer/CMakeLists.txt" ]; then
        "$cmake_cmd" "$PROJECT_ROOT/designer" \
            -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
            -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
            -DCMAKE_PREFIX_PATH="$QTDIR" \
            ${VERBOSE:+-DCMAKE_VERBOSE_MAKEFILE=ON}
        
        make -j$(nproc) VERBOSE=$VERBOSE
        make install
        
        # 重命名为标准名称
        if [ -f "$INSTALL_DIR/designer" ]; then
            mv "$INSTALL_DIR/designer" "$INSTALL_DIR/SCADADesigner"
        fi
        
        log_info "设计器构建完成"
    else
        log_warn "设计器 CMakeLists.txt 不存在，跳过构建"
    fi
}

# 构建运行时
build_runtime() {
    log_info "构建运行时..."
    
    local runtime_build_dir="$BUILD_DIR/runtime"
    mkdir -p "$runtime_build_dir"
    cd "$runtime_build_dir"
    
    # 使用Qt环境中的CMake
    local cmake_cmd="${QTDIR}/bin/cmake"
    if [ ! -f "$cmake_cmd" ]; then
        cmake_cmd="cmake"  # 回退到系统CMake
    fi
    
    # 构建运行时应用
    if [ -f "$PROJECT_ROOT/runtime/CMakeLists.txt" ]; then
        "$cmake_cmd" "$PROJECT_ROOT/runtime" \
            -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
            -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
            -DCMAKE_PREFIX_PATH="$QTDIR" \
            ${VERBOSE:+-DCMAKE_VERBOSE_MAKEFILE=ON}
        
        make -j$(nproc) VERBOSE=$VERBOSE
        make install
        
        # 重命名为标准名称
        if [ -f "$INSTALL_DIR/runtime" ]; then
            mv "$INSTALL_DIR/runtime" "$INSTALL_DIR/SCADARuntime"
        fi
        
        log_info "运行时构建完成"
    else
        log_warn "运行时 CMakeLists.txt 不存在，跳过构建"
    fi
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            BUILD_ALL=true
            shift
            ;;
        --designer)
            BUILD_DESIGNER=true
            shift
            ;;
        --runtime)
            BUILD_RUNTIME=true
            shift
            ;;
        --shared)
            BUILD_SHARED=true
            shift
            ;;
        --clean)
            CLEAN_BUILD=true
            shift
            ;;
        --debug)
            BUILD_TYPE="Debug"
            shift
            ;;
        --release)
            BUILD_TYPE="Release"
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --install-dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        --version)
            show_version
            exit 0
            ;;
        *)
            log_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 如果没有指定具体组件，默认构建全部
if [ "$BUILD_ALL" = false ] && [ "$BUILD_DESIGNER" = false ] && [ "$BUILD_RUNTIME" = false ] && [ "$BUILD_SHARED" = false ]; then
    BUILD_ALL=true
fi

# 开始构建过程
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Huayan SCADA System 构建开始${NC}"
echo -e "${BLUE}========================================${NC}"
echo "构建类型: $BUILD_TYPE"
echo "安装目录: $INSTALL_DIR"
echo "日志文件: $LOG_FILE"
echo -e "${BLUE}========================================${NC}"

# 初始化日志
echo "构建开始时间: $(date)" > "$LOG_FILE"

# 检查Qt环境
check_qt_environment

# 检查依赖
check_dependencies

# 清理构建（如果需要）
if [ "$CLEAN_BUILD" = true ]; then
    clean_build
fi

# 创建必要的目录
mkdir -p "$BUILD_DIR" "$INSTALL_DIR"

# 执行构建
if [ "$BUILD_ALL" = true ] || [ "$BUILD_SHARED" = true ]; then
    build_shared
fi

if [ "$BUILD_ALL" = true ] || [ "$BUILD_DESIGNER" = true ]; then
    build_designer
fi

if [ "$BUILD_ALL" = true ] || [ "$BUILD_RUNTIME" = true ]; then
    build_runtime
fi

# 复制资源文件
log_info "复制资源文件..."
cp -r "$PROJECT_ROOT/shared/themes" "$INSTALL_DIR/" 2>/dev/null || true
cp -r "$PROJECT_ROOT/shared/components" "$INSTALL_DIR/" 2>/dev/null || true

# 复制启动脚本
if [ -f "$PROJECT_ROOT/scada_launcher.sh" ]; then
    cp "$PROJECT_ROOT/scada_launcher.sh" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/scada_launcher.sh"
fi

# 显示构建结果
echo -e "${BLUE}========================================${NC}"
log_info "构建完成！"
echo "安装位置: $INSTALL_DIR"
echo "可执行文件:"
if [ -f "$INSTALL_DIR/SCADADesigner" ]; then
    echo "  - 设计器: $INSTALL_DIR/SCADADesigner"
fi
if [ -f "$INSTALL_DIR/SCADARuntime" ]; then
    echo "  - 运行时: $INSTALL_DIR/SCADARuntime"
fi
if [ -f "$INSTALL_DIR/scada_launcher.sh" ]; then
    echo "  - 启动器: $INSTALL_DIR/scada_launcher.sh"
fi
echo -e "${BLUE}========================================${NC}"

echo "构建结束时间: $(date)" >> "$LOG_FILE"
