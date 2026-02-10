@echo off

REM 钢铁厂监控平台一键运行脚本
REM 适配 Windows 系统

echo ========================================
echo 钢铁厂监控平台一键运行脚本
echo ========================================

REM 检查当前目录
if not exist "CMakeLists.txt" (
    echo 错误: 请在钢铁厂监控平台示例目录中运行此脚本
    pause
    exit /b 1
)

REM 创建构建目录
if not exist "build" (
    echo 创建构建目录...
    mkdir build
)

REM 进入构建目录
cd build

REM 配置 CMake
echo 配置 CMake...
cmake ..

REM 构建项目
echo 构建项目...
cmake --build . --config Release

REM 返回到示例目录
cd ..

REM 启动应用
echo 启动钢铁厂监控平台...
.uild\Release\steel_plant_monitoring.exe

REM 脚本结束
echo ========================================
echo 脚本执行完成
echo ========================================
pause
