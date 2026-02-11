# Makefile for Huayan SCADA System
# Cross-platform build automation

# Default configuration
BUILD_TYPE ?= Release
BUILD_DIR ?= build
JOBS ?= $(shell nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

# Platform detection
UNAME_S := $(shell uname -s 2>/dev/null)
ifeq ($(UNAME_S),Linux)
    PLATFORM = linux
endif
ifeq ($(UNAME_S),Darwin)
    PLATFORM = macos
endif
ifeq ($(OS),Windows_NT)
    PLATFORM = windows
endif

# Qt detection
QT6_DIR ?= $(wildcard /opt/Qt/6.[8-9]* /usr/local/Qt/6.[8-9]* $(HOME)/Qt/6.[8-9]*) 
ifeq ($(QT6_DIR),)
    # Try to find Qt using qmake if not set
    ifneq ($(shell which qmake6 2>/dev/null),)
        QT6_DIR := $(shell qmake6 -query QT_INSTALL_PREFIX 2>/dev/null)
    endif
endif

# Compiler settings
CMAKE_FLAGS := -DCMAKE_BUILD_TYPE=$(BUILD_TYPE)

# Add Qt path if found
ifneq ($(QT6_DIR),)
    CMAKE_FLAGS += -DCMAKE_PREFIX_PATH=$(QT6_DIR)
endif

.PHONY: all clean configure build install package run help

all: build

# Configure the project
configure:
	@echo "Configuring project for $(PLATFORM)..."
	@mkdir -p $(BUILD_DIR)
	@cd $(BUILD_DIR) && cmake .. $(CMAKE_FLAGS)
	@echo "Configuration completed."

# Build the project
build: configure
	@echo "Building project with $(JOBS) parallel jobs..."
	@$(MAKE) -C $(BUILD_DIR) -j$(JOBS)
	@echo "Build completed."

# Clean build artifacts
clean:
	@echo "Cleaning build directory..."
	@if [ -d $(BUILD_DIR) ]; then rm -rf $(BUILD_DIR); fi
	@echo "Clean completed."

# Install the project
install: build
	@echo "Installing project..."
	@$(MAKE) -C $(BUILD_DIR) install
	@echo "Install completed."

# Package the project
package: build
	@echo "Packaging project..."
	@cd $(BUILD_DIR) && \
	if [ "$(PLATFORM)" = "linux" ] || [ "$(PLATFORM)" = "macos" ]; then \
		tar -czf "huayan-scada-$(BUILD_TYPE)-$(PLATFORM)-$$(date +%Y%m%d).tar.gz" .; \
	else \
		zip -r "huayan-scada-$(BUILD_TYPE)-$(PLATFORM)-$$(date +%Y%m%d).zip" .; \
	fi
	@echo "Package created in $(BUILD_DIR)/"

# Run the application (after building)
run: build
	@echo "Running application..."
	@if [ "$(PLATFORM)" = "linux" ] || [ "$(PLATFORM)" = "macos" ]; then \
		cd $(BUILD_DIR) && LD_LIBRARY_PATH="lib:$$LD_LIBRARY_PATH" ./SCADASystem; \
	else \
		cd $(BUILD_DIR) && ./SCADASystem.exe; \
	fi

# Show help
help:
	@echo "Huayan SCADA System Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make [TARGET] [BUILD_TYPE=Release] [BUILD_DIR=build] [JOBS=n]"
	@echo ""
	@echo "Targets:"
	@echo "  all        - Configure and build the project (default)"
	@echo "  configure  - Configure the project with CMake"
	@echo "  build      - Build the project"
	@echo "  clean      - Clean build directory"
	@echo "  install    - Build and install the project"
	@echo "  package    - Build and create a distributable package"
	@echo "  run        - Build and run the application"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  BUILD_TYPE - Build type: Debug or Release (default: Release)"
	@echo "  BUILD_DIR  - Build directory (default: build)"
	@echo "  JOBS       - Number of parallel jobs (default: auto-detected)"
	@echo "  QT6_DIR    - Qt6 installation directory (auto-detected if not set)"

# Short aliases
debug:
	$(MAKE) BUILD_TYPE=Debug build

release:
	$(MAKE) BUILD_TYPE=Release build