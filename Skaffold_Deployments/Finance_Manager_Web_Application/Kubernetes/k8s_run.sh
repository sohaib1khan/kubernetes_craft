#!/bin/bash

# Variables
APP_NAME="money_app"
IMAGE_NAME="money_app_image"
CONTAINER_NAME="money_app_container"
PORT=5005
DATA_DIR="$(pwd)/data"  # Mount the data directory where the script is run
HOST_IP=$(hostname -I | awk '{print $1}')

# Create Dockerfile
echo "Creating Dockerfile..."
cat <<EOL > Dockerfile
# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container
COPY . /app

# Install any necessary dependencies
RUN pip install --no-cache-dir flask
RUN pip install --no-cache-dir flask_simplelogin
RUN pip install --no-cache-dir python-dotenv

EXPOSE 5025

CMD ["python", "app.py"]

EOL

# Launch with skaffold
echo "Launching with skaffold..."

skaffold run