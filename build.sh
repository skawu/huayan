#!/bin/bash

# Qt6 Project Build Script for Huayan SCADA System
# Automatically detects Qt6 environment and sets up build

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
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        PLATFORM="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="macos"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        PLATFORM="windows"
    else
        PLATFORM="unknown"
    fi
    
    print_info "Detected platform: $PLATFORM"
}

# Find Qt6 installation
find_qt6() {
    print_info "Searching for Qt6 installation..."
    
    # Common Qt6 installation paths
    QT6_POSSIBLE_PATHS=()
    
    if [[ "$PLATFORM" == "linux" ]]; then
        QT6_POSSIBLE_PATHS+=(
            "/opt/Qt/6.8.3/gcc_64"
            "/opt/Qt/6.8.2/gcc_64"
            "/opt/Qt/6.8.1/gcc_64"
            "/opt/Qt/6.8.0/gcc_64"
            "/opt/Qt/6.9*/gcc_64"
            "/usr/local/Qt/6.8.3/gcc_64"
            "/usr/local/Qt/6.8.*/gcc_64"
            "$HOME/Qt/6.8.3/gcc_64"
            "$HOME/Qt/6.8.*/gcc_64"
        )
    elif [[ "$PLATFORM" == "windows" ]]; then
        QT6_POSSIBLE_PATHS+=(
            "C:/Qt/6.8.3/msvc2022_64"
            "C:/Qt/6.8.3/mingw_64"
            "C:/Qt/6.8.2/msvc2022_64"
            "C:/Qt/6.8.2/mingw_64"
            "C:/Qt/6.8.1/msvc2022_64"
            "C:/Qt/6.8.1/mingw_64"
            "C:/Qt/6.8.0/msvc2022_64"
            "C:/Qt/6.8.0/mingw_64"
            "C:/Qt/6.9*/msvc2022_64"
            "C:/Qt/6.9*/mingw_64"
        )
    elif [[ "$PLATFORM" == "macos" ]]; then
        QT6_POSSIBLE_PATHS+=(
            "/Users/$USER/Qt/6.8.3/clang_64"
            "/Users/$USER/Qt/6.8.*/clang_64"
            "/usr/local/Qt/6.8.3/clang_64"
            "/usr/local/Qt/6.8.*/clang_64"
        )
    fi
    
    # Check if qmake6 is in PATH
    if command -v qmake6 &> /dev/null; then
        QT6_BIN_DIR=$(dirname "$(command -v qmake6)")
        QT6_DIR=$(dirname "$QT6_BIN_DIR")
        print_info "Found Qt6 via qmake6: $QT6_DIR"
        return 0
    fi
    
    # Search in common paths
    for qt_path in "${QT6_POSSIBLE_PATHS[@]}"; do
        # Handle wildcard paths
        for expanded_path in $qt_path; do
            if [[ -f "$expanded_path/bin/qmake" ]] || [[ -f "$expanded_path/bin/qmake.exe" ]]; then
                QT6_DIR="$expanded_path"
                print_info "Found Qt6 at: $QT6_DIR"
                return 0
            fi
        done
    done
    
    # Last resort: check Qt installation in /opt/Qt with version detection
    if [[ -d "/opt/Qt" ]]; then
        for qt_version_dir in /opt/Qt/6.*; do
            if [[ -d "$qt_version_dir" ]]; then
                for compiler_dir in "$qt_version_dir"/*/; do
                    if [[ -f "$compiler_dir/bin/qmake" ]] || [[ -f "$compiler_dir/bin/qmake.exe" ]]; then
                        QT6_DIR="$compiler_dir"
                        print_info "Found Qt6 at: $QT6_DIR"
                        return 0
                    fi
                done
            fi
        done
    fi
    
    print_error "Could not find Qt6 installation. Please install Qt 6.8 LTS or later."
    return 1
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
            -q|--qt-path)
                QT6_DIR="$2"
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
                echo "  -q, --qt-path     Qt6 installation path (default: auto-detected)"
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
    print_info "  Qt6 path: $QT6_DIR"
    print_info "  Build type: $BUILD_TYPE"
    print_info "  Build directory: $BUILD_DIR"
    print_info "  Clean build: $CLEAN_BUILD"
    print_info "  Install after build: $INSTALL_AFTER_BUILD"
    print_info "  Parallel jobs: $NUM_JOBS"
}

# Prepare build environment
prepare_environment() {
    print_info "Preparing build environment..."
    
    # Add Qt6 to PATH
    export PATH="$QT6_DIR/bin:$PATH"
    
    # Set Qt6-related environment variables
    if [[ "$PLATFORM" == "linux" ]]; then
        export LD_LIBRARY_PATH="$QT6_DIR/lib:$LD_LIBRARY_PATH"
        export PKG_CONFIG_PATH="$QT6_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"
    elif [[ "$PLATFORM" == "macos" ]]; then
        export DYLD_LIBRARY_PATH="$QT6_DIR/lib:$DYLD_LIBRARY_PATH"
        export PKG_CONFIG_PATH="$QT6_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"
    elif [[ "$PLATFORM" == "windows" ]]; then
        export PATH="$QT6_DIR/bin:$PATH"
        export PATH="$QT6_DIR/lib:$PATH"
    fi
    
    print_success "Build environment prepared"
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
    print_info "Configuring project with Qt6 from: $QT6_DIR"
    
    cd "$BUILD_DIR"
    
    # Determine CMake generator based on platform
    if [[ "$PLATFORM" == "windows" ]]; then
        # On Windows, check for MSVC vs MinGW
        if [[ -f "$QT6_DIR/bin/cl.exe" ]] || command -v cl &> /dev/null; then
            GENERATOR="-G \"Visual Studio 17 2022\" -A x64"
        else
            GENERATOR="-G \"MinGW Makefiles\""
        fi
    else
        GENERATOR=""
    fi
    
    # Configure with Qt6 path
    cmake .. \
        -DCMAKE_PREFIX_PATH="$QT6_DIR" \
        -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
        $GENERATOR
    
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

# Main execution
main() {
    print_info "Starting Qt6-based build for Huayan SCADA System"
    
    detect_platform
    find_qt6 || exit 1
    parse_arguments "$@"
    prepare_environment
    prepare_build_directory
    configure_project
    build_project
    install_project
    
    print_success "Build completed successfully!"
    print_info "Built files are located in: $BUILD_DIR/"
    print_info "To run the application, go to $BUILD_DIR/ and execute the generated executable"
}

# Execute main function with all arguments
main "$@"