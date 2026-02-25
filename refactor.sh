# 项目清理和重构脚本
#!/bin/bash

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$PROJECT_ROOT/backup_$(date +%Y%m%d_%H%M%S)"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 创建备份
create_backup() {
    log_info "创建项目备份: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    cp -r "$PROJECT_ROOT"/{src,examples,tests} "$BACKUP_DIR/" 2>/dev/null || true
}

# 重构目录结构
restructure_project() {
    log_info "重构项目目录结构..."
    
    # 创建标准目录结构
    mkdir -p "$PROJECT_ROOT"/{designer,runtime,shared/{components,themes,utils,models},projects,docs,tests}
    
    # 移动现有文件到合适位置
    if [ -d "$PROJECT_ROOT/src" ]; then
        # 移动设计器相关文件
        mkdir -p "$PROJECT_ROOT/designer/src"
        mv "$PROJECT_ROOT/src/designer_main.qml" "$PROJECT_ROOT/designer/main.qml" 2>/dev/null || true
        mv "$PROJECT_ROOT/src/main.cpp" "$PROJECT_ROOT/designer/src/" 2>/dev/null || true
        
        # 移动运行时相关文件
        mkdir -p "$PROJECT_ROOT/runtime/src"
        mv "$PROJECT_ROOT/src/runtime_main.qml" "$PROJECT_ROOT/runtime/main.qml" 2>/dev/null || true
        
        # 移动共享组件
        mkdir -p "$PROJECT_ROOT/shared/components"
        find "$PROJECT_ROOT/src" -name "*.qml" -not -path "*/designer*" -not -path "*/runtime*" -exec mv {} "$PROJECT_ROOT/shared/components/" \; 2>/dev/null || true
        
        # 移动核心模块
        mkdir -p "$PROJECT_ROOT/shared/models"
        mv "$PROJECT_ROOT/src/core" "$PROJECT_ROOT/shared/models/" 2>/dev/null || true
        mv "$PROJECT_ROOT/src/hmi" "$PROJECT_ROOT/shared/models/" 2>/dev/null || true
        mv "$PROJECT_ROOT/src/datasource" "$PROJECT_ROOT/shared/models/" 2>/dev/null || true
        mv "$PROJECT_ROOT/src/communication" "$PROJECT_ROOT/shared/models/" 2>/dev/null || true
        mv "$PROJECT_ROOT/src/editor" "$PROJECT_ROOT/shared/models/" 2>/dev/null || true
        
        # 移动主题和资源
        mkdir -p "$PROJECT_ROOT/shared/themes"
        mv "$PROJECT_ROOT/src/themes" "$PROJECT_ROOT/shared/" 2>/dev/null || true
        mv "$PROJECT_ROOT/src/resources" "$PROJECT_ROOT/shared/" 2>/dev/null || true
    fi
    
    log_info "目录结构重构完成"
}

# 更新CMake配置
update_cmake_configs() {
    log_info "更新CMake配置文件..."
    
    # 更新根CMakeLists.txt
    cat > "$PROJECT_ROOT/CMakeLists.txt" << 'EOF'
cmake_minimum_required(VERSION 3.16)

# 明确使用Qt安装包的工具
if(DEFINED ENV{QTDIR})
    set(CMAKE_PREFIX_PATH "$ENV{QTDIR}")
endif()

# 项目基本信息
project(HuayanSCADA VERSION 2.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Qt配置
find_package(Qt6 6.8 REQUIRED COMPONENTS
    Core Quick QuickControls2 Network Sql Charts
)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 设置输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# 包含目录
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/shared)

# 添加子目录
add_subdirectory(shared)
add_subdirectory(designer)
add_subdirectory(runtime)
EOF

    # 更新共享库CMakeLists.txt
    cat > "$PROJECT_ROOT/shared/CMakeLists.txt" << 'EOF'
# 共享库
add_library(HuayanShared INTERFACE)

# 包含目录
target_include_directories(HuayanShared INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/components
    ${CMAKE_CURRENT_SOURCE_DIR}/models
    ${CMAKE_CURRENT_SOURCE_DIR}/themes
    ${CMAKE_CURRENT_SOURCE_DIR}/utils
)

# 链接Qt库
target_link_libraries(HuayanShared INTERFACE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Network
    Qt6::Sql
    Qt6::Charts
)
EOF

    # 更新设计器CMakeLists.txt
    cat > "$PROJECT_ROOT/designer/CMakeLists.txt" << 'EOF'
cmake_minimum_required(VERSION 3.16)

# 明确指定使用Qt自带的CMake
if(DEFINED ENV{QTDIR})
    set(CMAKE_PREFIX_PATH "$ENV{QTDIR}")
endif()

# 查找Qt6
find_package(Qt6 6.8 REQUIRED COMPONENTS
    Core Quick QuickControls2 Network
)

# 启用Qt特性
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 包含目录
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../shared
)

# 设计器应用
qt_add_executable(SCADADesigner
    src/main.cpp
    main.qml
)

set_target_properties(SCADADesigner PROPERTIES
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(SCADADesigner PRIVATE
    HuayanShared
)

install(TARGETS SCADADesigner RUNTIME DESTINATION bin)
EOF

    # 更新运行时CMakeLists.txt
    cat > "$PROJECT_ROOT/runtime/CMakeLists.txt" << 'EOF'
cmake_minimum_required(VERSION 3.16)

# 明确指定使用Qt自带的CMake
if(DEFINED ENV{QTDIR})
    set(CMAKE_PREFIX_PATH "$ENV{QTDIR}")
endif()

# 查找Qt6
find_package(Qt6 6.8 REQUIRED COMPONENTS
    Core Quick QuickControls2 Network Sql Charts
)

# 启用Qt特性
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 包含目录
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../shared
)

# 运行时应用
qt_add_executable(SCADARuntime
    src/main.cpp
    main.qml
)

set_target_properties(SCADARuntime PROPERTIES
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(SCADARuntime PRIVATE
    HuayanShared
)

install(TARGETS SCADARuntime RUNTIME DESTINATION bin)
EOF

    log_info "CMake配置更新完成"
}

# 创建迁移指南
create_migration_guide() {
    log_info "创建迁移指南..."
    
    cat > "$PROJECT_ROOT/MIGRATION_GUIDE.md" << 'EOF'
# Huayan SCADA 项目迁移指南

## 迁移概述
本文档指导从旧项目结构迁移到新的模块化架构。

## 目录结构变化

### 旧结构
```
src/
├── core/
├── hmi/
├── datasource/
├── communication/
├── editor/
├── themes/
├── resources/
├── main.cpp
├── main.qml
├── designer_main.qml
└── runtime_main.qml
```

### 新结构
```
huayan-scada/
├── designer/
│   ├── src/main.cpp
│   └── main.qml
├── runtime/
│   ├── src/main.cpp
│   └── main.qml
├── shared/
│   ├── components/
│   ├── models/
│   │   ├── core/
│   │   ├── hmi/
│   │   ├── datasource/
│   │   ├── communication/
│   │   └── editor/
│   ├── themes/
│   └── utils/
└── projects/
```

## 迁移步骤

1. **备份当前项目**
   ```bash
   ./refactor.sh --backup
   ```

2. **执行自动重构**
   ```bash
   ./refactor.sh --restructure
   ```

3. **验证构建**
   ```bash
   ./build.sh --all
   ```

4. **测试功能**
   - 启动设计器验证界面功能
   - 启动运行时验证监控功能

## 注意事项

- 所有QML文件的import路径需要更新
- C++类的包含路径需要调整
- 资源文件引用路径需要修正
- 项目配置文件需要更新

## 回滚方案

如果迁移出现问题，可以从backup目录恢复：
```bash
# 恢复备份
cp -r backup_*/* .
```
EOF

    log_info "迁移指南创建完成"
}

# 主执行逻辑
main() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}Huayan SCADA 项目重构工具${NC}"
    echo -e "${BLUE}================================${NC}"
    
    case "${1:-}" in
        --backup)
            create_backup
            ;;
        --restructure)
            restructure_project
            update_cmake_configs
            create_migration_guide
            ;;
        --full)
            create_backup
            restructure_project
            update_cmake_configs
            create_migration_guide
            ;;
        *)
            echo "用法: $0 [--backup|--restructure|--full]"
            echo "  --backup      仅创建备份"
            echo "  --restructure 仅执行重构"
            echo "  --full        完整重构流程（默认）"
            ;;
    esac
    
    echo -e "${BLUE}================================${NC}"
    log_info "重构完成！请查看 MIGRATION_GUIDE.md 了解详细信息"
    echo -e "${BLUE}================================${NC}"
}

main "$@"