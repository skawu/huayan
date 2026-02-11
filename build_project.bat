@echo off
rem Cross-platform build script for Huayan SCADA System
rem Supports Windows platform using MSVC or MinGW

rem Colors are not supported in standard batch, so we'll use simple output

echo Starting cross-platform build for Huayan SCADA System

rem Detect platform (this script assumes Windows)
set PLATFORM=windows
echo Detected platform: %PLATFORM%

rem Check prerequisites
echo Checking prerequisites...

rem Check for CMake
cmake --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: CMake is not installed. Please install CMake 3.22 or higher.
    exit /b 1
)

rem Check CMake version (basic check)
for /f "tokens=3" %%i in ('cmake --version') do set CMAKE_VERSION=%%i
echo Found CMake version: %CMAKE_VERSION%

rem Check for compiler (MSVC or MinGW)
cl >nul 2>&1
if not errorlevel 1 (
    set COMPILER=MSVC
) else (
    g++ >nul 2>&1
    if not errorlevel 1 (
        set COMPILER=MinGW
    ) else (
        echo ERROR: No C++ compiler found. Please install Visual Studio or MinGW-w64.
        exit /b 1
    )
)
echo Found compiler: %COMPILER%

rem Check for Qt6
where qmake6 >nul 2>&1
if not errorlevel 1 (
    for /f "tokens=3" %%i in ('qmake6 -query QT_VERSION') do set QT_VERSION=%%i
    if "%QT_VERSION:~0,1%"=="6" (
        if "%QT_VERSION%" geq "6.8" (
            echo Found Qt6 version: %QT_VERSION%
        ) else (
            echo WARNING: Qt6 version is lower than 6.8: %QT_VERSION%
        )
    ) else (
        echo WARNING: Qt6 not found or version is lower than 6.0
    )
) else (
    echo WARNING: qmake6 not found. Attempting to locate Qt6 manually...
)

rem Try to find Qt6 using common paths
if "%QT6_DIR%"=="" (
    if exist "C:\Qt\6.8.*\mingw_*\bin\qmake.exe" (
        for /f "delims=" %%i in ('dir "C:\Qt\6.8.*\mingw_*\bin\qmake.exe" /b /s 2^>nul') do (
            set QT6_DIR=%%~dpi
            goto :qt_found
        )
    )
    if exist "C:\Qt\6.9.*\mingw_*\bin\qmake.exe" (
        for /f "delims=" %%i in ('dir "C:\Qt\6.9.*\mingw_*\bin\qmake.exe" /b /s 2^>nul') do (
            set QT6_DIR=%%~dpi
            goto :qt_found
        )
    )
)

:qt_found
if defined QT6_DIR (
    echo Found Qt6 at: %QT6_DIR%
    set "PATH=%QT6_DIR%bin;%PATH%"
) else (
    echo WARNING: Could not automatically locate Qt6. You may need to set QT6_DIR manually.
    echo Example: set QT6_DIR=C:\Qt\6.8.3\mingw_64\
)

echo Prerequisites check completed

rem Parse command line arguments
set BUILD_TYPE=Release
set BUILD_DIR=build
set CLEAN_BUILD=false
set INSTALL_AFTER_BUILD=false
set NUM_JOBS=4

:parse_args
if "%1"=="" goto args_parsed
if "%1"=="-d" set BUILD_TYPE=Debug& shift & goto parse_args
if "%1"=="--debug" set BUILD_TYPE=Debug& shift & goto parse_args
if "%1"=="-r" set BUILD_TYPE=Release& shift & goto parse_args
if "%1"=="--release" set BUILD_TYPE=Release& shift & goto parse_args
if "%1"=="-c" set CLEAN_BUILD=true& shift & goto parse_args
if "%1"=="--clean" set CLEAN_BUILD=true& shift & goto parse_args
if "%1"=="-i" set INSTALL_AFTER_BUILD=true& shift & goto parse_args
if "%1"=="--install" set INSTALL_AFTER_BUILD=true& shift & goto parse_args
if "%1"=="-j" set NUM_JOBS=%2& shift & shift & goto parse_args
if "%1"=="--jobs" set NUM_JOBS=%2& shift & shift & goto parse_args
if "%1"=="-b" set BUILD_DIR=%2& shift & shift & goto parse_args
if "%1"=="--build-dir" set BUILD_DIR=%2& shift & shift & goto parse_args
if "%1"=="-h" goto show_help
if "%1"=="--help" goto show_help

echo Build configuration:
echo   Platform: %PLATFORM%
echo   Build type: %BUILD_TYPE%
echo   Build directory: %BUILD_DIR%
echo   Clean build: %CLEAN_BUILD%
echo   Install after build: %INSTALL_AFTER_BUILD%
echo   Parallel jobs: %NUM_JOBS%

rem Prepare build directory
if "%CLEAN_BUILD%"=="true" (
    if exist "%BUILD_DIR%" (
        echo Cleaning build directory: %BUILD_DIR%
        rmdir /s /q "%BUILD_DIR%"
    )
)
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

echo Build directory prepared: %BUILD_DIR%

rem Configure the project
echo Configuring project...
cd "%BUILD_DIR%"

rem Determine Qt path for CMake
set QT_CMAKE_PATH=
if defined QT6_DIR (
    if exist "%QT6_DIR%\lib\cmake\Qt6\Qt6Config.cmake" (
        set QT_CMAKE_PATH=-DCMAKE_PREFIX_PATH=%QT6_DIR%
    )
)

rem Windows-specific configuration
if "%COMPILER%"=="MSVC" (
    cmake .. %QT_CMAKE_PATH% -DCMAKE_BUILD_TYPE=%BUILD_TYPE% -G "Visual Studio 17 2022" -A x64
) else (
    cmake .. %QT_CMAKE_PATH% -DCMAKE_BUILD_TYPE=%BUILD_TYPE% -G "MinGW Makefiles"
)

if errorlevel 1 (
    echo ERROR: CMake configuration failed
    exit /b 1
)

echo Project configured successfully
cd ..

rem Build the project
echo Building project with %NUM_JOBS% parallel jobs...
cd "%BUILD_DIR%"

if "%COMPILER%"=="MSVC" (
    msbuild SCADASystem.sln /p:Configuration=%BUILD_TYPE% /m:%NUM_JOBS%
) else (
    mingw32-make -j%NUM_JOBS%
)

if errorlevel 1 (
    echo ERROR: Build failed
    exit /b 1
)

echo Project built successfully
cd ..

rem Install the project
if "%INSTALL_AFTER_BUILD%"=="true" (
    echo Installing project...
    cd "%BUILD_DIR%"
    
    if "%COMPILER%"=="MSVC" (
        msbuild INSTALL.vcxproj /p:Configuration=%BUILD_TYPE%
    ) else (
        mingw32-make install
    )
    
    if errorlevel 1 (
        echo ERROR: Installation failed
        exit /b 1
    )
    
    echo Project installed successfully
    cd ..
)

rem Create run script
echo Creating run script...
(
echo @echo off
echo rem Auto-generated run script for Huayan SCADA System
echo rem Generated on %date%
echo.
echo rem Get the directory where the script is located
echo set SCRIPT_DIR=%%~dp0
echo.
echo rem Set environment variables for Qt libraries
echo set PATH=%%SCRIPT_DIR%%lib;%%PATH%%
echo set QT_PLUGIN_PATH=%%SCRIPT_DIR%%plugins;%%QT_PLUGIN_PATH%%
echo set QML2_IMPORT_PATH=%%SCRIPT_DIR%%qml;%%QML2_IMPORT_PATH%%
echo.
echo rem Run the application
echo "%%SCRIPT_DIR%%SCADASystem.exe" %%*
) > "%BUILD_DIR%\run_huayan.bat"

echo Run script created

echo Build completed successfully!
echo Built files are located in: %BUILD_DIR%

goto :eof

:show_help
echo Usage: %0 [OPTIONS]
echo Options:
echo   -d, --debug       Build in Debug mode
echo   -r, --release     Build in Release mode (default)
echo   -c, --clean       Clean previous build before building
echo   -i, --install     Install the application after building
echo   -j, --jobs N      Number of parallel jobs (default: 4)
echo   -b, --build-dir   Build directory (default: build)
echo   -h, --help        Show this help message