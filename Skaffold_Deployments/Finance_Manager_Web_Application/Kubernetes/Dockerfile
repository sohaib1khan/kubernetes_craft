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

EXPOSE 5022

CMD ["python", "app.py"]

