#!/bin/bash

# Function to check if python or python3 is installed
check_python() {
    if command -v python3 &>/dev/null; then
        echo "Python3 found"
        PYTHON_CMD="python3"
    elif command -v python &>/dev/null; then
        echo "Python found"
        PYTHON_CMD="python"
    else
        echo "Python is not installed. Please install Python or Python3."
        exit 1
    fi
}

# Function to check if pip or pip3 is available
check_pip() {
    if command -v pip3 &>/dev/null; then
        echo "pip3 found"
        PIP_CMD="pip3"
    elif command -v pip &>/dev/null; then
        echo "pip found"
        PIP_CMD="pip"
    else
        echo "pip is not installed. Please install pip or pip3."
        exit 1
    fi
}

# Install the necessary libraries using pip
install_dependencies() {
    echo "Installing required libraries..."
    $PIP_CMD install flask pandas matplotlib chardet pyyaml
}

# Run the Python Flask app in detached mode and log output to a file
run_app() {
    echo "Starting Flask app in detached mode..."
    nohup $PYTHON_CMD app.py > app_debug_log 2>&1 &
    echo "App is running in detached mode. Logs are being written to app_debug_log."
}

# Main script execution
check_python
check_pip
install_dependencies
run_app
