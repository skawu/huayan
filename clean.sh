#!/bin/bash

# Huayan SCADA System Clean Script
# 清理构建产物和临时文件

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 路径配置
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 默认参数
CLEAN_BUILD=true
CLEAN_CACHE=true
CLEAN_LOGS=true
CLEAN_TEMP=true
CLEAN_DOCS=false

# 显示帮助信息
show_help() {
    echo -e "${BLUE}Huayan SCADA System 清理脚本${NC}"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "清理选项:"
    echo "  --build            清理构建目录（默认）"
    echo "  --cache            清理编译缓存"
    echo "  --logs             清理日志文件"
    echo "  --temp             清理临时文件"
    echo "  --docs             清理生成的文档"
    echo "  --all              清理所有内容"
    echo ""
    echo "其他选项:"
    echo "  -h, --help         显示此帮助信息"
}

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 清理构建目录
clean_build_dirs() {
    log_info "清理构建目录..."
    
    # 清理主要构建目录
    rm -rf "$PROJECT_ROOT/build"
    rm -rf "$PROJECT_ROOT/bin"
    
    # 清理各模块构建目录
    rm -rf "$PROJECT_ROOT/designer/build"
    rm -rf "$PROJECT_ROOT/runtime/build"
    rm -rf "$PROJECT_ROOT/shared/build"
    
    # 清理CMake缓存文件
    find "$PROJECT_ROOT" -name "CMakeCache.txt" -delete 2>/dev/null || true
    find "$PROJECT_ROOT" -name "CMakeFiles" -type d -exec rm -rf {} + 2>/dev/null || true
    
    log_info "构建目录清理完成"
}

# 清理编译缓存
clean_cache() {
    log_info "清理编译缓存..."
    
    # 清理Qt moc、rcc、uic生成的文件
    find "$PROJECT_ROOT" -name "moc_*.cpp" -delete 2>/dev/null || true
    find "$PROJECT_ROOT" -name "qrc_*.cpp" -delete 2>/dev/null || true
    find "$PROJECT_ROOT" -name "ui_*.h" -delete 2>/dev/null || true
    
    # 清理编译中间文件
    find "$PROJECT_ROOT" -name "*.o" -delete 2>/dev/null || true
    find "$PROJECT_ROOT" -name "*.obj" -delete 2>/dev/null || true
    find "$PROJECT_ROOT" -name "*.pch" -delete 2>/dev/null || true
    
    log_info "编译缓存清理完成"
}

# 清理日志文件
clean_logs() {
    log_info "清理日志文件..."
    
    # 清理构建日志
    rm -f "$PROJECT_ROOT/build.log"
    rm -f "$PROJECT_ROOT/*.log"
    
    # 清理测试日志
    find "$PROJECT_ROOT" -name "test_*.log" -delete 2>/dev/null || true
    
    log_info "日志文件清理完成"
}

# 清理临时文件
clean_temp() {
    log_info "清理临时文件..."
    
    # 清理备份文件
    find "$PROJECT_ROOT" -name "*~" -delete 2>/dev/null || true
    find "$PROJECT_ROOT" -name "*.bak" -delete 2>/dev/null || true
    find "$PROJECT_ROOT" -name "*.tmp" -delete 2>/dev/null || true
    
    # 清理IDE临时文件
    find "$PROJECT_ROOT" -name ".vscode" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$PROJECT_ROOT" -name ".idea" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$PROJECT_ROOT" -name "*.user" -delete 2>/dev/null || true
    
    # 清理系统临时文件
    find "$PROJECT_ROOT" -name ".DS_Store" -delete 2>/dev/null || true
    find "$PROJECT_ROOT" -name "Thumbs.db" -delete 2>/dev/null || true
    
    log_info "临时文件清理完成"
}

# 清理生成的文档
clean_docs() {
    log_info "清理生成的文档..."
    
    # 清理doxygen生成的文档
    rm -rf "$PROJECT_ROOT/docs/html"
    rm -rf "$PROJECT_ROOT/docs/latex"
    
    # 清理其他生成的文档
    find "$PROJECT_ROOT" -name "*.pdf" -path "*/docs/*" -delete 2>/dev/null || true
    
    log_info "文档清理完成"
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --build)
            CLEAN_BUILD=true
            shift
            ;;
        --cache)
            CLEAN_CACHE=true
            shift
            ;;
        --logs)
            CLEAN_LOGS=true
            shift
            ;;
        --temp)
            CLEAN_TEMP=true
            shift
            ;;
        --docs)
            CLEAN_DOCS=true
            shift
            ;;
        --all)
            CLEAN_BUILD=true
            CLEAN_CACHE=true
            CLEAN_LOGS=true
            CLEAN_TEMP=true
            CLEAN_DOCS=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 开始清理过程
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Huayan SCADA System 清理开始${NC}"
echo -e "${BLUE}========================================${NC}"

# 执行清理
if [ "$CLEAN_BUILD" = true ]; then
    clean_build_dirs
fi

if [ "$CLEAN_CACHE" = true ]; then
    clean_cache
fi

if [ "$CLEAN_LOGS" = true ]; then
    clean_logs
fi

if [ "$CLEAN_TEMP" = true ]; then
    clean_temp
fi

if [ "$CLEAN_DOCS" = true ]; then
    clean_docs
fi

# 显示清理结果
echo -e "${BLUE}========================================${NC}"
log_info "清理完成！"
echo "已清理的内容:"
[ "$CLEAN_BUILD" = true ] && echo "  - 构建目录和可执行文件"
[ "$CLEAN_CACHE" = true ] && echo "  - 编译缓存文件"
[ "$CLEAN_LOGS" = true ] && echo "  - 日志文件"
[ "$CLEAN_TEMP" = true ] && echo "  - 临时文件"
[ "$CLEAN_DOCS" = true ] && echo "  - 生成的文档"
echo -e "${BLUE}========================================${NC}"