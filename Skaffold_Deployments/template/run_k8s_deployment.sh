#!/bin/bash

# Variables - Customize these variables for your application
APP_NAME="your_app_name"         # The name of the application
IMAGE_NAME="your_image_name"     # The Docker image name for the application
CONTAINER_NAME="your_container_name"  # The name of the container
PORT=your_port_number            # The port number your app will run on
DATA_DIR="$(pwd)/data"           # Data directory, set to the current path + /data
HOST_IP=$(hostname -I | awk '{print $1}')  # Fetch the host IP address

# Create namespace and registry secret if they don't exist
kubectl create namespace $APP_NAME
kubectl create secret generic regcred \
  --from-file=.dockerconfigjson=$HOME/.docker/config.json \
  --type=kubernetes.io/dockerconfigjson \
  --namespace $APP_NAME

# Create Dockerfile
echo "Creating Dockerfile..."
cat <<EOL > Dockerfile
# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container
COPY . /app

# Install necessary Python dependencies
RUN python -m venv /opt/venv && \
    . /opt/venv/bin/activate && \
    pip install --no-cache-dir flask pandas matplotlib chardet pyyaml

# Ensure venv is activated
ENV PATH="/opt/venv/bin:$PATH"

# Expose the application port
EXPOSE $PORT

# Command to run the application
CMD ["python", "app.py"]

EOL

# Launch with Skaffold
echo "Launching with Skaffold..."
skaffold dev &
SKAFFOLD_PID=$!

# Save Skaffold PID to manage it later
echo "Skaffold is running with PID $SKAFFOLD_PID"
echo $SKAFFOLD_PID > skaffold.pid
