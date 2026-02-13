#!/bin/bash

# Qt6 项目构建脚本 for Huayan SCADA System
# 自动检测 Qt6 环境并设置构建

set -e  # 出现任何错误即退出

# 输出颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 彩色输出打印
print_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# 检测平台
detect_platform() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        PLATFORM="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="macos"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        PLATFORM="windows"
    else
        PLATFORM="unknown"
    fi
    
    print_info "检测到平台: $PLATFORM"
}

# 查找 Qt6 安装
find_qt6() {
    print_info "正在搜索 Qt6 安装..."
    
    # 常见 Qt6 安装路径
    QT6_POSSIBLE_PATHS=()
    
    if [[ "$PLATFORM" == "linux" ]]; then
        QT6_POSSIBLE_PATHS+=(
            "/opt/Qt/6.8.3/gcc_64"
            "/opt/Qt/6.8.2/gcc_64"
            "/opt/Qt/6.8.1/gcc_64"
            "/opt/Qt/6.8.0/gcc_64"
            "/opt/Qt/6.9*/gcc_64"
            "/usr/local/Qt/6.8.3/gcc_64"
            "/usr/local/Qt/6.8.*/gcc_64"
            "$HOME/Qt/6.8.3/gcc_64"
            "$HOME/Qt/6.8.*/gcc_64"
        )
    elif [[ "$PLATFORM" == "windows" ]]; then
        QT6_POSSIBLE_PATHS+=(
            "C:/Qt/6.8.3/msvc2022_64"
            "C:/Qt/6.8.3/mingw_64"
            "C:/Qt/6.8.2/msvc2022_64"
            "C:/Qt/6.8.2/mingw_64"
            "C:/Qt/6.8.1/msvc2022_64"
            "C:/Qt/6.8.1/mingw_64"
            "C:/Qt/6.8.0/msvc2022_64"
            "C:/Qt/6.8.0/mingw_64"
            "C:/Qt/6.9*/msvc2022_64"
            "C:/Qt/6.9*/mingw_64"
        )
    elif [[ "$PLATFORM" == "macos" ]]; then
        QT6_POSSIBLE_PATHS+=(
            "/Users/$USER/Qt/6.8.3/clang_64"
            "/Users/$USER/Qt/6.8.*/clang_64"
            "/usr/local/Qt/6.8.3/clang_64"
            "/usr/local/Qt/6.8.*/clang_64"
        )
    fi
    
    # Check if qmake6 is in PATH
    if command -v qmake6 &> /dev/null; then
        QT6_BIN_DIR=$(dirname "$(command -v qmake6)")
        QT6_DIR=$(dirname "$QT6_BIN_DIR")
        print_info "Found Qt6 via qmake6: $QT6_DIR"
        return 0
    fi
    
    # Search in common paths
    for qt_path in "${QT6_POSSIBLE_PATHS[@]}"; do
        # Handle wildcard paths
        for expanded_path in $qt_path; do
            if [[ -f "$expanded_path/bin/qmake" ]] || [[ -f "$expanded_path/bin/qmake.exe" ]]; then
                QT6_DIR="$expanded_path"
                print_info "Found Qt6 at: $QT6_DIR"
                return 0
            fi
        done
    done
    
    # 最后手段：检查 /opt/Qt 中的 Qt 安装并检测版本
    if [[ -d "/opt/Qt" ]]; then
        for qt_version_dir in /opt/Qt/6.*; do
            if [[ -d "$qt_version_dir" ]]; then
                for compiler_dir in "$qt_version_dir"/*/; do
                    if [[ -f "$compiler_dir/bin/qmake" ]] || [[ -f "$compiler_dir/bin/qmake.exe" ]]; then
                        QT6_DIR="$compiler_dir"
                        print_info "找到 Qt6 位置: $QT6_DIR"
                        return 0
                    fi
                done
            fi
        done
    fi
    
    print_error "无法找到 Qt6 安装。请安装 Qt 6.8 LTS 或更高版本。"
    return 1
}

# 解析命令行参数
parse_arguments() {
    BUILD_TYPE="Release"
    BUILD_DIR="build"
    CLEAN_ONLY=false
    REBUILD=false
    DISTCLEAN=false
    INSTALL_ONLY=false
    INSTALL_AFTER_BUILD=false
    CUSTOM_INSTALL_PATH=""
    NUM_JOBS=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--debug)
                BUILD_TYPE="Debug"
                shift
                ;;
            -r|--release)
                BUILD_TYPE="Release"
                shift
                ;;
            -c|--clean)
                CLEAN_ONLY=true
                shift
                ;;
            --rebuild)
                REBUILD=true
                shift
                ;;
            --distclean)
                DISTCLEAN=true
                shift
                ;;
            -i|--install)
                INSTALL_ONLY=true
                shift
                ;;
            --install-to)
                CUSTOM_INSTALL_PATH="$2"
                INSTALL_AFTER_BUILD=true
                shift 2
                ;;
            -j|--jobs)
                NUM_JOBS="$2"
                shift 2
                ;;
            -b|--build-dir)
                BUILD_DIR="$2"
                shift 2
                ;;
            -q|--qt-path)
                QT6_DIR="$2"
                shift 2
                ;;
            -h|--help)
                echo "用法: $0 [选项]"
                echo "选项:"
                echo "  -d, --debug         Debug 模式构建"
                echo "  -r, --release       Release 模式构建（默认）"
                echo "  -c, --clean         清理构建目录"
                echo "  --rebuild           清理后重新构建"
                echo "  --distclean         清理构建目录和安装目录"
                echo "  -i, --install       仅安装（不构建，需要先构建）"
                echo "  --install-to PATH   构建后安装到指定目录"
                echo "  -j, --jobs N        并行作业数（默认：自动检测）"
                echo "  -b, --build-dir     构建目录（默认：build）"
                echo "  -q, --qt-path       Qt6 安装路径（默认：自动检测）"
                echo "  -h, --help          显示此帮助信息"
                exit 0
                ;;
            *)
                print_error "未知选项: $1"
                exit 1
                ;;
        esac
    done
    
    print_info "构建配置:"
    print_info "  平台: $PLATFORM"
    print_info "  Qt6 路径: $QT6_DIR"
    print_info "  构建类型: $BUILD_TYPE"
    print_info "  构建目录: $BUILD_DIR"
    print_info "  仅安装模式: $INSTALL_ONLY"
    print_info "  构建后安装: $INSTALL_AFTER_BUILD"
    print_info "  自定义安装路径: ${CUSTOM_INSTALL_PATH:-无}"
    print_info "  并行作业数: $NUM_JOBS"
    if [[ "$CLEAN_ONLY" == true ]]; then
        print_info "仅执行清理操作"
    fi
    if [[ "$INSTALL_ONLY" == true ]]; then
        print_info "仅执行安装操作（跳过构建）"
    fi
}

# 准备构建环境
prepare_environment() {
    print_info "准备构建环境..."
    
    # 添加 Qt6 到 PATH
    export PATH="$QT6_DIR/bin:$PATH"
    
    # 设置 Qt6 相关环境变量
    if [[ "$PLATFORM" == "linux" ]]; then
        export LD_LIBRARY_PATH="$QT6_DIR/lib:$LD_LIBRARY_PATH"
        export PKG_CONFIG_PATH="$QT6_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"
    elif [[ "$PLATFORM" == "macos" ]]; then
        export DYLD_LIBRARY_PATH="$QT6_DIR/lib:$DYLD_LIBRARY_PATH"
        export PKG_CONFIG_PATH="$QT6_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"
    elif [[ "$PLATFORM" == "windows" ]]; then
        export PATH="$QT6_DIR/bin:$PATH"
        export PATH="$QT6_DIR/lib:$PATH"
    fi
    
    print_success "构建环境准备完成"
}

# 准备构建目录
prepare_build_directory() {
    if [[ "$CLEAN_ONLY" == true ]] || [[ "$REBUILD" == true ]]; then
        if [[ -d "$BUILD_DIR" ]]; then
            print_info "清理构建目录: $BUILD_DIR"
            rm -rf "$BUILD_DIR"
            if [[ "$CLEAN_ONLY" == true ]]; then
                print_success "目录 $BUILD_DIR 已清理"
                return 0
            fi
        fi
    fi
    
    # 仅在非清理模式下创建目录
    if [[ "$CLEAN_ONLY" != true ]]; then
        mkdir -p "$BUILD_DIR"
        print_success "构建目录准备完成: $BUILD_DIR"
    fi
}

# 配置项目
configure_project() {
    print_info "使用 Qt6 配置项目: $QT6_DIR"
    
    cd "$BUILD_DIR"
    
    # 根据平台确定 CMake 生成器
    if [[ "$PLATFORM" == "windows" ]]; then
        # 在 Windows 上，检查 MSVC 与 MinGW
        if [[ -f "$QT6_DIR/bin/cl.exe" ]] || command -v cl &> /dev/null; then
            GENERATOR="-G \"Visual Studio 17 2022\" -A x64"
        else
            GENERATOR="-G \"MinGW Makefiles\""
        fi
    else
        GENERATOR=""
    fi
    
    # 使用 Qt6 路径配置，如果有自定义安装路径则设置CMAKE_INSTALL_PREFIX
    if [[ -n "$CUSTOM_INSTALL_PATH" ]]; then
        cmake .. \
            -DCMAKE_PREFIX_PATH="$QT6_DIR" \
            -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
            -DCMAKE_INSTALL_PREFIX="$CUSTOM_INSTALL_PATH" \
            $GENERATOR
    else
        cmake .. \
            -DCMAKE_PREFIX_PATH="$QT6_DIR" \
            -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
            $GENERATOR
    fi
    
    if [ $? -ne 0 ]; then
        print_error "CMake 配置失败"
        exit 1
    fi
    
    print_success "项目配置成功"
    cd ..
}

# 构建项目
build_project() {
    print_info "使用 $NUM_JOBS 个并行作业构建项目..."
    
    cd "$BUILD_DIR"
    
    make -j"$NUM_JOBS"
    
    if [ $? -ne 0 ]; then
        print_error "构建失败"
        exit 1
    fi
    
    print_success "项目构建成功"
    cd ..
}

# 复制Qt运行时库到目标目录
copy_qt_libraries() {
    local TARGET_DIR="$1"
    
    if [[ -z "$TARGET_DIR" ]]; then
        print_error "目标目录不能为空"
        return 1
    fi
    
    print_info "开始复制Qt运行时库到 $TARGET_DIR"
    
    # 创建lib目录
    mkdir -p "$TARGET_DIR/lib"
    
    # 复制Qt核心库
    local qt_libs=(
        "Qt6Core"
        "Qt6Gui"
        "Qt6Qml"
        "Qt6Quick"
        "Qt6Widgets"
        "Qt6OpenGL"
        "Qt6OpenGLWidgets"
        "Qt6Network"
        "Qt6Sql"
        "Qt6Svg"
    )
    
    for lib in "${qt_libs[@]}"; do
        local lib_file="${QT6_DIR}/lib/lib${lib}.so*"
        if ls $lib_file 1> /dev/null 2>&1; then
            cp -f $lib_file "$TARGET_DIR/lib/" 2>/dev/null || true
            print_info "复制 $lib"
        fi
    done
    
    # 复制Qt平台插件
    if [ -d "${QT6_DIR}/plugins" ]; then
        mkdir -p "$TARGET_DIR/plugins"
        # 复制常用的平台插件
        if [ -d "${QT6_DIR}/plugins/platforms" ]; then
            cp -rf "${QT6_DIR}/plugins/platforms" "$TARGET_DIR/plugins/"
        fi
        if [ -d "${QT6_DIR}/plugins/imageformats" ]; then
            cp -rf "${QT6_DIR}/plugins/imageformats" "$TARGET_DIR/plugins/"
        fi
        if [ -d "${QT6_DIR}/plugins/styles" ]; then
            cp -rf "${QT6_DIR}/plugins/styles" "$TARGET_DIR/plugins/"
        fi
        if [ -d "${QT6_DIR}/plugins/tls" ]; then
            cp -rf "${QT6_DIR}/plugins/tls" "$TARGET_DIR/plugins/"
        fi
    fi
    
    # 复制Qt QML插件
    if [ -d "${QT6_DIR}/qml" ]; then
        mkdir -p "$TARGET_DIR/qml"
        # 复制常用的QML模块
        local qml_modules=("QtQuick" "QtQml" "QtGraphicalEffects" "QtMultimedia" "QtTest")
        for module in "${qml_modules[@]}"; do
            if [ -d "${QT6_DIR}/qml/$module" ]; then
                cp -rf "${QT6_DIR}/qml/$module" "$TARGET_DIR/qml/"
            fi
        done
    fi
    
    print_info "Qt运行时库复制完成"
}

# 安装项目
install_project() {
    if [[ "$INSTALL_AFTER_BUILD" == true ]]; then
        print_info "安装项目..."
        
        cd "$BUILD_DIR"
        
        # 根据是否有自定义安装路径决定安装目标
        if [[ -n "$CUSTOM_INSTALL_PATH" ]]; then
            # 如果是相对路径，转换为绝对路径以确保正确安装
            if [[ "${CUSTOM_INSTALL_PATH:0:1}" == "/" ]]; then
                # 已经是绝对路径
                INSTALL_TARGET="$CUSTOM_INSTALL_PATH"
            else
                # 转换为绝对路径（相对于项目根目录）
                INSTALL_TARGET="$(pwd)/../$CUSTOM_INSTALL_PATH"
            fi
        else
            INSTALL_TARGET="../bin"
        fi
        
        # 绕过make install，直接复制必要的文件
        print_info "使用直接复制方法进行安装到: $INSTALL_TARGET"
        
        # 创建安装目录
        mkdir -p "$INSTALL_TARGET"
        
        # 复制可执行文件
        if [ -f "./SCADASystem" ]; then
            cp -f "./SCADASystem" "$INSTALL_TARGET/"
            print_info "已复制可执行文件"
        else
            print_error "可执行文件不存在于构建目录"
            exit 1
        fi
        
        # 复制必要的库文件
        if [ -f "./src/libSCADASystemQml.so" ]; then
            mkdir -p "$INSTALL_TARGET/qml/SCADASystemQml"
            cp -f "./src/libSCADASystemQml.so" "$INSTALL_TARGET/qml/SCADASystemQml/"
        fi
        
        # 复制QML插件
        if [ -d "./qml/plugins" ]; then
            mkdir -p "$INSTALL_TARGET/qml"
            cp -rf "./qml/plugins" "$INSTALL_TARGET/qml/"
        fi
        
        # 复制其他必要文件
        if [ -f "./run.sh" ]; then
            cp -f "./run.sh" "$INSTALL_TARGET/"
        fi
        
        # 复制资源文件（避免复制多余目录结构）
        if [ -d "./qml" ] && [ ! -L "./qml" ]; then
            # 只复制qml目录内容，不覆盖已有的qml/plugins
            rsync -av --exclude='plugins' "./qml/" "$INSTALL_TARGET/qml/" 2>/dev/null || cp -rf "./qml" "$INSTALL_TARGET/" 2>/dev/null || true
        fi
        
        if [ -d "./resources" ]; then
            cp -rf "./resources" "$INSTALL_TARGET/"
        fi
        
        if [ -d "./editor" ]; then
            cp -rf "./editor" "$INSTALL_TARGET/"
        fi
        
        # 复制Qt运行时库
        print_info "复制Qt运行时库..."
        copy_qt_libraries "$INSTALL_TARGET"
        
        # 确保不创建多余的 bin/bin 结构
        if [[ -n "$CUSTOM_INSTALL_PATH" ]]; then
            # 对于自定义路径，不做特殊处理
            :
        else
            # 对于默认路径，确保不创建多余的bin/bin结构
            if [ -d "$INSTALL_TARGET/bin" ] && [ -f "$INSTALL_TARGET/bin/SCADASystem" ] && [ -f "$INSTALL_TARGET/SCADASystem" ]; then
                print_info "移除多余的 $INSTALL_TARGET/bin 目录..."
                rm -rf "$INSTALL_TARGET/bin"
            fi
        fi
        
        print_success "项目安装成功"
        cd ..
    fi
}

# 仅安装项目（不构建）
install_only() {
    if [[ "$INSTALL_ONLY" == true ]]; then
        print_info "检查构建目录是否存在..."
        
        if [[ ! -d "$BUILD_DIR" ]]; then
            print_error "构建目录 $BUILD_DIR 不存在！"
            print_error "请先执行 ./build.sh 进行构建，然后再执行 ./build.sh --install"
            exit 1
        fi
        
        if [[ ! -f "$BUILD_DIR/Makefile" ]]; then
            print_error "构建文件不存在！"
            print_error "请先执行 ./build.sh 进行构建，然后再执行 ./build.sh --install"
            exit 1
        fi
        
        print_info "构建目录存在，开始安装..."
        
        cd "$BUILD_DIR"
        
        # 绕过make install，直接复制必要的文件
        print_info "使用直接复制方法进行安装..."
        
        # 创建安装目录
        if [[ -n "$CUSTOM_INSTALL_PATH" ]]; then
            INSTALL_TARGET="$CUSTOM_INSTALL_PATH"
        else
            INSTALL_TARGET="../bin"
        fi
        
        mkdir -p "$INSTALL_TARGET"
        
        # 复制可执行文件
        if [ -f "./SCADASystem" ]; then
            cp -f "./SCADASystem" "$INSTALL_TARGET/"
            print_info "已复制可执行文件"
        else
            print_error "可执行文件不存在于构建目录"
            exit 1
        fi
        
        # 复制必要的库文件
        if [ -f "./src/libSCADASystemQml.so" ]; then
            mkdir -p "$INSTALL_TARGET/qml/SCADASystemQml"
            cp -f "./src/libSCADASystemQml.so" "$INSTALL_TARGET/qml/SCADASystemQml/"
        fi
        
        # 复制QML插件
        if [ -d "./qml/plugins" ]; then
            mkdir -p "$INSTALL_TARGET/qml"
            cp -rf "./qml/plugins" "$INSTALL_TARGET/qml/"
        fi
        
        # 复制其他必要文件
        if [ -f "./run.sh" ]; then
            cp -f "./run.sh" "$INSTALL_TARGET/"
        fi
        
        # 复制资源文件（避免复制多余目录结构）
        if [ -d "./qml" ] && [ ! -L "./qml" ]; then
            # 只复制qml目录内容，不覆盖已有的qml/plugins
            rsync -av --exclude='plugins' "./qml/" "$INSTALL_TARGET/qml/" 2>/dev/null || cp -rf "./qml" "$INSTALL_TARGET/" 2>/dev/null || true
        fi
        
        if [ -d "./resources" ]; then
            cp -rf "./resources" "$INSTALL_TARGET/"
        fi
        
        if [ -d "./editor" ]; then
            cp -rf "./editor" "$INSTALL_TARGET/"
        fi
        
        # 复制Qt运行时库
        print_info "复制Qt运行时库..."
        copy_qt_libraries "$INSTALL_TARGET"
        
        # 确保不创建多余的bin/bin结构
        if [[ -z "$CUSTOM_INSTALL_PATH" ]]; then
            # 只在默认路径检查多余的bin/bin结构
            if [ -d "$INSTALL_TARGET/bin" ] && [ -f "$INSTALL_TARGET/bin/SCADASystem" ] && [ -f "$INSTALL_TARGET/SCADASystem" ]; then
                print_info "移除多余的 $INSTALL_TARGET/bin 目录..."
                rm -rf "$INSTALL_TARGET/bin"
            fi
        fi
        
        print_success "项目安装成功"
        cd ..
    fi
}

# 主执行
main() {
    print_info "开始基于 Qt6 的 Huayan SCADA System 构建"
    
    detect_platform
    find_qt6 || exit 1
    parse_arguments "$@"
    
    # 如果是分布式清理模式，则清理构建目录和安装目录
     if [[ "$DISTCLEAN" == true ]]; then
         if [[ -d "$BUILD_DIR" ]]; then
             print_info "清理构建目录: $BUILD_DIR"
             rm -rf "$BUILD_DIR"
         fi
         
         INSTALL_DIR="$(dirname "$BUILD_DIR")/bin"
         if [[ -d "$INSTALL_DIR" ]]; then
             print_info "清理安装目录: $INSTALL_DIR"
             rm -rf "$INSTALL_DIR"
         fi
         
         print_success "分布式清理完成!"
         return 0
     fi
     
     # 如果是仅清理模式，则只清理构建目录
     if [[ "$CLEAN_ONLY" == true ]]; then
         if [[ -d "$BUILD_DIR" ]]; then
             print_info "清理构建目录: $BUILD_DIR"
             rm -rf "$BUILD_DIR"
         fi
         print_success "清理完成!"
         return 0
     fi
     
     # 如果是仅安装模式，则只安装而不构建
     if [[ "$INSTALL_ONLY" == true ]]; then
         install_only
         print_success "安装完成!"
         if [[ -n "$CUSTOM_INSTALL_PATH" ]]; then
             print_info "可执行文件已安装到: $CUSTOM_INSTALL_PATH"
             print_info "要运行应用程序，请进入 $CUSTOM_INSTALL_PATH 并执行生成的可执行文件"
         else
             print_info "可执行文件已安装到: $(dirname "$BUILD_DIR")/bin/"
             print_info "要运行应用程序，请进入 $(dirname "$BUILD_DIR")/bin/ 并执行生成的可执行文件"
         fi
         return 0
     fi
     
     # 如果是重建模式，先清理再构建
     if [[ "$REBUILD" == true ]]; then
         if [[ -d "$BUILD_DIR" ]]; then
             print_info "清理构建目录: $BUILD_DIR"
             rm -rf "$BUILD_DIR"
         fi
     fi
    
    prepare_environment
    prepare_build_directory
    configure_project
    build_project
    install_project
    
    print_success "构建成功完成!"
    print_info "构建文件位于: $BUILD_DIR/"
    
    if [[ "$INSTALL_AFTER_BUILD" == true ]]; then
        if [[ -n "$CUSTOM_INSTALL_PATH" ]]; then
            print_info "可执行文件已安装到: $CUSTOM_INSTALL_PATH"
            print_info "要运行应用程序，请进入 $CUSTOM_INSTALL_PATH 并执行生成的可执行文件"
        else
            print_info "可执行文件已安装到: $(dirname "$BUILD_DIR")/bin/"
            print_info "要运行已安装的应用程序，请进入 $(dirname "$BUILD_DIR")/bin/ 并执行生成的可执行文件"
            print_info "或者执行 $(dirname "$BUILD_DIR")/bin/run.sh 脚本来启动应用程序"
        fi
    else
        print_info "构建完成。可执行文件位于: $BUILD_DIR/"
        print_info "要运行应用程序，请进入 $BUILD_DIR/ 并执行生成的可执行文件"
    fi
}

# Execute main function with all arguments
main "$@"