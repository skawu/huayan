# 华颜工业SCADA系统

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

## 技术栈

- **核心框架**：Qt 6.8 LTS (C++20 + QML)
- **构建系统**：CMake 3.24+
- **Qt 组件**：Core, Quick, Network, SerialBus, Sql, Charts, QuickControls2
- **QML 插件架构**：组件模块化的动态插件

## 项目结构

```
huayan/
├── CMakeLists.txt          # 顶层 CMake 配置
├── src/
│   ├── CMakeLists.txt      # 主应用 CMake 配置
│   ├── main.cpp            # 应用程序入口点
│   ├── resources.qrc       # QML 资源文件
│   ├── communication/
│   │   ├── modbustcpdriver.h
│   │   └── modbustcpdriver.cpp
│   └── core/
│       ├── tagmanager.h
│       ├── tagmanager.cpp
│       ├── dataprocessor.h
│       └── dataprocessor.cpp
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
│       │   └── Motor.qml
│       └── ChartComponents/
│           ├── CMakeLists.txt
│           ├── qmldir
│           ├── TrendChart.qml
│           └── BarChart.qml
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
  - Windows: MSVC 2022
  - Linux: GCC 11+

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

### 使用命令行

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