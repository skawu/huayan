#!/bin/bash

# Cross-platform build script for Huayan SCADA System
# Supports both Linux and Windows (via MinGW/MSYS2) platforms

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect platform
detect_platform() {
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        PLATFORM="windows"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        PLATFORM="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="macos"
    else
        PLATFORM="unknown"
    fi
    
    print_info "Detected platform: $PLATFORM"
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check for CMake
    if ! command -v cmake &> /dev/null; then
        print_error "CMake is not installed. Please install CMake 3.22 or higher."
        exit 1
    fi
    
    # Check CMake version
    CMAKE_VERSION=$(cmake --version | head -n1 | cut -d' ' -f3)
    CMAKE_MAJOR=$(echo $CMAKE_VERSION | cut -d'.' -f1)
    CMAKE_MINOR=$(echo $CMAKE_VERSION | cut -d'.' -f2)
    
    if [ $CMAKE_MAJOR -lt 3 ] || ([ $CMAKE_MAJOR -eq 3 ] && [ $CMAKE_MINOR -lt 22 ]); then
        print_error "CMake version must be 3.22 or higher. Found: $CMAKE_VERSION"
        exit 1
    fi
    
    # Check for compiler
    if [[ "$PLATFORM" == "windows" ]]; then
        if ! command -v g++ &> /dev/null && ! command -v clang++ &> /dev/null; then
            print_error "No C++ compiler found. Please install MinGW-w64 or MSYS2."
            exit 1
        fi
    else
        if ! command -v g++ &> /dev/null && ! command -v clang++ &> /dev/null; then
            print_error "No C++ compiler found. Please install g++ or clang++."
            exit 1
        fi
    fi
    
    # Check for Qt6
    if command -v qmake6 &> /dev/null; then
        QT_VERSION=$(qmake6 -query QT_VERSION 2>/dev/null || echo "unknown")
        if [[ "$QT_VERSION" != "6."* ]] || [[ "$QT_VERSION" < "6.8" ]]; then
            print_warning "Qt6 not found or version is lower than 6.8. Attempting to locate Qt6..."
        fi
    else
        print_warning "qmake6 not found. Attempting to locate Qt6 manually..."
    fi
    
    # Try to find Qt6 using common paths
    if [[ -z "$QT6_DIR" ]]; then
        for qt_path in /opt/Qt/6.8* /opt/Qt/6.9* /usr/local/Qt/6.8* /usr/local/Qt/6.9* "$HOME/Qt/6.8*" "$HOME/Qt/6.9*"; do
            if [[ -d "$qt_path" && -f "$qt_path/bin/qmake" ]]; then
                export QT6_DIR="$qt_path"
                break
            fi
        done
    fi
    
    if [[ -z "$QT6_DIR" ]]; then
        print_warning "Could not automatically locate Qt6. You may need to set QT6_DIR manually."
        print_info "Example: export QT6_DIR=/opt/Qt/6.8.3/gcc_64"
    else
        print_info "Found Qt6 at: $QT6_DIR"
        export PATH="$QT6_DIR/bin:$PATH"
        if [[ "$PLATFORM" == "linux" ]]; then
            export LD_LIBRARY_PATH="$QT6_DIR/lib:$LD_LIBRARY_PATH"
        fi
    fi
    
    print_success "Prerequisites check completed"
}

# Parse command line arguments
parse_arguments() {
    BUILD_TYPE="Release"
    BUILD_DIR="build"
    CLEAN_BUILD=false
    INSTALL_AFTER_BUILD=false
    NUM_JOBS=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--debug)
                BUILD_TYPE="Debug"
                shift
                ;;
            -r|--release)
                BUILD_TYPE="Release"
                shift
                ;;
            -c|--clean)
                CLEAN_BUILD=true
                shift
                ;;
            -i|--install)
                INSTALL_AFTER_BUILD=true
                shift
                ;;
            -j|--jobs)
                NUM_JOBS="$2"
                shift 2
                ;;
            -b|--build-dir)
                BUILD_DIR="$2"
                shift 2
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  -d, --debug       Build in Debug mode"
                echo "  -r, --release     Build in Release mode (default)"
                echo "  -c, --clean       Clean previous build before building"
                echo "  -i, --install     Install the application after building"
                echo "  -j, --jobs N      Number of parallel jobs (default: auto-detected)"
                echo "  -b, --build-dir   Build directory (default: build)"
                echo "  -h, --help        Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    print_info "Build configuration:"
    print_info "  Platform: $PLATFORM"
    print_info "  Build type: $BUILD_TYPE"
    print_info "  Build directory: $BUILD_DIR"
    print_info "  Clean build: $CLEAN_BUILD"
    print_info "  Install after build: $INSTALL_AFTER_BUILD"
    print_info "  Parallel jobs: $NUM_JOBS"
}

# Prepare build directory
prepare_build_directory() {
    if [[ "$CLEAN_BUILD" == true ]]; then
        if [[ -d "$BUILD_DIR" ]]; then
            print_info "Cleaning build directory: $BUILD_DIR"
            rm -rf "$BUILD_DIR"
        fi
    fi
    
    mkdir -p "$BUILD_DIR"
    print_success "Build directory prepared: $BUILD_DIR"
}

# Configure the project
configure_project() {
    print_info "Configuring project..."
    
    cd "$BUILD_DIR"
    
    # Determine Qt path for CMake
    QT_CMAKE_PATH=""
    if [[ -n "$QT6_DIR" && -f "$QT6_DIR/lib/cmake/Qt6/Qt6Config.cmake" ]]; then
        QT_CMAKE_PATH="-DCMAKE_PREFIX_PATH=$QT6_DIR"
    fi
    
    # Additional flags for Windows
    if [[ "$PLATFORM" == "windows" ]]; then
        # Add Windows-specific flags if needed
        cmake .. \
            $QT_CMAKE_PATH \
            -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
            -G "Unix Makefiles"
    else
        # Linux configuration
        cmake .. \
            $QT_CMAKE_PATH \
            -DCMAKE_BUILD_TYPE=$BUILD_TYPE
    fi
    
    if [ $? -ne 0 ]; then
        print_error "CMake configuration failed"
        exit 1
    fi
    
    print_success "Project configured successfully"
    cd ..
}

# Build the project
build_project() {
    print_info "Building project with $NUM_JOBS parallel jobs..."
    
    cd "$BUILD_DIR"
    
    make -j"$NUM_JOBS"
    
    if [ $? -ne 0 ]; then
        print_error "Build failed"
        exit 1
    fi
    
    print_success "Project built successfully"
    cd ..
}

# Install the project
install_project() {
    if [[ "$INSTALL_AFTER_BUILD" == true ]]; then
        print_info "Installing project..."
        
        cd "$BUILD_DIR"
        
        make install
        
        if [ $? -ne 0 ]; then
            print_error "Installation failed"
            exit 1
        fi
        
        print_success "Project installed successfully"
        cd ..
    fi
}

# Create run scripts
create_run_scripts() {
    print_info "Creating run scripts..."
    
    # Create Linux run script
    cat > "$BUILD_DIR/run_huayan.sh" << 'EOF'
#!/bin/bash

# Auto-generated run script for Huayan SCADA System
# Generated on $(date)

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Set environment variables for Qt libraries
export LD_LIBRARY_PATH="$SCRIPT_DIR/lib:$LD_LIBRARY_PATH"
export QT_PLUGIN_PATH="$SCRIPT_DIR/plugins:$QT_PLUGIN_PATH"
export QML2_IMPORT_PATH="$SCRIPT_DIR/qml:$QML2_IMPORT_PATH"

# Run the application
"$SCRIPT_DIR/SCADASystem" "$@"
EOF

    chmod +x "$BUILD_DIR/run_huayan.sh"
    
    # Create Windows run script if on Windows
    if [[ "$PLATFORM" == "windows" ]]; then
        cat > "$BUILD_DIR/run_huayan.bat" << 'EOF'
@echo off
rem Auto-generated run script for Huayan SCADA System
rem Generated on %date%

rem Get the directory where the script is located
set SCRIPT_DIR=%~dp0

rem Set environment variables for Qt libraries
set PATH=%SCRIPT_DIR%lib;%PATH%
set QT_PLUGIN_PATH=%SCRIPT_DIR%plugins;%QT_PLUGIN_PATH%
set QML2_IMPORT_PATH=%SCRIPT_DIR%qml;%QML2_IMPORT_PATH%

rem Run the application
"%SCRIPT_DIR%SCADASystem.exe" %*
EOF
    fi
    
    print_success "Run scripts created"
}

# Package the project (optional)
package_project() {
    print_info "Packaging project..."
    
    PACKAGE_NAME="huayan-scada-${BUILD_TYPE,,}-$(date +%Y%m%d)"
    PACKAGE_DIR="$BUILD_DIR/$PACKAGE_NAME"
    
    mkdir -p "$PACKAGE_DIR"
    
    # Copy binaries
    if [[ "$PLATFORM" == "windows" ]]; then
        cp "$BUILD_DIR/SCADASystem.exe" "$PACKAGE_DIR/" 2>/dev/null || true
        cp "$BUILD_DIR/SCADASystem"*.exe "$PACKAGE_DIR/" 2>/dev/null || true
    else
        cp "$BUILD_DIR/SCADASystem" "$PACKAGE_DIR/" 2>/dev/null || true
    fi
    
    # Copy required libraries and resources
    if [[ -d "$BUILD_DIR/lib" ]]; then
        cp -r "$BUILD_DIR/lib" "$PACKAGE_DIR/"
    fi
    
    if [[ -d "$BUILD_DIR/qml" ]]; then
        cp -r "$BUILD_DIR/qml" "$PACKAGE_DIR/"
    fi
    
    if [[ -d "$BUILD_DIR/plugins" ]]; then
        cp -r "$BUILD_DIR/plugins" "$PACKAGE_DIR/"
    fi
    
    # Copy run scripts
    cp "$BUILD_DIR/run_huayan"* "$PACKAGE_DIR/" 2>/dev/null || true
    
    # Create archive
    cd "$BUILD_DIR"
    if [[ "$PLATFORM" == "windows" ]]; then
        if command -v zip &> /dev/null; then
            zip -r "${PACKAGE_NAME}.zip" "$PACKAGE_NAME"
            print_success "Package created: $BUILD_DIR/${PACKAGE_NAME}.zip"
        else
            print_warning "zip not found. Package directory: $PACKAGE_DIR"
        fi
    else
        tar -czf "${PACKAGE_NAME}.tar.gz" "$PACKAGE_NAME"
        print_success "Package created: $BUILD_DIR/${PACKAGE_NAME}.tar.gz"
    fi
    
    cd ..
}

# Main execution
main() {
    print_info "Starting cross-platform build for Huayan SCADA System"
    
    detect_platform
    check_prerequisites
    parse_arguments "$@"
    prepare_build_directory
    configure_project
    build_project
    install_project
    create_run_scripts
    
    print_success "Build completed successfully!"
    print_info "Built files are located in: $BUILD_DIR/"
    
    # Optionally package the build
    read -p "Would you like to create a distributable package? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        package_project
    fi
}

# Execute main function with all arguments
main "$@"