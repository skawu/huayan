@echo off
rem Qt6 项目构建脚本 for Huayan SCADA System
rem 自动检测 Qt6 环境并设置构建

echo 开始基于 Qt6 的 Huayan SCADA System 构建

rem 检测平台（此脚本假设为 Windows）
set PLATFORM=windows
echo 检测到平台: %PLATFORM%

rem 查找 Qt6 安装
echo 正在搜索 Qt6 安装...

set QT6_DIR=

rem Windows 上常见的 Qt6 安装路径
for /F "tokens=*" %%i in ('dir "C:\Qt\6.*" /AD /B 2^>nul') do (
  for /F "tokens=*" %%j in ('dir "C:\Qt\%%i\*" /AD /B 2^>nul') do (
    if exist "C:\Qt\%%i\%%j\bin\qmake.exe" (
      set "QT6_DIR=C:\Qt\%%i\%%j"
      goto :found_qt
    )
  )
)

rem 检查用户配置文件
for /F "tokens=*" %%i in ('dir "%USERPROFILE%\Qt\6.*" /AD /B 2^>nul') do (
  for /F "tokens=*" %%j in ('dir "%USERPROFILE%\Qt\%%i\*" /AD /B 2^>nul') do (
    if exist "%USERPROFILE%\Qt\%%i\%%j\bin\qmake.exe" (
      set "QT6_DIR=%USERPROFILE%\Qt\%%i\%%j"
      goto :found_qt
    )
  )
)

:found_qt
if "%QT6_DIR%"=="" (
  echo 错误: 无法找到 Qt6 安装。请安装 Qt 6.8 LTS 或更高版本。
  exit /b 1
)

echo 找到 Qt6 位置: %QT6_DIR%

rem 设置 Qt6 相关环境变量
set "PATH=%QT6_DIR%\bin;%PATH%"
set "PATH=%QT6_DIR%\lib;%PATH%"

rem 解析命令行参数
set BUILD_TYPE=Release
set BUILD_DIR=build
set CLEAN_ONLY=false
set REBUILD=false
set INSTALL_AFTER_BUILD=false
set NUM_JOBS=4

:arg_loop
if "%~1"=="" goto :after_args
if "%~1"=="-d" set BUILD_TYPE=Debug
if "%~1"=="--debug" set BUILD_TYPE=Debug
if "%~1"=="-r" set BUILD_TYPE=Release
if "%~1"=="--release" set BUILD_TYPE=Release
if "%~1"=="-c" set CLEAN_ONLY=true
if "%~1"=="--clean" set CLEAN_ONLY=true
if "%~1"=="--rebuild" set REBUILD=true
if "%~1"=="-i" set INSTALL_AFTER_BUILD=true
if "%~1"=="--install" set INSTALL_AFTER_BUILD=true
if "%~1"=="-j" set NUM_JOBS=%2& shift
if "%~1"=="--jobs" set NUM_JOBS=%2& shift
if "%~1"=="-b" set BUILD_DIR=%2& shift
if "%~1"=="--build-dir" set BUILD_DIR=%2& shift
if "%~1"=="-q" set QT6_DIR=%2& shift
if "%~1"=="--qt-path" set QT6_DIR=%2& shift
if "%~1"=="-h" goto :show_help
if "%~1"=="--help" goto :show_help
shift
goto :arg_loop

:show_help
echo 用法: %0 [选项]
echo 选项:
echo   -d, --debug       Debug 模式构建
echo   -r, --release     Release 模式构建（默认）
echo   -c, --clean       清理构建目录
echo   --rebuild         清理后重新构建
echo   -i, --install     构建后安装应用程序
echo   -j, --jobs N      并行作业数（默认：4）
echo   -b, --build-dir   构建目录（默认：build）
echo   -q, --qt-path     Qt6 安装路径（默认：自动检测）
echo   -h, --help        显示此帮助信息
exit /b 0

:after_args

echo 构建配置:
echo   平台: %PLATFORM%
echo   Qt6 路径: %QT6_DIR%
echo   构建类型: %BUILD_TYPE%
echo   构建目录: %BUILD_DIR%
echo   清理构建: %CLEAN_BUILD%
echo   构建后安装: %INSTALL_AFTER_BUILD%
echo   并行作业数: %NUM_JOBS%

rem 检查是否仅执行清理操作
if "%CLEAN_ONLY%"=="true" (
  if exist "%BUILD_DIR%" (
    echo 清理构建目录: %BUILD_DIR%
    rmdir /s /q "%BUILD_DIR%"
    echo 目录 %BUILD_DIR% 已清理
  ) else (
    echo 构建目录 %BUILD_DIR% 不存在
  )
  echo 清理完成!
  exit /b 0
)

rem 检查是否重建，先清理再构建
if "%REBUILD%"=="true" (
  if exist "%BUILD_DIR%" (
    echo 清理构建目录: %BUILD_DIR%
    rmdir /s /q "%BUILD_DIR%"
  )
)

rem 准备构建目录
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

rem 配置项目
echo 使用 Qt6 配置项目: %QT6_DIR%
cd "%BUILD_DIR%"

rem 根据安装的 Qt 确定 CMake 生成器
if exist "%QT6_DIR%\bin\cl.exe" (
  cmake .. -DCMAKE_PREFIX_PATH="%QT6_DIR%" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -G "Visual Studio 17 2022" -A x64
) else (
  cmake .. -DCMAKE_PREFIX_PATH="%QT6_DIR%" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -G "MinGW Makefiles"
)

if errorlevel 1 (
  echo CMake 配置失败
  cd ..
  exit /b 1
)

echo 项目配置成功

rem 构建项目
echo 使用 %NUM_JOBS% 个并行作业构建项目...
if exist "ninja.exe" (
  ninja -j %NUM_JOBS%
) else (
  mingw32-make -j %NUM_JOBS%
)

if errorlevel 1 (
  echo 构建失败
  cd ..
  exit /b 1
)

echo 项目构建成功
cd ..

rem 安装项目
if "%INSTALL_AFTER_BUILD%"=="true" (
  echo 安装项目...
  cd "%BUILD_DIR%"
  
  if exist "ninja.exe" (
    ninja install
  ) else (
    mingw32-make install
  )
  
  if errorlevel 1 (
    echo 安装失败
    cd ..
    exit /b 1
  )
  
  echo 项目安装成功
  cd ..
)

echo 构建成功完成!
echo 构建文件位于: %BUILD_DIR%/

if "%INSTALL_AFTER_BUILD%"=="true" (
  echo 可执行文件已安装到: %%HOMEDRIVE%%%%HOMEPATH%%\huayan\bin\
  echo 要运行已安装的应用程序，请进入 %%HOMEDRIVE%%%%HOMEPATH%%\huayan\bin\ 并执行生成的可执行文件
  echo 或者执行 %%HOMEDRIVE%%%%HOMEPATH%%\huayan\bin\run.bat 脚本来启动应用程序
) else (
  echo 可执行文件位于: %BUILD_DIR%\bin\
  echo 要运行应用程序，请进入 %BUILD_DIR%\bin\ 并执行生成的可执行文件
  echo 或者在 %BUILD_DIR%\ 目录下执行 run.bat 脚本来启动应用程序
)