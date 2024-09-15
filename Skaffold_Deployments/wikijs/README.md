# Wiki.js Kubernetes Deployment

This directory  contains a Kubernetes deployment configuration for deploying [Wiki.js](https://wiki.js.org/) with PostgreSQL on Kubernetes using `Skaffold` for continuous development.

## Project Structure

```
.
├── k8s
│   └── deployment.yaml
└── skaffold.yaml

1 directory, 2 files
```

- **k8s/deployment.yaml**: The Kubernetes deployment YAML file containing the configuration for Wiki.js and PostgreSQL.
- **skaffold.yaml**: The Skaffold configuration file for managing the deployment lifecycle in Kubernetes.

## Deployment Setup

### Requirements

1. **Kubernetes cluster**: Ensure you have a Kubernetes cluster set up (e.g., Minikube, k3s, GKE, EKS, etc.).
2. **Skaffold**: Skaffold needs to be installed for continuous development and easy management of Kubernetes manifests.
3. **kubectl**: Kubectl must be installed and configured to interact with your Kubernetes cluster.

### Files

- `deployment.yaml`: This file contains the configurations for the Wiki.js and PostgreSQL deployments, services, persistent volumes, and claims.
- `skaffold.yaml`: The Skaffold configuration is responsible for applying the manifests to the Kubernetes cluster.

### How to Deploy

1. **Clone the repository**:

   ```bash
   git clone <repository-url>
   cd <repository-directory>
- **Check the Kubernetes configuration**:
    
    The `k8s/deployment.yaml` file contains the Kubernetes deployment configuration. It includes:
    
    - Persistent volumes and claims for Wiki.js and PostgreSQL.
    - Services for exposing PostgreSQL and Wiki.js.
    - Deployment specifications for both applications.
- **Start the deployment with Skaffold**:
    
    Run the following command to deploy the app using `Skaffold`:
    

```
skaffold dev

```

- This command will deploy the services and continuously monitor changes to the code or configurations. If there are changes, it will automatically redeploy the application.
    
- **Verify the Deployment**:
    
    Use `kubectl` to verify that the services and pods are running:
    

```
kubectl get pods -n <namespace>
kubectl get svc -n <namespace>

```

### Customization

1.  **Persistent Volumes**:
    
    In the `deployment.yaml`, you can update the `hostPath` and storage settings under the `PersistentVolume` configuration:
    

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: wikijs-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/path/to/data"

```

2. **PostgreSQL Configuration**:

The PostgreSQL database settings (username, password, database name) can be configured in the environment variables in the `deployment.yaml` file:

```
env:
  - name: POSTGRES_DB
    value: "<your-db-name>"
  - name: POSTGRES_USER
    value: "<your-db-user>"
  - name: POSTGRES_PASSWORD
    value: "<your-db-password>"

```

3.  **Wiki.js Configuration**:

Wiki.js is configured to connect to PostgreSQL using environment variables in the `deployment.yaml` file. You can adjust these variables as needed:

```
env:
  - name: DB_TYPE
    value: "postgres"
  - name: DB_HOST
    value: "db"
  - name: DB_PORT
    value: "5432"
  - name: DB_USER
    value: "<your-db-user>"
  - name: DB_PASS
    value: "<your-db-password>"
  - name: DB_NAME
    value: "<your-db-name>"

```

### Notes

- Make sure that the paths and volumes are correctly set according to your environment.
- Adjust the namespace in the `deployment.yaml` if necessary.
- Be cautious with sensitive information (e.g., passwords) and consider using Kubernetes secrets for storing sensitive data.
