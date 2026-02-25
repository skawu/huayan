# Huayan SCADA System

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Qt](https://img.shields.io/badge/Qt-6.8+-green.svg)](https://www.qt.io/)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20Windows%20%7C%20macOS-lightgrey.svg)]()

Huayan SCADA System is a modern industrial monitoring and data acquisition system designed for manufacturing, energy, and process control industries. The system adopts a dual-mode architecture, providing intuitive visual design tools and high-performance real-time monitoring capabilities.

## 🌟 Key Features

### 🔧 Designer Mode
- **Drag-and-drop Layout Editing**: Intuitive visual interface design tool
- **Rich Component Library**: Pre-built 6 common industrial monitoring components
- **Real-time Preview**: Instant visualization of design effects
- **Property Configuration Panel**: Fine-grained component parameter adjustment
- **Grid Alignment Assistance**: Precise layout control

### 📊 Runtime Mode  
- **Real-time Data Monitoring**: Millisecond-level data update display
- **Multi-data Source Support**: Modbus, OPC UA, MQTT and other protocols
- **Alarm Management System**: Intelligent alarm and event processing
- **Historical Data Query**: Trend analysis and report generation
- **Multi-screen Display Support**: Adaptable to different scale monitoring needs

### 🏗️ System Architecture
- **Dual-mode Separation**: Complete independence between design time and runtime
- **Modular Design**: Clear component hierarchy structure
- **Cross-platform Support**: Full compatibility with Linux, Windows, macOS
- **Extensible Architecture**: Plugin-based components and custom development interfaces

## 📁 Project Structure

```
huayan-scada/
├── designer/              # 🎨 SCADA Designer Application
│   ├── main.qml          # Designer main interface
│   └── src/main.cpp      # Designer entry program
├── runtime/               # 📊 SCADA Runtime Application  
│   ├── main.qml          # Runtime monitoring interface
│   └── src/main.cpp      # Runtime entry program
├── shared/                # 🔧 Shared Component Library
│   ├── components/       # Reusable UI components
│   ├── models/           # Business logic models
│   ├── resources/        # Shared resource files
│   └── themes/           # Theme style configuration
├── docs/                  # 📚 Documentation
│   ├── developer_guide.md # Developer guide
│   └── roadmap.md        # Project development plan
├── examples/              # 💡 Usage Examples
│   └── steel_plant_monitoring/ # Steel plant monitoring example
├── scripts/               # 🛠️ Helper Scripts
│   ├── package_with_deps.sh   # Dependency packaging script
│   └── run.sh.in         # Run script template
├── projects/              # 📁 User Project Directory
├── tests/                 # 🧪 Test Code
└── assets/                # 🎨 Static Resource Files
```

## 🚀 Quick Start

### System Requirements
- **Operating System**: Linux (Ubuntu 20.04+/CentOS 8+) / Windows 10+ / macOS 10.15+
- **Qt Version**: Qt 6.8 or higher
- **Compiler**: GCC 9+/Clang 10+/MSVC 2019+
- **Memory**: Minimum 4GB RAM, recommended 8GB+
- **Storage**: At least 2GB available disk space

### Environment Setup

```bash
# 1. Clone the project
git clone https://github.com/skawu/huayan.git
cd huayan

# 2. Configure Qt environment (auto-detection)
./setup_env.sh

# 3. Verify environment
source ~/.huayan_scada_env
```

### Build Project

```bash
# Full build (recommended)
./build.sh --all

# Build designer only
./build.sh --designer

# Build runtime only
./build.sh --runtime

# Clean rebuild
./build.sh --clean --all
```

### Run System

```bash
# Smart launch (auto mode selection)
./scada_launcher.sh

# Launch designer mode
./scada_launcher.sh --designer

# Launch runtime mode  
./scada_launcher.sh --runtime
```

## 🎯 Usage Guide

### Designer Mode Operations
1. **Launch Designer**: Run `./scada_launcher.sh --designer`
2. **Select Components**: Choose required components from the left component library
3. **Drag Layout**: Drag components to the central canvas area
4. **Adjust Properties**: Configure component parameters in the right property panel
5. **Save Project**: Use toolbar to save design results

### Runtime Mode Operations
1. **Launch Runtime**: Run `./scada_launcher.sh --runtime`
2. **Load Project**: System automatically loads saved monitoring layouts
3. **Real-time Monitoring**: View real-time data updates of various components
4. **Handle Alarms**: Respond to system-generated alarm information
5. **Data Analysis**: Use historical data query functions

## 🔧 Development Documentation

For detailed development documentation, please refer to:
- [Developer Guide](docs/developer_guide.md) - System architecture and API documentation
- [Secondary Development Manual](二次开发手册.md) - Custom component development tutorial
- [Software Design Document](华颜软件设计文档.md) - Detailed technical specifications

## 📈 Project Status

### ✅ Completed Features
- [x] Dual-mode architecture separation
- [x] Drag-and-drop layout editor
- [x] Basic industrial component library
- [x] Real-time data simulation display
- [x] Standardized build system
- [x] Cross-platform support

### 🚧 In Development
- [ ] Industrial communication protocol integration (Modbus/OPC UA)
- [ ] Project file import/export functionality
- [ ] Advanced data analysis components
- [ ] User permission management system

### 🔮 Planned Features
- [ ] 3D visualization monitoring
- [ ] Mobile platform adaptation
- [ ] Cloud deployment support
- [ ] AI-assisted diagnostic functions

## 🤝 Contribution Guidelines

Welcome to participate in project development! Please follow these steps:

1. Fork the project repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

### Development Standards
- Follow small-granularity commit principle
- Use meaningful commit messages
- Maintain code style consistency
- Write necessary test cases

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## 📞 Contact

- **Project Homepage**: [https://github.com/skawu/huayan](https://github.com/skawu/huayan)
- **Issue Tracking**: [Issues](https://github.com/skawu/huayan/issues)
- **Development Discussion**: [Discussions](https://github.com/skawu/huayan/discussions)

---

**Huayan SCADA System** - Making industrial monitoring simpler and smarter! 🚀