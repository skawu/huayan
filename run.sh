#!/bin/bash

# Run script for SCADASystem

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Set working directory to script directory
cd "$SCRIPT_DIR"

# Set environment variables using relative paths
if [ -d "$SCRIPT_DIR/lib" ]; then
    export LD_LIBRARY_PATH="$SCRIPT_DIR/lib:$LD_LIBRARY_PATH"
fi

# Also add the bin/lib directory for installed libraries
if [ -d "$SCRIPT_DIR/bin/lib" ]; then
    export LD_LIBRARY_PATH="$SCRIPT_DIR/bin/lib:$LD_LIBRARY_PATH"
fi

if [ -d "$SCRIPT_DIR/qml" ]; then
    export QML2_IMPORT_PATH="$SCRIPT_DIR/qml:$QML2_IMPORT_PATH"
fi

# Add QML import path for installed QML modules
if [ -d "$SCRIPT_DIR/bin/qml" ]; then
    export QML2_IMPORT_PATH="$SCRIPT_DIR/bin/qml:$QML2_IMPORT_PATH"
fi

# Add Qt plugin path for installed plugins
if [ -d "$SCRIPT_DIR/bin/plugins" ]; then
    export QT_PLUGIN_PATH="$SCRIPT_DIR/bin/plugins:$QT_PLUGIN_PATH"
fi

# Run the application
if [ -f "$SCRIPT_DIR/bin/SCADASystem" ]; then
    echo "Starting SCADASystem..."
    "$SCRIPT_DIR/bin/SCADASystem"
else
    echo "Error: SCADASystem executable not found at $SCRIPT_DIR/bin/SCADASystem"
    echo "Please build the project first using 'cmake --build .' from the project root"
    exit 1
fi
