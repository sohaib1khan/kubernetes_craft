#!/bin/bash

# Variables
PORT=5005
APP_NAME="app.py"
REQUIREMENTS=("flask")
PYTHON_CMD=""
PIP_CMD=""

# Function to find python3 or python
find_python() {
    if command -v python3 &>/dev/null; then
        PYTHON_CMD="python3"
    elif command -v python &>/dev/null; then
        PYTHON_CMD="python"
    else
        echo "Python is not installed. Please install Python and try again."
        exit 1
    fi
}

# Function to find pip3 or pip
find_pip() {
    if command -v pip3 &>/dev/null; then
        PIP_CMD="pip3"
    elif command -v pip &>/dev/null; then
        PIP_CMD="pip"
    else
        echo "pip is not installed. Please install pip and try again."
        exit 1
    fi
}

# Function to install required Python packages
install_requirements() {
    for package in "${REQUIREMENTS[@]}"; do
        if ! $PIP_CMD show "$package" &>/dev/null; then
            echo "Installing $package..."
            $PIP_CMD install "$package"
        else
            echo "$package is already installed."
        fi
    done
}

# Function to kill the running Flask app if it exists
kill_existing_app() {
    PID=$(ps -ef | grep "$APP_NAME" | grep -v "grep" | awk '{print $2}')
    if [ ! -z "$PID" ]; then
        echo "Killing existing Flask app with PID $PID..."
        kill -9 "$PID"
    fi
}

# Function to start the Flask app in the background
start_flask_app() {
    echo "Starting Flask app in the background..."
    nohup $PYTHON_CMD $APP_NAME > flask_output.log 2>&1 &
    echo "Flask app started with PID $!"
}

# Function to get the IP address
get_ip_address() {
    IP_ADDRESS=$(hostname -I | awk '{print $1}')
    if [ -z "$IP_ADDRESS" ]; then
        IP_ADDRESS="localhost"
    fi
    echo "Access the app at: http://$IP_ADDRESS:$PORT"
}

# Main script logic
find_python
find_pip
install_requirements
kill_existing_app
start_flask_app
get_ip_address
