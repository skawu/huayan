# 华颜工业SCADA系统 (Huayan Industrial SCADA System)

## Project Overview

**华颜** (Huayan) is a light-weight industrial SCADA (Supervisory Control and Data Acquisition) system built with Qt 6.8 LTS, C++20, and QML. The system provides real-time monitoring and control of industrial processes through a modular, extensible architecture.

### About the Name

- **Project Name**: 华颜 (Huayan)
- **Full Name**: 华颜工业SCADA系统 (Huayan Industrial SCADA System)
- **Code Naming Convention**: Key functions and variables in the codebase use the prefix "HY" (Huayan abbreviation) for consistency.

### Language Support
- [English](README.md) (Current)
- [中文](README_CN.md) (Chinese version)

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

### Key Features

- **Device Communication**: Modbus TCP driver with connection management, data reading/writing, and error handling
- **Tag System**: Centralized data management with tag grouping, value change notifications, and QML binding support
- **Modular QML Components**: Industrial components (valves, tanks, motors), basic components (indicators, buttons), and chart components (trend charts, bar charts)
- **Configuration Editor**: Drag-and-drop interface for creating and managing process visualizations
- **Real-time Data Processing**: Continuous data collection from devices with configurable intervals
- **Cross-platform Support**: Windows (MSVC 2022) and Linux (GCC 11+)

## Technical Stack

- **Core Framework**: Qt 6.8 LTS (C++20 + QML)
- **Build System**: CMake 3.24+
- **Qt Components**: Core, Quick, Network, SerialBus, Sql, Charts, QuickControls2
- **QML Plugin Architecture**: Dynamic plugins for component modularity

## Project Structure

```
huayan/
├── CMakeLists.txt          # Top-level CMake configuration
├── src/
│   ├── CMakeLists.txt      # Main application CMake configuration
│   ├── main.cpp            # Application entry point
│   ├── resources.qrc       # QML resource file
│   ├── communication/
│   │   ├── modbustcpdriver.h
│   │   └── modbustcpdriver.cpp
│   └── core/
│       ├── tagmanager.h
│       ├── tagmanager.cpp
│       ├── dataprocessor.h
│       └── dataprocessor.cpp
├── qml/
│   ├── main.qml            # Main QML interface
│   ├── DragAndDropHelper.qml  # Drag-and-drop functionality
│   └── plugins/
│       ├── CMakeLists.txt  # Plugins CMake configuration
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
├── bin/                    # Self-contained installation directory
│   ├── bin/
│   │   └── huayan          # Main executable
│   ├── lib/                # Required Qt libraries
│   ├── plugins/
│   │   └── platforms/      # Qt platform plugins
│   ├── qml/                # QML plugins and components
│   └── run.sh              # Run script with environment setup
└── README.md               # This file
```

## Compilation Instructions

### Prerequisites

- Qt 6.8 LTS or later (installed at `/opt/Qt/6.8.3` for Linux)
- CMake 3.22 or later (Qt-provided CMake at `/opt/Qt/Tools/CMake`)
- C++20 compatible compiler:
  - Windows: MSVC 2022
  - Linux: GCC 11+

### Using Qt Creator

1. **Open the Project**
   - Launch Qt Creator
   - Select "File > Open File or Project"
   - Navigate to the project directory and select `CMakeLists.txt`
   - Click "Open"

2. **Configure the Project**
   - Qt Creator will automatically detect the CMake configuration
   - Select the appropriate Qt version (6.8 LTS)
   - Choose the compiler (MSVC 2022 on Windows, GCC 11+ on Linux)
   - Click "Configure Project"

3. **Build the Project**
   - Click the "Build" button (hammer icon) or press Ctrl+B
   - Wait for the build to complete successfully

4. **Run the Application**
   - Click the "Run" button (green triangle) or press Ctrl+R

### Using Command Line

1. **Create Build Directory**
   ```bash
   mkdir build && cd build
   ```

2. **Configure with CMake** (using Qt-provided CMake)
   ```bash
   /opt/Qt/Tools/CMake/bin/cmake .. -DCMAKE_PREFIX_PATH=/opt/Qt/6.8.3/gcc_64 -DCMAKE_BUILD_TYPE=Release
   ```

3. **Build the Project**
   ```bash
   make -j$(nproc)
   ```

4. **Install the Application** (to self-contained bin directory)
   ```bash
   make install
   ```

5. **Run the Application**
   ```bash
   # Using the run script (handles environment setup)
   ../bin/run.sh
   
   # Or manually with environment variables
   LD_LIBRARY_PATH=../bin/lib QT_QPA_PLATFORM_PLUGIN_PATH=../bin/plugins/platforms ../bin/bin/huayan
   ```

## QML Dynamic Plugins

### Plugin Compilation

The QML components are built as dynamic plugins (DLLs on Windows, SO files on Linux) and are automatically placed in the `qml/plugins` directory during the build process.

### Plugin Loading

The application loads plugins at runtime through the following mechanism:

1. **QML Import Paths**: The main.cpp file adds the plugin directories to the QML engine's import paths
2. **Dynamic Loading**: QML components are loaded on demand when referenced in QML files
3. **Plugin Structure**: Each plugin has a `qmldir` file that defines the component types available

### Plugin Management

- **Adding New Components**: Create new QML files in the appropriate plugin directory and update the `qmldir` file
- **Removing Components**: Delete the QML file and update the `qmldir` file
- **Updating Components**: Modify the QML file and rebuild the project

## Core Functionality Testing

### Dynamic Component Addition/Removal

1. **Open the Configuration Editor** tab
2. **Drag components** from the Component Library to the Canvas
3. **Resize and reposition** components as needed
4. **Save the layout** using the save functionality
5. **Restart the application** and verify components are loaded correctly

### Drag-and-Drop Layout

1. **Open the Configuration Editor** tab
2. **Drag components** from the library to the canvas
3. **Click and drag** components to reposition them
4. **Use resize handles** (bottom-right corner) to adjust component sizes
5. **Verify** components stay in place after releasing the mouse

### Tag Value Binding

1. **Open the Tag Management** tab
2. **Add a new tag** with a name and initial value
3. **Open the Configuration Editor** tab
4. **Add a component** to the canvas
5. **Select the component** and set its `tagName` property to the tag you created
6. **Open the Dashboard** tab and verify the component displays the tag value
7. **Update the tag value** in the Tag Management tab and verify the component updates automatically

### Device Communication

1. **Open the Dashboard** tab
2. **Connect to a Modbus TCP device** using the connection parameters
3. **Verify** the connection status shows "Connected"
4. **Add tags** mapped to Modbus registers
5. **Start data collection** and verify tag values update with device data
6. **Test command sending** by updating tag values and verifying they're sent to the device

## Troubleshooting

### Common Issues

1. **QML Component Not Found**
   - Check that the plugin is built successfully
   - Verify the QML import path is set correctly
   - Ensure the `qmldir` file is properly formatted

2. **Modbus Connection Failed**
   - Verify the device IP address and port are correct
   - Check that the device is powered on and accessible
   - Ensure firewall settings allow Modbus TCP traffic

3. **Tag Values Not Updating**
   - Verify the tag is mapped to the correct Modbus register
   - Check that data collection is active
   - Ensure the device is responding to Modbus requests

4. **Compilation Errors**
   - Verify Qt 6.8 LTS is installed correctly
   - Check that CMake 3.22+ is being used
   - Ensure the compiler supports C++20

5. **Platform Plugin Issues on Linux**
   - Error: "Could not find the Qt platform plugin 'xcb'"
   - Solution: Install the required system package: `sudo apt-get install libxcb-cursor0`

6. **Library Loading Errors**
   - Error: "error while loading shared libraries"
   - Solution: Use the provided `run.sh` script which sets up the correct library paths
   - Alternative: Set `LD_LIBRARY_PATH` to point to the `bin/lib` directory

## Summary

**华颜** (Huayan) Industrial SCADA System is a Qt 6-based comprehensive solution for monitoring and controlling industrial processes. Its modular architecture, dynamic QML plugins, and real-time data processing capabilities make it suitable for a wide range of industrial applications.

### Project Identity

- **Open Source**: This project is released under the Apache License 2.0
- **Code Naming Convention**: Key functions and variables use the "HY" prefix for consistency

### System Strengths

- **Extensible Component Architecture**: Easy to add new custom components
- **Real-time Data Processing**: Continuous monitoring with configurable intervals
- **Intuitive Configuration Editor**: Drag-and-drop interface for quick visualization creation
- **Robust Communication**: Modbus TCP driver with error handling and reconnection logic
- **Cross-platform Support**: Works on both Windows and Linux

With its focus on modularity, performance, and ease of use, **华颜** Industrial SCADA System provides a solid foundation for industrial automation projects, carrying the brand's commitment to quality and innovation.