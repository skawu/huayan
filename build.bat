@echo off
rem Qt6 Project Build Script for Huayan SCADA System
rem Automatically detects Qt6 environment and sets up build

echo Starting Qt6-based build for Huayan SCADA System

rem Detect platform (this script assumes Windows)
set PLATFORM=windows
echo Detected platform: %PLATFORM%

rem Find Qt6 installation
echo Searching for Qt6 installation...

set QT6_DIR=

rem Common Qt6 installation paths on Windows
for /F "tokens=*" %%i in ('dir "C:\Qt\6.*" /AD /B 2^>nul') do (
  for /F "tokens=*" %%j in ('dir "C:\Qt\%%i\*" /AD /B 2^>nul') do (
    if exist "C:\Qt\%%i\%%j\bin\qmake.exe" (
      set "QT6_DIR=C:\Qt\%%i\%%j"
      goto :found_qt
    )
  )
)

rem Check in user profile
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
  echo ERROR: Could not find Qt6 installation. Please install Qt 6.8 LTS or later.
  exit /b 1
)

echo Found Qt6 at: %QT6_DIR%

rem Set Qt6-related environment variables
set "PATH=%QT6_DIR%\bin;%PATH%"
set "PATH=%QT6_DIR%\lib;%PATH%"

rem Parse command line arguments
set BUILD_TYPE=Release
set BUILD_DIR=build
set CLEAN_BUILD=false
set INSTALL_AFTER_BUILD=false
set NUM_JOBS=4

:arg_loop
if "%~1"=="" goto :after_args
if "%~1"=="-d" set BUILD_TYPE=Debug
if "%~1"=="--debug" set BUILD_TYPE=Debug
if "%~1"=="-r" set BUILD_TYPE=Release
if "%~1"=="--release" set BUILD_TYPE=Release
if "%~1"=="-c" set CLEAN_BUILD=true
if "%~1"=="--clean" set CLEAN_BUILD=true
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
echo Usage: %0 [OPTIONS]
echo Options:
echo   -d, --debug       Build in Debug mode
echo   -r, --release     Build in Release mode (default)
echo   -c, --clean       Clean previous build before building
echo   -i, --install     Install the application after building
echo   -j, --jobs N      Number of parallel jobs (default: 4)
echo   -b, --build-dir   Build directory (default: build)
echo   -q, --qt-path     Qt6 installation path (default: auto-detected)
echo   -h, --help        Show this help message
exit /b 0

:after_args

echo Build configuration:
echo   Platform: %PLATFORM%
echo   Qt6 path: %QT6_DIR%
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

rem Configure the project
echo Configuring project with Qt6 from: %QT6_DIR%
cd "%BUILD_DIR%"

rem Determine CMake generator based on Qt installation
if exist "%QT6_DIR%\bin\cl.exe" (
  cmake .. -DCMAKE_PREFIX_PATH="%QT6_DIR%" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -G "Visual Studio 17 2022" -A x64
) else (
  cmake .. -DCMAKE_PREFIX_PATH="%QT6_DIR%" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -G "MinGW Makefiles"
)

if errorlevel 1 (
  echo CMake configuration failed
  cd ..
  exit /b 1
)

echo Project configured successfully

rem Build the project
echo Building project with %NUM_JOBS% parallel jobs...
if exist "ninja.exe" (
  ninja -j %NUM_JOBS%
) else (
  mingw32-make -j %NUM_JOBS%
)

if errorlevel 1 (
  echo Build failed
  cd ..
  exit /b 1
)

echo Project built successfully
cd ..

rem Install the project
if "%INSTALL_AFTER_BUILD%"=="true" (
  echo Installing project...
  cd "%BUILD_DIR%"
  
  if exist "ninja.exe" (
    ninja install
  ) else (
    mingw32-make install
  )
  
  if errorlevel 1 (
    echo Installation failed
    cd ..
    exit /b 1
  )
  
  echo Project installed successfully
  cd ..
)

echo Build completed successfully!
echo Built files are located in: %BUILD_DIR%/
echo To run the application, go to %BUILD_DIR%/ and execute the generated executable