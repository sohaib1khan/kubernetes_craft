#!/bin/bash

# Variables
APP_NAME="log_parser"
IMAGE_NAME="log_parser"
CONTAINER_NAME="log_parser"
PORT=5009
DATA_DIR="$(pwd)/data"
HOST_IP=$(hostname -I | awk '{print $1}')

# Create namespace and registry secret if they don't exist
kubectl create namespace log-parser
kubectl create secret generic regcred \
  --from-file=.dockerconfigjson=$HOME/.docker/config.json \
  --type=kubernetes.io/dockerconfigjson \
  --namespace log-parser

# Create Dockerfile
echo "Creating Dockerfile..."
cat <<EOL > Dockerfile
# Stage 1: Build Stage
FROM python:3.9-alpine AS builder

# Install build dependencies
RUN apk add --no-cache gcc musl-dev python3-dev libffi-dev

# Set the working directory
WORKDIR /app

# Copy only necessary files for installing dependencies
COPY requirements.txt .

# Install the dependencies in a virtual environment
RUN python -m venv /opt/venv && \
    . /opt/venv/bin/activate && \
    pip install --no-cache-dir -r requirements.txt

# Stage 2: Final Stage
FROM python:3.9-alpine

# Set the working directory
WORKDIR /app

# Copy the virtual environment and application files from the builder stage
COPY --from=builder /opt/venv /opt/venv
COPY . .

# Set environment path
ENV PATH="/opt/venv/bin:$PATH"

# Expose the application port
EXPOSE 5009

# Command to run the application
CMD ["python", "app.py"]
EOL

# Create a .dockerignore file to reduce the size of the Docker image
echo "Creating .dockerignore..."
cat <<EOL > .dockerignore
__pycache__
*.pyc
*.pyo
.git
*.log
.env
node_modules
data
EOL

# Create requirements.txt
echo "Creating requirements.txt..."
cat <<EOL > requirements.txt
flask
pandas
matplotlib
chardet
pyyaml
EOL

# Launch with skaffold
echo "Launching with skaffold..."
skaffold dev &
SKAFFOLD_PID=$!

# Save Skaffold PID to manage it later
echo "Skaffold is running with PID $SKAFFOLD_PID"
echo $SKAFFOLD_PID > skaffold.pid
