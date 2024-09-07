This project is a Python-based web application that helps manage finances. The application can be run and developed continuously within a Kubernetes cluster, allowing real-time updates using **Skaffold**. The setup includes Kubernetes deployment configurations and supporting bash scripts to streamline the process of developing, building, and deploying the application.

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Project Structure](#project-structure)
  - [Important Files:](#important-files)
- [Prerequisites](#prerequisites)
- [Running the App Locally](#running-the-app-locally)
- [Deploying on Kubernetes with Skaffold](#deploying-on-kubernetes-with-skaffold)
  - [Steps to Deploy:](#steps-to-deploy)
- [Additional Bash Scripts](#additional-bash-scripts)
  - [`run_flask.sh`:](#run_flasksh)
  - [`k8s_run.sh`:](#k8s_runsh)
- [Developing While Deploying](#developing-while-deploying)
- [Accessing the Application](#accessing-the-application)

* * *

## Project Structure

The folder structure is designed to separate application code, Docker configurations, and Kubernetes deployment files:

```
.
├── app.py                  # Main Python application
├── data                    # JSON data files used by the app
│   ├── finance_data.json
│   └── user.json
├── Dockerfile              # Dockerfile to containerize the app
├── img                     # Image assets
├── k8s                     # Kubernetes manifests
│   ├── deployment.yaml     # Kubernetes deployment configuration
│   └── service.yaml        # Kubernetes service configuration (LoadBalancer)
├── k8s_run.sh              # Script to build, deploy the app using Skaffold
├── run_flask.sh            # Script to run Flask locally
├── skaffold.yaml           # Skaffold configuration for continuous development
├── static                  # Static files (CSS)
└── templates               # HTML templates for the Flask app

```

### Important Files:

- **`app.py`**: The main application logic for the Finance Manager.
- **`Dockerfile`**: Defines how to containerize the Python app.
- **`skaffold.yaml`**: Configuration for Skaffold to automate the build, push, and deployment process to Kubernetes.
- **`k8s/`**: Contains Kubernetes deployment and service files.
    - `deployment.yaml`: Defines the deployment of the app in Kubernetes.
    - `service.yaml`: Exposes the app via a LoadBalancer service.
- **Bash Scripts**:
    - `k8s_run.sh`: Automates the Docker build and Kubernetes deployment process using Skaffold.
    - `run_flask.sh`: Starts the app locally for quick development without Kubernetes.

* * *

## Prerequisites

Before running or deploying the app, ensure you have the following installed:

- **Docker**: For containerizing the application.
- **Kubernetes**: Running on your local machine or remote cluster (e.g., K3s, Minikube, etc.).
- **Skaffold**: For continuous development and deployment in Kubernetes.
- **kubectl**: For interacting with your Kubernetes cluster.
- **Python 3**: To run the app locally.

Install Skaffold:

```
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
chmod +x skaffold
sudo mv skaffold /usr/local/bin

```

Ensure you have a **LoadBalancer** configured (if running on bare metal, consider using MetalLB).

* * *

## Running the App Locally

If you want to quickly test the app locally (without Kubernetes), you can use the provided `run_flask.sh` script:

1.  Open a terminal and navigate to the project folder.
    
2.  Run the following command:
    

```
bash run_flask.sh

```

This script will:

- - Check for `Python` and `pip` on your machine.
    - Install any required dependencies.
    - Start the Flask app and make it accessible at `http://localhost:5005`.

* * *

## Deploying on Kubernetes with Skaffold

If you want to deploy and continuously develop the application on Kubernetes, you can use Skaffold. Skaffold will build your Docker image, push it to a container registry, and deploy the application into your Kubernetes cluster.

### Steps to Deploy:

1.  **Create an Image Pull Secret** (if using a private Docker registry): If you're using a private Docker registry, create a Kubernetes secret for pulling images:

```
kubectl create secret generic regcred \
  --from-file=.dockerconfigjson=$HOME/.docker/config.json \
  --type=kubernetes.io/dockerconfigjson \
  --namespace money-manager

```

&nbsp;2.  **Run the `k8s_run.sh` script**: The provided `k8s_run.sh` script will handle Dockerfile generation and trigger the Skaffold build and deployment.

Run the following command to start the process:

```
bash k8s_run.sh

```

This script will:

- - Automatically generate the `Dockerfile`.
    - Build the Docker image for your application.
    - Deploy the app to your Kubernetes cluster using Skaffold.
    

3.   **Access the Application**: After deployment, if you have configured the `service.yaml` to use a LoadBalancer, you can access the app through the external IP assigned by your Kubernetes LoadBalancer (check with `kubectl get services`).

Example command to get the external IP:

```
kubectl get services -n YOUR_NAMESPACE

```

&nbsp;

## Additional Bash Scripts

### `run_flask.sh`:

Use this script to run the app locally in a development environment. It installs required Python packages and runs the Flask app at `http://localhost:5005`.

### `k8s_run.sh`:

This script streamlines the Kubernetes deployment process using Skaffold. It ensures the Dockerfile is set up correctly, then builds and deploys the app to your K8s cluster.

* * *

## Developing While Deploying

One of the advantages of using Skaffold is that you can **develop your app while it's running on Kubernetes**. If you modify your Python code, Skaffold will detect the changes, rebuild the Docker image, and redeploy it automatically to your Kubernetes cluster.

To start the continuous development process, use the following command:

```
skaffold dev

```

&nbsp;

This project setup allows you to easily develop and deploy a Python-based web app on Kubernetes. Whether you're running the app locally for quick tests or deploying it on a Kubernetes cluster with Skaffold, the provided bash scripts and configuration files make it simple to manage the entire process.



## Accessing the Application:

The script will output the IP address and port where you can access the web interface. Typically, this would be:

```
http://<your-ip-address>:5005
```

Default username and password can be in changed in the following  `data/user.json`  file. 

```
    "username": "admin",
    "password": "password123"

```
![gifDemo](https://github.com/sohaib1khan/Finance_Manager_Web_Application/blob/main/Kubernetes/img/Finance_Manage.gif)


