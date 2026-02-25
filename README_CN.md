# Huayan SCADA System - 华颜SCADA系统

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Qt](https://img.shields.io/badge/Qt-6.8+-green.svg)](https://www.qt.io/)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20Windows%20%7C%20macOS-lightgrey.svg)]()

华颜SCADA系统是一个现代化的工业监控和数据采集系统，专为制造业、能源和过程控制行业设计。系统采用双模式架构，提供直观的可视化设计工具和高性能的实时监控功能。

## 🌟 核心特性

### 🔧 设计器模式 (Designer Mode)
- **拖拽式布局编辑**：直观的可视化界面设计工具
- **丰富的组件库**：预置6种常用工业监控组件
- **实时预览功能**：设计效果即时呈现
- **属性配置面板**：精细的组件参数调节
- **网格对齐辅助**：精确的布局控制

### 📊 运行时模式 (Runtime Mode)  
- **实时数据监控**：毫秒级数据更新显示
- **多数据源支持**：Modbus、OPC UA、MQTT等协议
- **告警管理系统**：智能报警和事件处理
- **历史数据查询**：趋势分析和报表生成
- **多屏显示支持**：适应不同规模的监控需求

### 🏗️ 系统架构
- **双模式分离**：设计时与运行时完全独立
- **模块化设计**：清晰的组件层次结构
- **跨平台支持**：Linux、Windows、macOS全平台兼容
- **可扩展架构**：插件化组件和自定义开发接口

## 📁 项目结构

```
huayan-scada/
├── designer/              # 🎨 SCADA设计器应用
│   ├── main.qml          # 设计器主界面
│   └── src/main.cpp      # 设计器入口程序
├── runtime/               # 📊 SCADA运行时应用  
│   ├── main.qml          # 运行时监控界面
│   └── src/main.cpp      # 运行时入口程序
├── shared/                # 🔧 共享组件库
│   ├── components/       # 可复用UI组件
│   ├── models/           # 业务逻辑模型
│   ├── resources/        # 共享资源文件
│   └── themes/           # 主题样式配置
├── docs/                  # 📚 文档资料
│   ├── developer_guide.md # 开发者指南
│   └── roadmap.md        # 项目发展规划
├── examples/              # 💡 使用示例
│   └── steel_plant_monitoring/ # 钢铁厂监控示例
├── scripts/               # 🛠️ 辅助脚本
│   ├── package_with_deps.sh   # 依赖打包脚本
│   └── run.sh.in         # 运行脚本模板
├── projects/              # 📁 用户项目目录
├── tests/                 # 🧪 测试代码
└── assets/                # 🎨 静态资源文件
```

## 🚀 快速开始

### 系统要求
- **操作系统**: Linux (Ubuntu 20.04+/CentOS 8+) / Windows 10+ / macOS 10.15+
- **Qt版本**: Qt 6.8 或更高版本
- **编译器**: GCC 9+/Clang 10+/MSVC 2019+
- **内存**: 最低4GB RAM，推荐8GB+
- **存储**: 至少2GB可用磁盘空间

### 环境配置

```bash
# 1. 克隆项目
git clone https://github.com/skawu/huayan.git
cd huayan

# 2. 配置Qt环境（自动检测）
./setup_env.sh

# 3. 验证环境
source ~/.huayan_scada_env
```

### 构建项目

```bash
# 完整构建（推荐）
./build.sh --all

# 仅构建设计器
./build.sh --designer

# 仅构建运行时
./build.sh --runtime

# 清理重新构建
./build.sh --clean --all
```

### 运行系统

```bash
# 智能启动（自动选择模式）
./scada_launcher.sh

# 启动设计器模式
./scada_launcher.sh --designer

# 启动运行时模式  
./scada_launcher.sh --runtime
```

## 🎯 使用指南

### 设计器模式操作
1. **启动设计器**：运行 `./scada_launcher.sh --designer`
2. **选择组件**：从左侧组件库中选择所需组件
3. **拖拽布局**：将组件拖拽到中央画布区域
4. **调整属性**：在右侧属性面板中配置组件参数
5. **保存项目**：使用工具栏保存设计成果

### 运行时模式操作
1. **启动运行时**：运行 `./scada_launcher.sh --runtime`
2. **加载项目**：系统自动加载已保存的监控布局
3. **实时监控**：查看各组件的实时数据更新
4. **处理告警**：响应系统发出的报警信息
5. **数据分析**：使用历史数据查询功能

## 🔧 开发文档

详细的开发文档请参考：
- [开发者指南](docs/developer_guide.md) - 系统架构和API说明
- [二次开发手册](二次开发手册.md) - 自定义组件开发教程
- [软件设计文档](华颜软件设计文档.md) - 详细技术规格

## 📈 项目状态

### ✅ 已完成功能
- [x] 双模式架构分离
- [x] 拖拽式布局编辑器
- [x] 基础工业组件库
- [x] 实时数据模拟显示
- [x] 标准化构建系统
- [x] 跨平台支持

### 🚧 开发中功能
- [ ] 工业通信协议集成（Modbus/OPC UA）
- [ ] 项目文件导入导出功能
- [ ] 高级数据分析组件
- [ ] 用户权限管理系统

### 🔮 规划中功能
- [ ] 3D可视化监控
- [ ] 移动端适配
- [ ] 云端部署支持
- [ ] AI辅助诊断功能

## 🤝 贡献指南

欢迎参与项目开发！请遵循以下步骤：

1. Fork 项目仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 开发规范
- 遵循小粒度提交原则
- 使用有意义的提交信息
- 保持代码风格一致性
- 编写必要的测试用例

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 联系方式

- **项目主页**: [https://github.com/skawu/huayan](https://github.com/skawu/huayan)
- **问题反馈**: [Issues](https://github.com/skawu/huayan/issues)
- **开发讨论**: [Discussions](https://github.com/skawu/huayan/discussions)

---

**Huayan SCADA System** - 让工业监控变得更简单、更智能！ 🚀

# 华颜工业SCADA系统

[![CI/CD Pipeline](https://github.com/skawu/huayan/actions/workflows/ci.yml/badge.svg)](https://github.com/skawu/huayan/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Qt Version](https://img.shields.io/badge/Qt-6.8.3-green.svg)](https://www.qt.io/)

## 项目概述

**华颜**（Huayan）是一个基于 Qt 6.8 LTS、C++20 和 QML 构建的轻量级工业 SCADA（监控与数据采集）系统。该系统通过模块化、可扩展的架构提供工业过程的实时监控和控制。

### 关于项目名称

- **项目名称**：华颜（Huayan）
- **全称**：华颜工业SCADA系统（Huayan Industrial SCADA System）
- **代码命名规范**：代码库中的关键函数和变量使用"HY"前缀（华颜缩写）以保持一致性

### 语言支持
- [中文](README_CN.md)（当前）
- [English](README.md)（英文版）

### 主要功能

- **设备通信**：Modbus TCP 驱动，支持连接管理、数据读写和错误处理
- **标签系统**：集中式数据管理，支持标签分组、值变化通知和 QML 绑定
- **模块化 QML 组件**：工业组件（阀门、储罐、电机）、基础组件（指示器、按钮）和图表组件（趋势图、柱状图）
- **配置编辑器**：拖放界面，用于创建和管理过程可视化
- **实时数据处理**：从设备连续收集数据，可配置采集间隔
- **跨平台支持**：Windows (MSVC 2022) 和 Linux (GCC 11+)

### 新功能（2026-02-13）

- **全面的单元测试覆盖**：添加了C++和QML单元测试，包括TagManager、ConfigManager、ExtensionManager等核心模块的测试
- **QML语法错误修复**：修复了editor.qml等文件中的语法错误，提升了代码质量和稳定性
- **增强的配置编辑器**：添加了画布分层、对齐吸附和批量编辑功能
- **丰富的组件库**：添加了工业专用组件（仪表盘、趋势图、工控按钮/指示灯等）
- **离线工程导出/导入**：支持无网络工业现场部署
- **优化的实时数据绑定**：动态刷新，延迟＜1s
- **时序数据库集成**：支持InfluxDB/TimescaleDB用于历史数据查询
- **增强的3D可视化**：深度集成WebGL/Three.js，支持数字孪生场景

## 技术栈

- **核心框架**：Qt 6.8 LTS (C++20 + QML)
- **构建系统**：CMake 3.24+
- **Qt 组件**：Core, Quick, Network, SerialBus, Sql, Charts, QuickControls2
- **QML 插件架构**：组件模块化的动态插件
- **CI/CD 流水线**：GitHub Actions 自动化构建和测试
- **版本控制**：Git 与 GitHub
- **3D 可视化**：Three.js 用于数字孪生场景
- **时序数据库**：InfluxDB/TimescaleDB 用于历史数据存储

## 项目结构

```
huayan/
├── CMakeLists.txt          # 顶层 CMake 配置
├── src/
│   ├── CMakeLists.txt      # 主应用 CMake 配置
│   ├── main.cpp            # 应用程序入口点
│   ├── resources.qrc       # QML 资源文件
│   ├── communication/
│   │   ├── hymodbustcpdriver.h
│   │   └── hymodbustcpdriver.cpp
│   └── core/
│       ├── tagmanager.h
│       ├── tagmanager.cpp
│       ├── dataprocessor.h
│       ├── dataprocessor.cpp
│       ├── timeseriesdatabase.h
│       └── timeseriesdatabase.cpp
├── qml/
│   ├── main.qml            # 主 QML 界面
│   ├── DragAndDropHelper.qml  # 拖放功能
│   └── plugins/
│       ├── CMakeLists.txt  # 插件 CMake 配置
│       ├── BasicComponents/
│       │   ├── CMakeLists.txt
│       │   ├── qmldir
│       │   ├── Indicator.qml
│       │   ├── PushButton.qml
│       │   └── TextLabel.qml
│       ├── IndustrialComponents/
│       │   ├── CMakeLists.txt
│       │   ├── qmldir
│       │   ├── Valve.qml
│       │   ├── Tank.qml
│       │   ├── Motor.qml
│       │   ├── Gauge.qml
│       │   ├── IndustrialButton.qml
│       │   └── IndustrialIndicator.qml
│       ├── ChartComponents/
│       │   ├── CMakeLists.txt
│       │   ├── qmldir
│       │   ├── TrendChart.qml
│       │   └── BarChart.qml
│       └── ThreeDComponents/
│           ├── CMakeLists.txt
│           ├── qmldir
│           ├── ThreeDScene.qml
│           ├── ModelLoader.qml
│           └── CameraController.qml
├── bin/                    # 自包含安装目录
│   ├── bin/
│   │   └── huayan          # 主可执行文件
│   ├── lib/                # 所需的 Qt 库
│   ├── plugins/
│   │   └── platforms/      # Qt 平台插件
│   ├── qml/                # QML 插件和组件
│   └── run.sh              # 运行脚本，处理环境设置
└── README.md               # 此文件
```

## 编译说明

### 先决条件

- Qt 6.8 LTS 或更高版本（Linux 下安装在 `/opt/Qt/6.8.3`）
- CMake 3.22 或更高版本（Qt 提供的 CMake 位于 `/opt/Qt/Tools/CMake`）
- 支持 C++20 的编译器：
  - Windows: MSVC 2022 或 MinGW-w64
  - Linux: GCC 11+ 或 Clang 12+

### 使用 Qt Creator

1. **打开项目**
   - 启动 Qt Creator
   - 选择 "文件 > 打开文件或项目"
   - 导航到项目目录并选择 `CMakeLists.txt`
   - 点击 "打开"

2. **配置项目**
   - Qt Creator 将自动检测 CMake 配置
   - 选择适当的 Qt 版本（6.8 LTS）
   - 选择编译器（Windows 上为 MSVC 2022，Linux 上为 GCC 11+）
   - 点击 "配置项目"

3. **构建项目**
   - 点击 "构建" 按钮（锤子图标）或按 Ctrl+B
   - 等待构建成功完成

4. **运行应用程序**
   - 点击 "运行" 按钮（绿色三角形）或按 Ctrl+R

### 使用构建脚本（推荐）

为了更轻松地使用正确的 Qt6 环境进行设置，我们提供了适用于两个平台的自动化构建脚本：

#### Linux/macOS

1. **使脚本可执行：**
   ```bash
   chmod +x build.sh
   ```

2. **运行构建脚本：**
   ```bash
   # 构建发布版本（默认）
   ./build.sh
   
   # 构建调试版本
   ./build.sh --debug
   
   # 清理构建
   ./build.sh --clean
   
   # 使用指定数量的并行作业构建
   ./build.sh --jobs 8
   
   # 构建并安装
   ./build.sh --install
   ```

#### Windows

1. **运行构建脚本：**
   ```cmd
   REM 构建发布版本（默认）
   build.bat
   
   REM 构建调试版本
   build.bat --debug
   
   REM 清理构建
   build.bat --clean
   
   REM 使用指定数量的并行作业构建
   build.bat --jobs 8
   
   REM 构建并安装
   build.bat --install
   ```

### 使用命令行

如果您更喜欢手动构建：

1. **创建构建目录**
   ```bash
   mkdir build && cd build
   ```

2. **使用 CMake 配置**（确保 Qt6 在您的 PATH 中）
   ```bash
   cmake .. -DCMAKE_PREFIX_PATH=/opt/Qt/6.8.3/gcc_64 -DCMAKE_BUILD_TYPE=Release
   ```

3. **构建项目**
   ```bash
   make -j$(nproc)
   ```

4. **安装应用程序**（到自包含的 bin 目录）
   ```bash
   make install
   ```

5. **运行应用程序**
   ```bash
   # 使用运行脚本（处理环境设置）
   ../bin/run.sh
   
   # 或手动设置环境变量
   LD_LIBRARY_PATH=../bin/lib QT_QPA_PLATFORM_PLUGIN_PATH=../bin/plugins/platforms ../bin/bin/huayan
   ```

1. **创建构建目录**
   ```bash
   mkdir build && cd build
   ```

2. **使用 CMake 配置**（使用 Qt 提供的 CMake）
   ```bash
   /opt/Qt/Tools/CMake/bin/cmake .. -DCMAKE_PREFIX_PATH=/opt/Qt/6.8.3/gcc_64 -DCMAKE_BUILD_TYPE=Release
   ```

3. **构建项目**
   ```bash
   make -j$(nproc)
   ```

4. **安装应用程序**（到自包含的 bin 目录）
   ```bash
   make install
   ```

5. **运行应用程序**
   ```bash
   # 使用运行脚本（处理环境设置）
   ../bin/run.sh
   
   # 或手动设置环境变量
   LD_LIBRARY_PATH=../bin/lib QT_QPA_PLATFORM_PLUGIN_PATH=../bin/plugins/platforms ../bin/bin/huayan
   ```

## QML 动态插件

### 插件编译

QML 组件被构建为动态插件（Windows 上为 DLL，Linux 上为 SO 文件），并在构建过程中自动放置在 `qml/plugins` 目录中。

### 插件加载

应用程序通过以下机制在运行时加载插件：

1. **QML 导入路径**：main.cpp 文件将插件目录添加到 QML 引擎的导入路径
2. **动态加载**：当在 QML 文件中引用时，QML 组件会按需加载
3. **插件结构**：每个插件都有一个 `qmldir` 文件，定义可用的组件类型

### 插件管理

- **添加新组件**：在适当的插件目录中创建新的 QML 文件并更新 `qmldir` 文件
- **删除组件**：删除 QML 文件并更新 `qmldir` 文件
- **更新组件**：修改 QML 文件并重建项目

## 核心功能测试

### 动态组件添加/删除

1. **打开配置编辑器**选项卡
2. **从组件库中拖动组件**到画布
3. **根据需要调整组件大小和位置**
4. **使用保存功能保存布局**
5. **重新启动应用程序**并验证组件是否正确加载

### 拖放布局

1. **打开配置编辑器**选项卡
2. **从库中拖动组件**到画布
3. **点击并拖动组件**以重新定位它们
4. **使用调整大小手柄**（右下角）调整组件大小
5. **验证**释放鼠标后组件保持在原位

### 标签值绑定

1. **打开标签管理**选项卡
2. **添加一个新标签**，包含名称和初始值
3. **打开配置编辑器**选项卡
4. **向画布添加一个组件**
5. **选择组件**并将其 `tagName` 属性设置为您创建的标签
6. **打开仪表板**选项卡并验证组件显示标签值
7. **在标签管理选项卡中更新标签值**并验证组件自动更新

### 设备通信

1. **打开仪表板**选项卡
2. **使用连接参数连接到 Modbus TCP 设备**
3. **验证**连接状态显示"已连接"
4. **添加映射到 Modbus 寄存器的标签**
5. **开始数据收集**并验证标签值随设备数据更新
6. **通过更新标签值测试命令发送**并验证它们已发送到设备

## 故障排除

### 常见问题

1. **QML 组件未找到**
   - 检查插件是否成功构建
   - 验证 QML 导入路径设置正确
   - 确保 `qmldir` 文件格式正确

2. **Modbus 连接失败**
   - 验证设备 IP 地址和端口正确
   - 检查设备是否通电且可访问
   - 确保防火墙设置允许 Modbus TCP 流量

3. **标签值未更新**
   - 验证标签映射到正确的 Modbus 寄存器
   - 检查数据收集是否激活
   - 确保设备响应 Modbus 请求

4. **编译错误**
   - 验证 Qt 6.8 LTS 安装正确
   - 检查是否使用 CMake 3.22+
   - 确保编译器支持 C++20

5. **Linux 上的平台插件问题**
   - 错误："Could not find the Qt platform plugin 'xcb'"
   - 解决方案：安装所需的系统包：`sudo apt-get install libxcb-cursor0`

6. **库加载错误**
   - 错误："error while loading shared libraries"
   - 解决方案：使用提供的 `run.sh` 脚本，它会设置正确的库路径
   - 替代方案：将 `LD_LIBRARY_PATH` 设置为指向 `bin/lib` 目录

## 总结

**华颜**工业SCADA系统是一个基于 Qt 6 的工业过程监控与控制综合解决方案。其模块化架构、动态 QML 插件和实时数据处理能力使其适用于各种工业应用。

### 项目标识

- **开源项目**：本项目基于 Apache License 2.0 开源
- **代码命名规范**：关键函数和变量使用"HY"前缀以保持一致性

### 系统优势

- **可扩展的组件架构**：易于添加新的自定义组件
- **实时数据处理**：具有可配置间隔的连续监控
- **直观的配置编辑器**：用于快速创建可视化的拖放界面
- **强大的通信**：具有错误处理和重连逻辑的 Modbus TCP 驱动
- **跨平台支持**：可在 Windows 和 Linux 上运行

凭借其对模块化、性能和易用性的关注，**华颜**工业SCADA系统为工业自动化项目提供了坚实的基础，承载着品牌对品质和创新的承诺。