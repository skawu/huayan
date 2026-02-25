# Huayan Industrial SCADA System

<div align="center">

![Huayan SCADA](https://img.shields.io/badge/SCADA-Industrial%20Automation-blue)
![Qt](https://img.shields.io/badge/Qt-6.8+-green)
![License](https://img.shields.io/badge/license-Apache%202.0-blue)

**Professional Industrial Monitoring & Control System**

</div>

## 🎯 系统特色

- **双模式架构**: 设计器模式 + 运行时模式
- **现代化界面**: 基于Qt Quick的流畅用户体验
- **工业级组件**: 丰富的工业自动化专用组件库
- **跨平台支持**: Windows/Linux/macOS全平台兼容
- **开放扩展**: 模块化设计，易于二次开发
- **实时数据处理**: 动态刷新延迟 < 1秒
- **时序数据库集成**: 支持InfluxDB/TimescaleDB历史数据查询
- **3D可视化**: 深度集成WebGL/Three.js用于数字孪生场景

## 🏗️ 系统架构

```
huayan-scada/
├── designer/          # 设计器应用 (设计监控界面)
├── runtime/           # 运行时应用 (工业现场监控)
├── shared/            # 共享组件库
│   ├── components/    # 基础组件
│   ├── themes/        # 主题系统
│   └── utils/         # 工具函数
├── projects/          # 用户项目目录
├── docs/              # 文档资料
└── tests/             # 测试用例
```

## 🚀 快速开始

### 系统要求
- Qt 6.8 或更高版本
- CMake 3.22 或更高版本
- GCC 11 或更高版本 (Linux)
- Visual Studio 2022 或更高版本 (Windows)

### 安装依赖
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install qt6-base-dev qt6-declarative-dev qt6-charts-dev

# CentOS/RHEL
sudo yum install qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtcharts-devel
```

### 构建项目
```bash
# 克隆仓库
git clone http://github.com/skawu/huayan.git
cd huayan

# 构建所有组件
./build.sh --all

# 或分别构建
./build.sh --designer  # 构建设计器
./build.sh --runtime   # 构建运行时
```

### 启动系统
```bash
# 使用启动器（推荐）
./scada_launcher.sh

# 或直接启动
./bin/SCADADesigner  # 设计器模式
./bin/SCADARuntime   # 运行时模式
```

## 🛠️ 使用指南

### 设计器模式
1. 启动设计器应用
2. 创建新项目或打开现有项目
3. 从组件库拖拽组件到画布
4. 配置组件属性和数据绑定
5. 导出运行时包

### 运行时模式
1. 启动运行时应用
2. 加载导出的运行时包
3. 配置设备通信参数
4. 开始实时监控

## 📚 文档资源

- [用户使用指南](docs/user_guide.md) - 详细操作说明
- [开发者文档](docs/developer_guide.md) - 二次开发指南
- [API参考](docs/api_reference.md) - 组件接口文档
- [部署手册](docs/deployment_guide.md) - 系统部署说明

## 🤝 贡献指南

我们欢迎任何形式的贡献！

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 Apache License 2.0 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 技术支持

- 📧 邮箱: support@huayan-industry.com
- 💬 微信: huayan_scada_support
- 🌐 官网: https://www.huayan-industry.com

---

<p align="center">Made with ❤️ by Huayan Industrial Automation</p>
