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
