# Joplin Kubernetes Deployment

This repository contains Kubernetes manifests to deploy the [Joplin Server](https://joplinapp.org/) with a PostgreSQL database on a Kubernetes cluster. The deployment is managed using Skaffold, allowing you to deploy and manage the application easily.

## Prerequisites

Before deploying Joplin on your Kubernetes cluster, ensure the following prerequisites are met:

- A running Kubernetes cluster (e.g., k3s, minikube, or any other Kubernetes setup).
- `kubectl` installed and configured to access your cluster.
- **Skaffold** installed for managing deployments.
- A LoadBalancer configured in your Kubernetes cluster (e.g., MetalLB for local clusters).

### Required Tools:

1. **kubectl**: For interacting with your Kubernetes cluster.
2. **Skaffold**: To handle the deployment of your Kubernetes manifests.

## Project Structure

```bash
.
├── k8s/
│   ├── joplin-server-deployment.yaml   # Deployment and Service for Joplin server
│   ├── notes.txt                       # Notes on base64 encoding
│   ├── postgres-deployment.yaml        # Deployment and Service for PostgreSQL database
│   ├── postgres-secret.yaml            # Secret for PostgreSQL password
├── skaffold.yaml                       # Skaffold configuration for managing deployments
└── README.md                           # This README file

## Configuration

Before deploying, customize the following values:

### PostgreSQL Secret

In `k8s/postgres-secret.yaml`, the `POSTGRES_PASSWORD` is stored as a base64-encoded value. You can update the password by running the following command and replacing the encoded value:

```
echo -n "your-new-password" | base64
```

Replace the `POSTGRES_PASSWORD` value in `postgres-secret.yaml` with the new base64 encoded password.

### Joplin Base URL and LoadBalancer IP

In `k8s/joplin-server-deployment.yaml`:

1.  Replace the `APP_BASE_URL` with your desired URL for accessing Joplin.
2.  Replace `loadBalancerIP` with the external IP of your LoadBalancer in your environment.

Example:

```
- name: APP_BASE_URL
  value: "https://write.your-domain.com:22300"

loadBalancerIP: 192.168.1.100

```

### Persistent Volume

Ensure the persistent volume path defined in `postgres-deployment.yaml` (`/home/k8server/joplin_server`) is correctly set for your environment. This directory will store the PostgreSQL data on the node.

## Deployment

To deploy the application using Skaffold, follow these steps:

### Step 1: Clone the Repository

```
git clone https://github.com/sohaib1khan/kubernetes_craft.git 
cd Joplin

```

### Step 2: Apply Secrets

First, apply the PostgreSQL secret:

```
kubectl apply -f ./k8s/postgres-secret.yaml

```

### Step 3: Deploy the Application

Deploy the PostgreSQL database and Joplin server using Skaffold:

```
skaffold run

```

Skaffold will apply the manifests from `k8s/` and deploy both the Joplin server and PostgreSQL.

### Step 4: Access the Application

Once the deployment is complete, you can access the Joplin server at:

```
http://<your-loadbalancer-ip>:22300

```

or

```
https://<your-domain>:22300 (if SSL is configured)

```

### Step 5: Verifying Deployment

Check that both the PostgreSQL and Joplin server pods are running:

```
kubectl get pods

```

You should see output similar to:

```
NAME                             READY   STATUS    RESTARTS   AGE
joplin-server-57cfb68d4c-xmwkv   1/1     Running   0          2m
postgres-569d8fddf4-xqvkx        1/1     Running   0          2m

```

Also, verify that services are running and the external IP is assigned:

```
kubectl get svc

```

You should see output like:

```
NAME            TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)           AGE
joplin-server   LoadBalancer   10.43.160.61   192.168.1.100   22300:31747/TCP   2m
postgres        ClusterIP      10.43.65.24    <none>          5432/TCP          2m

```

### Step 6: Clean Up

To delete the deployment, run:

```
skaffold delete

```

This will remove all the resources related to the Joplin and PostgreSQL deployments.

## Customization

- **Scaling**: You can adjust the `replicas` field in the deployment files to scale your PostgreSQL or Joplin server instances.
- **Persistent Storage**: Customize the `hostPath` or replace it with a cloud-based or shared storage solution like NFS or AWS EBS for production environments.
- **Environment Variables**: Customize other environment variables like `POSTGRES_USER`, `POSTGRES_DB`, and `APP_PORT` based on your preferences.

## Troubleshooting

- **Pod Not Starting**: Check the logs of the failing pod:

```
kubectl logs <pod-name>

```

- **Database Connection Issue**: Ensure that the PostgreSQL service is running and that the Joplin server has the correct connection details (`POSTGRES_HOST`, `POSTGRES_PORT`, etc.).
    
- **Persistent Volume Issue**: Verify the persistent volume path exists on the node and has the correct permissions:
    

```
ls -al /home/k8server/joplin_server

```

