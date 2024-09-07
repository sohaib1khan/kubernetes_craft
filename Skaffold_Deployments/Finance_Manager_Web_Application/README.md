# Deployment Options

This project provides two methods for deploying and running the Finance Manager Web Application. You can choose between using Docker for local containerized deployment or Kubernetes with Skaffold for continuous development and cloud-native deployment.

## Deployment Methods

1.  **Docker** (for local development and deployment in a Docker container)
2.  **Kubernetes** (for deploying and developing in a Kubernetes cluster using Skaffold)

Each directory contains the necessary files and scripts for its respective deployment. Follow the instructions in the respective directories to set up and run the application.

* * *

## Docker Deployment

The **Docker** directory contains everything you need to run the app locally using Docker.

### Files and Directories:

- **`run_docker.sh`**: A bash script to build and run the Docker container.
- **`app.py`**: The Python web application.
- **`data/`**: Contains JSON files with the app’s data.
- **`static/` and `templates/`**: Assets and HTML templates for the Flask app.
- **`run_flask.sh`**: Run the Flask app directly without Docker for local testing.

### Instructions:

1.  Navigate to the `Docker` directory:

```
cd Docker
```

&nbsp; 2. Run the app in a Docker container using the provided `run_docker.sh`:

```
bash run_docker.sh
```

For more detailed instructions, please refer to the `README.md` inside the `Docker` directory.

* * *

## Kubernetes Deployment

The **Kubernetes** directory contains the files necessary to deploy the app in a Kubernetes cluster using **Skaffold**.

### Files and Directories:

- **`skaffold.yaml`**: Skaffold configuration file for continuous development and deployment.
- **`k8s/`**: Kubernetes manifests for deploying the app.
    - `deployment.yaml`: Defines the Kubernetes deployment for the app.
    - `service.yaml`: Exposes the app via a Kubernetes LoadBalancer service.
- **`k8s_run.sh`**: A script to automatically build and deploy the app using Skaffold.
- **`Dockerfile`**: Defines how to containerize the app for Kubernetes.

### Instructions:

1.  Navigate to the `Kubernetes` directory:

```
cd Kubernetes

```

&nbsp; 2. Run the Kubernetes deployment using the provided `k8s_run.sh` script:

```
bash k8s_run.sh
```

For more detailed instructions on setting up the app with Kubernetes, refer to the `README.md` inside the `Kubernetes` directory.

* * *

You have two options for deploying and running the Finance Manager Web Application:

- Use **Docker** for quick, containerized local development.
- Use **Kubernetes** for cloud-native deployment with continuous development capabilities via **Skaffold**.

Choose the appropriate method based on your use case and follow the corresponding instructions for a seamless setup.



### Demo 

![gifDemo](https://github.com/sohaib1khan/Finance_Manager_Web_Application/blob/main/Kubernetes/img/Finance_Manage.gif)

&nbsp;

![Login](https://github.com/sohaib1khan/Finance_Manager_Web_Application/blob/main/Kubernetes/img/Login.png)


&nbsp;

![Demo](https://github.com/sohaib1khan/Finance_Manager_Web_Application/blob/main/Kubernetes/img/Screenshot%202024-09-04%20at%2000-27-38%20Finance%20Manager.png)



