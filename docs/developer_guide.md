# Huayan SCADA System 开发者指南

## 项目架构说明

### 目录结构
```
huayan-scada/
├── designer/          # 设计器应用源码
│   ├── main.cpp       # 设计器入口点
│   ├── main.qml       # 设计器主界面
│   └── qml/           # 设计器QML组件
├── runtime/           # 运行时应用源码
│   ├── main.cpp       # 运行时入口点
│   ├── main.qml       # 运行时主界面
│   └── qml/           # 运行时QML组件
├── shared/            # 共享组件库
│   ├── components/    # 可复用UI组件
│   ├── themes/        # 主题和样式
│   └── utils/         # 工具函数库
├── src/               # 原始源码（逐步迁移）
├── docs/              # 文档目录
├── tests/             # 测试代码
├── build/             # 构建输出目录
└── bin/               # 可执行文件目录
```

## 开发环境搭建

### 必需工具
- Qt 6.8+ 开发环境
- CMake 3.22+
- GCC 11+ 或 MSVC 2022+
- Git 版本控制

### 环境变量设置
```bash
# Linux/MacOS
export QTDIR=/opt/Qt/6.8.3/gcc_64
export PATH=$QTDIR/bin:$PATH
export LD_LIBRARY_PATH=$QTDIR/lib:$LD_LIBRARY_PATH

# Windows (PowerShell)
$env:QTDIR="C:\Qt\6.8.3\mingw_64"
$env:PATH="$env:QTDIR\bin;$env:PATH"
```

## 编码规范

### C++编码规范
- 遵循 Google C++ Style Guide
- 使用现代C++特性 (C++20)
- 类名采用PascalCase
- 函数和变量采用camelCase
- 常量采用UPPER_SNAKE_CASE

### QML编码规范
- 组件名采用PascalCase
- 属性名采用camelCase
- 信号名采用on开头的PascalCase
- 私有属性以下划线开头

### 代码组织原则
1. **单一职责原则**: 每个类/组件只负责一个功能
2. **开闭原则**: 对扩展开放，对修改关闭
3. **依赖倒置**: 依赖抽象而非具体实现
4. **接口隔离**: 使用专门的接口而非胖接口

## 组件开发指南

### 基础组件开发
```qml
// components/BaseComponent.qml
import QtQuick 2.15

Item {
    id: root
    
    // 公共属性
    property string componentId: ""
    property string label: ""
    property bool enabled: true
    
    // 公共信号
    signal clicked()
    signal valueChanged(var newValue)
    
    // 内部实现...
}
```

### 工业组件开发
```qml
// components/IndustrialValve.qml
import QtQuick 2.15
import "BaseComponent.qml" as Base

Base {
    id: valve
    
    // 阀门特有属性
    property bool isOpen: false
    property real flowRate: 0.0
    
    // 数据绑定
    Binding {
        target: valve
        property: "isOpen"
        value: tagManager.getTagValue("valve_status")
    }
    
    // 视觉表现
    Rectangle {
        anchors.fill: parent
        color: isOpen ? "green" : "red"
        border.color: "black"
        border.width: 2
    }
}
```

## 数据流架构

### MVVM模式实现
```
View (QML) ←→ ViewModel (C++/JS) ←→ Model (数据源)
```

### 数据绑定机制
```cpp
// TagManager.h - 标签管理器
class TagManager : public QObject {
    Q_OBJECT
    
public:
    Q_INVOKABLE QVariant getTagValue(const QString& tagName);
    Q_INVOKABLE void setTagValue(const QString& tagName, const QVariant& value);
    
signals:
    void tagValueChanged(const QString& tagName, const QVariant& newValue);
};
```

## 测试策略

### 单元测试
```cpp
// tests/TestTagManager.cpp
#include <QtTest/QtTest>
#include "TagManager.h"

class TestTagManager : public QObject {
    Q_OBJECT
    
private slots:
    void testGetTagValue();
    void testSetTagValue();
};

void TestTagManager::testGetTagValue() {
    TagManager manager;
    manager.setTagValue("test_tag", 42);
    QCOMPARE(manager.getTagValue("test_tag").toInt(), 42);
}
```

### 集成测试
- UI交互测试
- 数据流测试
- 性能基准测试

## 调试技巧

### QML调试
```bash
# 启用QML调试
export QML_DEBUGGER_PORT=1234
./SCADADesigner -qmljsdebugger=port:1234

# 使用Qt Creator连接调试器
```

### 性能分析
```bash
# 启用性能日志
export QT_LOGGING_RULES="qt.quick.scenegraph.debug=true"
./SCADARuntime
```

## 发布流程

### 版本管理
遵循语义化版本控制 (SemVer):
- MAJOR: 不兼容的API变更
- MINOR: 向下兼容的功能新增
- PATCH: 向下兼容的问题修复

### 构建发布包
```bash
# 构建发布版本
./build.sh --release --all

# 创建安装包
cpack -G DEB  # Linux
cpack -G NSIS # Windows
```

## 贡献指南

### 提交规范
```
type(scope): subject

body

footer
```

类型包括:
- feat: 新功能
- fix: 修复bug
- docs: 文档更新
- style: 代码格式调整
- refactor: 代码重构
- test: 测试相关
- chore: 构建过程或辅助工具变动

### 代码审查要点
1. 功能实现是否正确
2. 代码风格是否一致
3. 是否有足够的测试覆盖
4. 文档是否同步更新
5. 性能影响是否可接受