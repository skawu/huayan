# 华颜工业SCADA系统 API参考文档

## 1. 核心类API

### 1.1 HYTag 类

#### 描述
表示一个工业数据标签，包含名称、组、值和描述等属性。

#### 构造函数
```cpp
HYTag(QObject *parent = nullptr);
HYTag(const QString &name, const QString &group, const QVariant &value, const QString &description = "", QObject *parent = nullptr);
```

#### 属性
| 属性名 | 类型 | 说明 | 可写 |
|-------|------|------|------|
| name | QString | 标签名称 | 否 |
| group | QString | 标签组 | 否 |
| value | QVariant | 标签值 | 是 |
| description | QString | 标签描述 | 是 |

#### 方法
```cpp
QString name() const;
QString group() const;
QVariant value() const;
QString description() const;
void setValue(const QVariant &value);
void setDescription(const QString &description);
```

#### 信号
```cpp
void valueChanged(const QVariant &newValue);
```

### 1.2 HYTagManager 类

#### 描述
负责管理所有标签，包括标签的添加、删除、查询和值的更新等功能。

#### 构造函数
```cpp
HYTagManager(QObject *parent = nullptr);
```

#### 方法
```cpp
bool addTag(const QString &name, const QString &group, const QVariant &value, const QString &description = "");
bool removeTag(const QString &name);
HYTag *getTag(const QString &name) const;
QVector<HYTag *> getTagsByGroup(const QString &group) const;
QVector<HYTag *> getAllTags() const;
QVector<QString> getGroups() const;
bool setTagValue(const QString &name, const QVariant &value);
QVariant getTagValue(const QString &name) const;
void bindTagToProperty(const QString &tagName, QObject *object, const char *propertyName);
void unbindTagFromProperty(const QString &tagName, QObject *object, const char *propertyName);
```

#### 信号
```cpp
void tagAdded(const QString &name);
void tagRemoved(const QString &name);
void tagValueChanged(const QString &name, const QVariant &newValue);
```

### 1.3 HYDataProcessor 类

#### 描述
负责数据的采集、处理和发送，是系统的核心组件之一。

#### 构造函数
```cpp
HYDataProcessor(QObject *parent = nullptr);
```

#### 方法
```cpp
void initialize(HYModbusTcpDriver *driver, HYTagManager *tagManager);
void startDataCollection(int interval = 1000);
void stopDataCollection();
void setCollectionInterval(int interval);
bool sendCommand(const QString &tagName, const QVariant &value);
bool mapTagToDeviceRegister(const QString &tagName, int registerAddress, bool isHoldingRegister = true);
bool unmapTagFromDeviceRegister(const QString &tagName);
```

#### 信号
```cpp
void dataCollectionStarted();
void dataCollectionStopped();
void commandSent(const QString &tagName, const QVariant &value, bool success);
```

### 1.4 HYModbusTcpDriver 类

#### 描述
负责与Modbus TCP设备的通信，包括连接管理、数据读写、错误处理等功能。

#### 构造函数
```cpp
HYModbusTcpDriver(QObject *parent = nullptr);
```

#### 方法
```cpp
bool connectToDevice(const QString &ipAddress, int port, int slaveId);
void disconnectFromDevice();
bool isConnected() const;
bool readCoil(int address, bool &value);
bool readDiscreteInput(int address, bool &value);
bool readHoldingRegister(int address, quint16 &value);
bool readInputRegister(int address, quint16 &value);
bool writeCoil(int address, bool value);
bool writeHoldingRegister(int address, quint16 value);
bool readCoils(int startAddress, int count, QVector<bool> &values);
bool readMultipleCoils(int startAddress, int count, QVector<bool> &values);
bool readMultipleHoldingRegisters(int startAddress, int count, QVector<quint16> &values);
bool writeMultipleCoils(int startAddress, const QVector<bool> &values);
bool writeMultipleHoldingRegisters(int startAddress, const QVector<quint16> &values);
void setReconnectInterval(int interval);
void setResponseTimeout(int timeout);
```

#### 信号
```cpp
void connected();
void disconnected();
void connectionError(const QString &error);
void dataReadError(const QString &error);
void dataWriteError(const QString &error);
```

### 1.5 HYTimeSeriesDatabase 类

#### 描述
负责与时间序列数据库的交互，支持InfluxDB、TimescaleDB和SQLite等数据库。

#### 构造函数
```cpp
HYTimeSeriesDatabase(QObject *parent = nullptr);
```

#### 枚举
```cpp
enum DatabaseType {
    INFLUXDB,   // InfluxDB数据库
    TIMESCALEDB, // TimescaleDB数据库
    SQLITE      // SQLite数据库
};
```

#### 结构体
```cpp
struct DatabaseConfig {
    DatabaseType type; // 数据库类型
    QString host; // 数据库主机
    int port; // 数据库端口
    QString database; // 数据库名称
    QString username; // 用户名
    QString password; // 密码
    QString tableName; // 表名
};
```

#### 方法
```cpp
bool initialize(const DatabaseConfig &config);
void shutdown();
bool isConnected() const;
QString connectionStatus() const;
bool storeTagValue(const QString &tagName, const QVariant &value, const QDateTime &timestamp = QDateTime::currentDateTime());
bool storeTagValues(const QMap<QString, QVariant> &tagValues, const QDateTime &timestamp = QDateTime::currentDateTime());
QMap<QDateTime, QVariant> queryTagHistory(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime, int limit = 1000);
QMap<QString, QMap<QDateTime, QVariant>> queryMultipleTagsHistory(const QStringList &tagNames, const QDateTime &startTime, const QDateTime &endTime, int limit = 1000);
bool createDatabase();
bool createTable();
bool clearData(const QString &tagName = QString());
```

#### 信号
```cpp
void connected();
void disconnected();
void dataStored(const QString &tagName, const QVariant &value);
void dataRetrieved(const QString &tagName, int count);
```

## 2. QML组件API

### 2.1 基础组件

#### 2.1.1 Indicator 组件

##### 描述
显示状态指示灯，可用于显示设备的运行状态。

##### 属性
| 属性名 | 类型 | 默认值 | 说明 |
|-------|------|-------|------|
| state | string | "normal" | 指示灯状态：normal, warning, error |
| size | int | 30 | 指示灯大小 |
| label | string | "" | 指示灯标签 |
| showLabel | bool | false | 是否显示标签 |
| tagName | string | "" | 关联的标签名称 |
| tagValue | variant | null | 关联的标签值 |

##### 使用示例
```qml
Indicator {
    state: "normal"
    size: 40
    label: "运行状态"
    showLabel: true
    tagName: "Motor_Running"
}
```

#### 2.1.2 PushButton 组件

##### 描述
可点击的按钮组件，支持普通模式和切换模式。

##### 属性
| 属性名 | 类型 | 默认值 | 说明 |
|-------|------|-------|------|
| text | string | "Button" | 按钮文本 |
| width | int | 100 | 按钮宽度 |
| height | int | 40 | 按钮高度 |
| toggleMode | bool | false | 是否为切换模式 |
| checked | bool | false | 切换模式下的状态 |
| tagName | string | "" | 关联的标签名称 |
| tagValue | variant | null | 关联的标签值 |

##### 信号
```qml
signal buttonClicked()
```

##### 使用示例
```qml
PushButton {
    text: "启动"
    width: 120
    height: 50
    toggleMode: false
    onClicked: {
        console.log("按钮被点击");
    }
}
```

#### 2.1.3 TextLabel 组件

##### 描述
显示标签文本和对应的值，支持与数据标签关联。

##### 属性
| 属性名 | 类型 | 默认值 | 说明 |
|-------|------|-------|------|
| labelText | string | "Label" | 标签文本 |
| valueText | string | "" | 显示的值文本 |
| tagName | string | "" | 关联的数据标签名称 |
| tagValue | variant | null | 关联的数据标签值 |
| showValue | bool | true | 是否显示值文本 |
| fontSize | int | 14 | 字体大小 |
| showBackground | bool | false | 是否显示背景 |

##### 使用示例
```qml
TextLabel {
    labelText: "温度"
    valueText: "25.5°C"
    width: 150
    height: 30
}
```

### 2.2 工业组件

#### 2.2.1 Valve 组件

##### 描述
用于模拟和显示阀门开关状态的工业组件。

##### 属性
| 属性名 | 类型 | 默认值 | 说明 |
|-------|------|-------|------|
| open | bool | false | 是否打开 |
| tagName | string | "" | 数据标签名称 |
| tagValue | variant | null | 数据标签值 |
| openColor | color | "#4CAF50" | 打开状态颜色 |
| closedColor | color | "#F44336" | 关闭状态颜色 |

##### 信号
```qml
signal valveClicked(var value)
```

##### 使用示例
```qml
Valve {
    width: 100
    height: 100
    open: true
    tagName: "Main_Valve"
}
```

#### 2.2.2 Tank 组件

##### 描述
用于显示储罐液位高度的工业组件。

##### 属性
| 属性名 | 类型 | 默认值 | 说明 |
|-------|------|-------|------|
| level | real | 0.5 | 液位高度（0.0-1.0） |
| tagName | string | "" | 数据标签名称 |
| tagValue | variant | null | 数据标签值 |
| fillColor | color | "#2196F3" | 填充颜色 |
| emptyColor | color | "#E0E0E0" | 空罐颜色 |
| showLevelText | bool | true | 是否显示液位文本 |
| unit | string | "%" | 液位单位 |

##### 使用示例
```qml
Tank {
    width: 120
    height: 180
    level: 0.75
    fillColor: "#2196F3"
    showLevelText: true
}
```

#### 2.2.3 Motor 组件

##### 描述
用于模拟和显示电机运行状态的工业组件。

##### 属性
| 属性名 | 类型 | 默认值 | 说明 |
|-------|------|-------|------|
| running | bool | false | 是否运行 |
| tagName | string | "" | 数据标签名称 |
| tagValue | variant | null | 数据标签值 |
| runningColor | color | "#4CAF50" | 运行状态颜色 |
| stoppedColor | color | "#F44336" | 停止状态颜色 |
| showStatusText | bool | true | 是否显示状态文本 |

##### 信号
```qml
signal motorClicked(var value)
```

##### 使用示例
```qml
Motor {
    width: 120
    height: 120
    running: true
    showStatusText: true
}
```

#### 2.2.4 Pump 组件

##### 描述
用于模拟和显示水泵运行状态的工业组件。

##### 属性
| 属性名 | 类型 | 默认值 | 说明 |
|-------|------|-------|------|
| running | bool | false | 是否运行 |
| tagName | string | "" | 数据标签名称 |
| tagValue | variant | null | 数据标签值 |
| runningColor | color | "#4CAF50" | 运行状态颜色 |
| stoppedColor | color | "#F44336" | 停止状态颜色 |
| showStatusText | bool | true | 是否显示状态文本 |

##### 信号
```qml
signal pumpClicked(var value)
```

##### 使用示例
```qml
Pump {
    width: 120
    height: 120
    running: true
    showStatusText: true
}
```

### 2.3 图表组件

#### 2.3.1 TrendChart 组件

##### 描述
显示数据趋势的图表组件。

##### 属性
| 属性名 | 类型 | 默认值 | 说明 |
|-------|------|-------|------|
| title | string | "Trend" | 图表标题 |
| color | color | "#2196F3" | 图表颜色 |
| width | int | 200 | 图表宽度 |
| height | int | 150 | 图表高度 |

##### 使用示例
```qml
TrendChart {
    width: 250
    height: 200
    title: "温度趋势"
    color: "#4CAF50"
}
```

#### 2.3.2 BarChart 组件

##### 描述
显示柱状图的图表组件。

##### 属性
| 属性名 | 类型 | 默认值 | 说明 |
|-------|------|-------|------|
| title | string | "Bar Chart" | 图表标题 |
| color | color | "#2196F3" | 图表颜色 |
| width | int | 200 | 图表宽度 |
| height | int | 150 | 图表高度 |

##### 使用示例
```qml
BarChart {
    width: 250
    height: 200
    title: "产量统计"
    color: "#FF9800"
}
```

### 2.4 3D组件

#### 2.4.1 ThreeDScene 组件

##### 描述
创建3D场景的组件。

##### 属性
| 属性名 | 类型 | 默认值 | 说明 |
|-------|------|-------|------|
| width | int | 400 | 场景宽度 |
| height | int | 300 | 场景高度 |
| backgroundColor | color | "#1E1E1E" | 背景颜色 |

##### 使用示例
```qml
ThreeDScene {
    width: 500
    height: 400
    backgroundColor: "#2C3E50"
}
```

#### 2.4.2 ModelLoader 组件

##### 描述
加载3D模型的组件。

##### 属性
| 属性名 | 类型 | 默认值 | 说明 |
|-------|------|-------|------|
| modelPath | string | "" | 模型文件路径 |
| scale | real | 1.0 | 模型缩放比例 |
| rotation | vector3d | Qt.vector3d(0, 0, 0) | 模型旋转角度 |
| position | vector3d | Qt.vector3d(0, 0, 0) | 模型位置 |

##### 使用示例
```qml
ModelLoader {
    modelPath: "models/pump.glb"
    scale: 0.5
    rotation: Qt.vector3d(0, 45, 0)
}
```

## 3. 二次开发API

### 3.1 插件系统

#### 3.1.1 创建自定义QML组件

1. **创建QML文件**：在`qml/plugins`目录下创建新的QML文件
2. **实现组件逻辑**：编写组件的属性、信号和行为
3. **更新qmldir文件**：在对应目录的qmldir文件中添加组件声明
4. **重新构建项目**：运行CMake构建命令

#### 示例：创建自定义仪表组件

```qml
// CustomGauge.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: customGauge
    width: 200
    height: 200
    
    property real value: 50
    property real minValue: 0
    property real maxValue: 100
    property string unit: "%"
    property color fillColor: "#4CAF50"
    
    // 实现仪表逻辑...
}
```

在qmldir文件中添加：
```
CustomGauge 1.0 CustomGauge.qml
```

### 3.2 自定义驱动开发

#### 3.2.1 继承基础驱动类

创建自定义驱动类，继承自基础驱动接口，实现通信逻辑。

#### 示例：创建自定义驱动

```cpp
class CustomDriver : public QObject {
    Q_OBJECT

public:
    CustomDriver(QObject *parent = nullptr);
    
    bool connectToDevice(const QString &ipAddress, int port);
    void disconnectFromDevice();
    bool isConnected() const;
    bool readRegister(int address, QVariant &value);
    bool writeRegister(int address, const QVariant &value);
    
private:
    // 实现细节...
};
```

### 3.3 数据处理扩展

#### 3.3.1 扩展数据处理器

通过继承或组合的方式扩展数据处理器功能。

#### 示例：添加数据转换功能

```cpp
class EnhancedDataProcessor : public HYDataProcessor {
    Q_OBJECT

public:
    EnhancedDataProcessor(QObject *parent = nullptr);
    
    // 添加数据转换方法
    QVariant convertValue(const QVariant &value, const QString &fromUnit, const QString &toUnit);
    
    // 重写数据处理方法
    void processData(const QMap<QString, QVariant> &rawData) override;
    
private:
    // 实现细节...
};
```

## 4. 系统配置API

### 4.1 配置文件结构

系统使用JSON格式的配置文件，主要配置项包括：

- **通信配置**：设备连接参数
- **数据采集配置**：采集频率、超时设置等
- **数据库配置**：时序数据库连接参数
- **UI配置**：界面布局、主题设置等

### 4.2 配置加载与保存

```cpp
// 加载配置
QJsonObject loadConfig(const QString &configFile);

// 保存配置
bool saveConfig(const QString &configFile, const QJsonObject &config);

// 应用配置
void applyConfig(const QJsonObject &config);
```

### 4.3 运行时配置修改

系统支持运行时修改配置，修改后会自动应用到系统中：

```cpp
// 修改通信配置
void updateCommunicationConfig(const QString &ipAddress, int port, int slaveId);

// 修改数据采集配置
void updateCollectionConfig(int interval, int timeout);

// 修改数据库配置
void updateDatabaseConfig(const HYTimeSeriesDatabase::DatabaseConfig &config);
```

## 5. 错误处理API

### 5.1 错误类型

| 错误类型 | 描述 | 错误码 |
|---------|------|--------|
| NoError | 无错误 | 0 |
| ConnectionError | 连接错误 | 1 |
| ReadError | 读取错误 | 2 |
| WriteError | 写入错误 | 3 |
| ConfigurationError | 配置错误 | 4 |
| DatabaseError | 数据库错误 | 5 |
| TimeoutError | 超时错误 | 6 |

### 5.2 错误处理方法

```cpp
// 错误处理回调
typedef std::function<void(int errorCode, const QString &errorMessage)> ErrorHandler;

// 设置错误处理
void setErrorHandler(ErrorHandler handler);

// 错误日志记录
void logError(int errorCode, const QString &errorMessage, const QString &source);

// 错误恢复
bool recoverFromError(int errorCode);
```

## 6. 性能监控API

### 6.1 系统性能指标

| 指标 | 描述 | 单位 |
|------|------|------|
| CpuUsage | CPU使用率 | % |
| MemoryUsage | 内存使用率 | % |
| NetworkLatency | 网络延迟 | ms |
| DataProcessingTime | 数据处理时间 | ms |
| UiRefreshRate | UI刷新频率 | Hz |

### 6.2 性能监控方法

```cpp
// 获取系统性能指标
QMap<QString, QVariant> getSystemMetrics();

// 监控特定操作的执行时间
qint64 measureExecutionTime(std::function<void()> operation);

// 性能警告回调
typedef std::function<void(const QString &metric, double value, double threshold)> PerformanceWarningHandler;

// 设置性能警告处理
void setPerformanceWarningHandler(PerformanceWarningHandler handler);

// 设置性能阈值
void setPerformanceThreshold(const QString &metric, double threshold);
```

## 7. 安全API

### 7.1 用户认证

```cpp
// 用户认证
bool authenticateUser(const QString &username, const QString &password);

// 生成加密密码
QString generatePasswordHash(const QString &password);

// 验证密码
bool verifyPassword(const QString &password, const QString &hash);
```

### 7.2 权限管理

| 权限级别 | 描述 | 权限码 |
|---------|------|--------|
| ViewOnly | 仅查看 | 0 |
| Operator | 操作员 | 1 |
| Engineer | 工程师 | 2 |
| Administrator | 管理员 | 3 |

```cpp
// 检查权限
bool checkPermission(int requiredLevel, const QString &username);

// 设置用户权限
void setUserPermission(const QString &username, int permissionLevel);

// 获取用户权限
int getUserPermission(const QString &username);
```

### 7.3 操作审计

```cpp
// 记录操作
void logOperation(const QString &username, const QString &operation, const QString &details);

// 查询操作日志
QVector<QMap<QString, QVariant>> queryOperationLogs(const QDateTime &startTime, const QDateTime &endTime, const QString &username = "");

// 导出操作日志
bool exportOperationLogs(const QString &filePath, const QDateTime &startTime, const QDateTime &endTime);
```

## 8. 部署与维护API

### 8.1 系统部署

```cpp
// 打包工程
bool packageProject(const QString &projectPath, const QString &outputPath);

// 导出工程配置
bool exportProjectConfig(const QString &projectPath, const QString &configFile);

// 导入工程配置
bool importProjectConfig(const QString &configFile, const QString &projectPath);

// 验证部署环境
bool validateDeploymentEnvironment();
```

### 8.2 系统维护

```cpp
// 备份系统配置
bool backupSystemConfig(const QString &backupPath);

// 恢复系统配置
bool restoreSystemConfig(const QString &backupPath);

// 清理系统日志
bool cleanupSystemLogs(int daysToKeep = 30);

// 检查系统更新
bool checkForUpdates(QString &versionInfo);

// 应用系统更新
bool applyUpdate(const QString &updatePackage);
```

### 8.3 诊断工具

```cpp
// 运行系统诊断
QMap<QString, QVariant> runSystemDiagnostic();

// 测试通信连接
bool testCommunication(const QString &ipAddress, int port);

// 测试数据库连接
bool testDatabaseConnection(const HYTimeSeriesDatabase::DatabaseConfig &config);

// 生成诊断报告
bool generateDiagnosticReport(const QString &reportPath);
```

## 9. 总结

本API参考文档提供了华颜工业SCADA系统的核心API接口说明，涵盖了：

1. **核心类API**：标签管理、数据处理、通信驱动等核心功能
2. **QML组件API**：基础组件、工业组件、图表组件和3D组件
3. **二次开发API**：插件系统、自定义驱动、数据处理扩展
4. **系统配置API**：配置文件管理、运行时配置修改
5. **错误处理API**：错误类型、错误处理方法
6. **性能监控API**：系统性能指标、性能监控方法
7. **安全API**：用户认证、权限管理、操作审计
8. **部署与维护API**：系统部署、系统维护、诊断工具

这些API为开发者提供了完整的系统接入和扩展能力，支持用户根据具体需求进行二次开发和定制化。

## 10. 版本历史

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| 1.0.0 | 2026-02-07 | 初始版本 |
| 1.1.0 | 2026-03-15 | 增加3D组件API |
| 1.2.0 | 2026-04-20 | 增加性能监控API |
| 1.3.0 | 2026-05-25 | 增加安全API |

---

本API文档由华颜软件技术团队编制，如有任何疑问或建议，请联系技术支持：support@huayan-scada.com
