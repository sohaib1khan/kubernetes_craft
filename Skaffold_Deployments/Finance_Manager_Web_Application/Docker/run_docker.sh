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

# Expose the specified port
EXPOSE $PORT

# Run the app
CMD ["python", "app.py"]
EOL

# Create docker-compose.yml
echo "Creating docker-compose.yml..."
cat <<EOL > docker-compose.yml
version: '3'
services:
  $APP_NAME:
    build: .
    container_name: $CONTAINER_NAME
    ports:
      - "$PORT:$PORT"
    volumes:
      - "$DATA_DIR:/app/data"
    restart: always
    environment:
      - FLASK_ENV=development
      - FLASK_APP=app.py
    command: ["python", "app.py"]
EOL

# Build and run the Docker container
echo "Building and running Docker container..."
docker-compose up --build -d

# Check if the container is running
if [ $(docker ps -q -f name=$CONTAINER_NAME) ]; then
    echo "Container is up and running."
else
    echo "Failed to start the container. Check logs for more information."
    exit 1
fi

# Output the IP address and port
echo "Access the app at: http://$HOST_IP:$PORT"
