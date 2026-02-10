#!/bin/bash

# 钢铁厂监控平台一键运行脚本
# 适配 Linux 系统

set -e

echo "========================================"
echo "钢铁厂监控平台一键运行脚本"
echo "========================================"

# 检查当前目录
if [ ! -f "CMakeLists.txt" ]; then
    echo "错误: 请在钢铁厂监控平台示例目录中运行此脚本"
    exit 1
fi

# 创建构建目录
if [ ! -d "build" ]; then
    echo "创建构建目录..."
    mkdir -p build
fi

# 进入构建目录
cd build

# 配置 CMake
echo "配置 CMake..."
cmake ..

# 构建项目
echo "构建项目..."
make -j4

# 返回到示例目录
cd ..

# 启动应用
echo "启动钢铁厂监控平台..."
./build/steel_plant_monitoring

# 脚本结束
echo "========================================"
echo "脚本执行完成"
echo "========================================"
