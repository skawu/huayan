#!/bin/bash

# Huayan SCADA System Launcher
# 支持设计器和运行时两种模式

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认参数
MODE=""
PROJECT_FILE=""
INSTALL_DIR="/home/hdzk/workspace/huayan/bin"

# 显示帮助信息
show_help() {
    echo -e "${BLUE}Huayan SCADA System 启动器${NC}"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -d, --designer     启动设计器模式"
    echo "  -r, --runtime      启动运行时模式"
    echo "  -p, --project FILE 指定项目文件"
    echo "  -i, --install DIR  指定安装目录 (默认: $INSTALL_DIR)"
    echo "  -h, --help         显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 --designer                    # 启动设计器"
    echo "  $0 --runtime --project myproj.hyproj  # 启动运行时并加载项目"
    echo "  $0 --runtime                     # 启动运行时（交互式选择项目）"
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--designer)
            MODE="designer"
            shift
            ;;
        -r|--runtime)
            MODE="runtime"
            shift
            ;;
        -p|--project)
            PROJECT_FILE="$2"
            shift 2
            ;;
        -i|--install)
            INSTALL_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}未知选项: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# 检查安装目录
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${RED}错误: 安装目录不存在: $INSTALL_DIR${NC}"
    exit 1
fi

# 设置环境变量
export LD_LIBRARY_PATH="$INSTALL_DIR/lib:$LD_LIBRARY_PATH"
export QML2_IMPORT_PATH="$INSTALL_DIR/qml:$QML2_IMPORT_PATH"
export QT_PLUGIN_PATH="$INSTALL_DIR/plugins:$QT_PLUGIN_PATH"

echo -e "${GREEN}Huayan SCADA System 启动器${NC}"
echo "安装目录: $INSTALL_DIR"
echo ""

# 如果没有指定模式，让用户选择
if [ -z "$MODE" ]; then
    echo "请选择启动模式:"
    echo "1) 设计器模式 - 用于创建和编辑监控界面"
    echo "2) 运行时模式 - 用于运行已创建的监控系统"
    echo ""
    read -p "请输入选择 (1 或 2): " choice
    
    case $choice in
        1)
            MODE="designer"
            ;;
        2)
            MODE="runtime"
            ;;
        *)
            echo -e "${RED}无效选择${NC}"
            exit 1
            ;;
    esac
fi

# 根据模式启动相应应用
case $MODE in
    designer)
        echo -e "${BLUE}启动设计器模式...${NC}"
        
        # 检查设计器可执行文件
        DESIGNER_EXE="$INSTALL_DIR/SCADADesigner"
        if [ ! -f "$DESIGNER_EXE" ]; then
            echo -e "${YELLOW}警告: 设计器可执行文件不存在，使用主程序替代${NC}"
            DESIGNER_EXE="$INSTALL_DIR/SCADASystem"
        fi
        
        if [ -f "$DESIGNER_EXE" ]; then
            echo "启动设计器: $DESIGNER_EXE"
            "$DESIGNER_EXE" "$@" &
            DESIGNER_PID=$!
            echo "设计器PID: $DESIGNER_PID"
            wait $DESIGNER_PID
        else
            echo -e "${RED}错误: 找不到设计器可执行文件${NC}"
            exit 1
        fi
        ;;
        
    runtime)
        echo -e "${BLUE}启动运行时模式...${NC}"
        
        # 如果指定了项目文件，检查其存在性
        if [ -n "$PROJECT_FILE" ]; then
            if [ ! -f "$PROJECT_FILE" ]; then
                echo -e "${RED}错误: 项目文件不存在: $PROJECT_FILE${NC}"
                exit 1
            fi
            echo "加载项目文件: $PROJECT_FILE"
        else
            # 交互式选择项目文件
            echo "请选择要加载的项目文件:"
            PROJECTS=($(find . -name "*.hyproj" -o -name "*.hyruntime" 2>/dev/null))
            
            if [ ${#PROJECTS[@]} -eq 0 ]; then
                echo -e "${YELLOW}未找到项目文件，启动空的运行时${NC}"
            else
                echo "找到以下项目文件:"
                for i in "${!PROJECTS[@]}"; do
                    echo "$((i+1))) ${PROJECTS[$i]}"
                done
                echo "$((${#PROJECTS[@]}+1))) 不加载项目文件"
                echo ""
                read -p "请选择 (1-${#PROJECTS[@]}+1): " proj_choice
                
                if [ "$proj_choice" -ge 1 ] && [ "$proj_choice" -le ${#PROJECTS[@]} ]; then
                    PROJECT_FILE="${PROJECTS[$((proj_choice-1))]}"
                    echo "选择项目: $PROJECT_FILE"
                fi
            fi
        fi
        
        # 启动运行时
        RUNTIME_EXE="$INSTALL_DIR/SCADARuntime"
        if [ ! -f "$RUNTIME_EXE" ]; then
            echo -e "${YELLOW}警告: 运行时可执行文件不存在，使用主程序替代${NC}"
            RUNTIME_EXE="$INSTALL_DIR/SCADASystem"
        fi
        
        if [ -f "$RUNTIME_EXE" ]; then
            RUNTIME_ARGS=()
            if [ -n "$PROJECT_FILE" ]; then
                RUNTIME_ARGS+=("--project" "$PROJECT_FILE")
            fi
            
            echo "启动运行时: $RUNTIME_EXE"
            "$RUNTIME_EXE" "${RUNTIME_ARGS[@]}" "$@" &
            RUNTIME_PID=$!
            echo "运行时PID: $RUNTIME_PID"
            wait $RUNTIME_PID
        else
            echo -e "${RED}错误: 找不到运行时可执行文件${NC}"
            exit 1
        fi
        ;;
        
    *)
        echo -e "${RED}未知模式: $MODE${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}程序已退出${NC}"