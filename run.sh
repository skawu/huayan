#!/bin/bash

# Run script for SCADASystem

# Set working directory
cd "/home/hdzk/workspace/project"

# Set environment variables
if [ -d "/home/hdzk/workspace/project/lib" ]; then
    export LD_LIBRARY_PATH="/home/hdzk/workspace/project/lib:$LD_LIBRARY_PATH"
fi

if [ -d "/home/hdzk/workspace/project/qml" ]; then
    export QML2_IMPORT_PATH="/home/hdzk/workspace/project/qml:$QML2_IMPORT_PATH"
fi

# Run the application
if [ -f "/home/hdzk/workspace/project/bin/SCADASystem" ]; then
    echo "Starting SCADASystem..."
    "/home/hdzk/workspace/project/bin/SCADASystem"
else
    echo "Error: SCADASystem executable not found at /home/hdzk/workspace/project/bin/SCADASystem"
    echo "Please build the project first using 'cmake --build /home/hdzk/workspace/project'"
    exit 1
fi
