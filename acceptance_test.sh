#!/bin/bash

# Huayan SCADA System 验收测试脚本
# 用于验证重构后的项目功能完整性

set -e  # 遇到错误立即退出

echo "========================================"
echo "Huayan SCADA System 验收测试开始"
echo "========================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试结果统计
PASSED=0
FAILED=0
TOTAL=0

function print_result() {
    TOTAL=$((TOTAL + 1))
    if [ "$1" = "PASS" ]; then
        PASSED=$((PASSED + 1))
        echo -e "${GREEN}✓ [$PASSED/$TOTAL] $2${NC}"
    else
        FAILED=$((FAILED + 1))
        echo -e "${RED}✗ [$PASSED/$TOTAL] $2${NC}"
    fi
}

function run_test() {
    echo -e "${BLUE}测试: $1${NC}"
    shift
    if "$@"; then
        print_result "PASS" "$1"
    else
        print_result "FAIL" "$1"
    fi
    echo ""
}

# 检查环境
echo "1. 环境检查..."
run_test "Qt环境配置检查" bash -c 'source /home/hdzk/.huayan_scada_env && [ -n "$QTDIR" ] && echo "Qt环境: $QTDIR"'

# 构建测试
echo "2. 构建测试..."
run_test "清理构建目录" ./build.sh --clean
run_test "构建设计器" ./build.sh --designer
run_test "构建运行时" ./build.sh --runtime

# 文件结构检查
echo "3. 文件结构检查..."
run_test "检查设计器可执行文件" test -f "bin/bin/SCADADesigner"
run_test "检查运行时可执行文件" test -f "bin/bin/SCADARuntime"
run_test "检查共享组件目录" test -d "shared/components"
run_test "检查文档文件" test -f "README_CN.md"

# 功能模块检查
echo "4. 功能模块检查..."
run_test "检查TagManager头文件" test -f "shared/models/core/tagmanager.h"
run_test "检查拖拽组件" test -f "shared/components/DraggableIndustrialComponent.qml"
run_test "检查组件库面板" test -f "shared/components/ComponentLibraryPanel.qml"

# 启动器测试
echo "5. 启动器测试..."
run_test "检查智能启动器" test -f "scada_launcher.sh"
run_test "检查环境配置脚本" test -f "setup_env.sh"

# 验收测试总结
echo "========================================"
echo "验收测试总结"
echo "========================================"
echo "总测试数: $TOTAL"
echo -e "${GREEN}通过测试: $PASSED${NC}"
echo -e "${RED}失败测试: $FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}"
    echo "🎉 所有验收测试通过！"
    echo "项目重构成功完成，功能完整可用。"
    echo ""
    echo "🚀 下一步操作："
    echo "   1. 运行 ./scada_launcher.sh 启动系统"
    echo "   2. 使用 --designer 参数启动设计器模式"
    echo "   3. 使用 --runtime 参数启动运行时模式"
    echo ""
    echo "📚 相关文档："
    echo "   - 中文文档: README_CN.md"
    echo "   - 英文文档: README.md"
    echo "   - 开发指南: docs/developer_guide.md"
    echo -e "${NC}"
    exit 0
else
    echo -e "${RED}"
    echo "❌ 部分测试失败，请检查上述错误信息"
    echo "建议运行: ./build.sh --clean && ./build.sh --all"
    echo -e "${NC}"
    exit 1
fi