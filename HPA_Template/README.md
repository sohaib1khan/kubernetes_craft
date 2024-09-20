# Kubernetes Deployment & HorizontalPodAutoscaler Template

## Overview

This repository/directory contains templates for setting up a **Kubernetes Deployment** and a **HorizontalPodAutoscaler (HPA)**. These templates are designed to be reusable, allowing you to easily deploy applications and autoscale them based on CPU utilization.

## Files

- `deployment-template.yaml`: This file defines a template for deploying a containerized application in Kubernetes.
- `hpa-template.yaml`: This file provides a template for autoscaling the deployed application using Kubernetes' Horizontal Pod Autoscaler (HPA) based on CPU utilization.

## How to Use the Templates

### 1. Deployment Template

The **Deployment** template defines the configuration for running your containerized application, including the number of replicas, resource requests and limits, volumes, and image pull secrets for private registries.

#### Key Fields

- `deployment_name`: Name of your Kubernetes Deployment.
- `namespace`: Kubernetes namespace where the application will be deployed.
- `replicas`: Initial number of pod replicas.
- `app_name`: Label for the application, used for selecting pods.
- `container_name`: Name of the container inside the pod.
- `image_registry_url`: URL of the container registry where your image is stored.
- `image_name`: Name of the container image.
- `image_tag`: Tag of the image (e.g., `latest`).
- `container_port`: Port on which your application listens.
- `cpu_requests`, `memory_requests`: Minimum resource requests for the container.
- `cpu_limits`, `memory_limits`: Maximum resource limits for the container.
- `host_path`: Host path for the `hostPath` volume, used for binding a directory from the host machine to the container.
- `image_pull_secret`: Kubernetes secret used to pull images from a private container registry.

#### Example

To use this template, replace the placeholders with the actual values specific to your deployment. For example:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-deployment
  namespace: production
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app-container
        image: registry.helixx.cloud/my-app:latest
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: app-data
          mountPath: /app/data
        resources:
          requests:
            cpu: "200m"
            memory: "256Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
      volumes:
      - name: app-data
        hostPath:
          path: /home/k8server/my-app
          type: Directory
      imagePullSecrets:
      - name: regcred

```

### 2. HPA Template

The **HPA** template is used to automatically scale the number of pod replicas based on CPU utilization.

#### Key Fields

- `hpa_name`: Name of the HPA resource.
- `namespace`: Kubernetes namespace where the HPA will be applied.
- `deployment_name`: The name of the target deployment that will be scaled.
- `min_replicas`: Minimum number of pod replicas.
- `max_replicas`: Maximum number of pod replicas.
- `target_cpu_utilization`: CPU utilization percentage at which autoscaling should trigger.

#### Example

To use this template, replace the placeholders with actual values for your setup. For example:

```
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app-deployment
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70

```

### 3. Steps to Deploy

- **Create a Secret for ImagePull**: If you're pulling the image from a private container registry, create a Kubernetes secret:

```
kubectl create secret docker-registry regcred \
--docker-server=<your-registry-server> \
--docker-username=<your-username> \
--docker-password=<your-password> \
--docker-email=<your-email> \
--namespace=<your-namespace>

```

- **Edit the Templates**: Replace the placeholder fields in both `deployment-template.yaml` and `hpa-template.yaml` with your specific values.
    
- **Deploy the Application**: Apply the deployment using:
    

```
kubectl apply -f deployment-template.yaml
```

- **Deploy the HPA**: Apply the HPA resource using:

```
kubectl apply -f hpa-template.yaml

```

### 4. Persistent Volumes (Optional)

If you prefer to use **Persistent Volumes** instead of `hostPath` for storage, replace the `hostPath` configuration in the deployment with a **PersistentVolumeClaim** (PVC) reference.

Example:

```
volumes:
- name: app-data
  persistentVolumeClaim:
    claimName: my-pvc

```

### Notes

- Ensure that your Kubernetes namespace is correctly set in both the Deployment and HPA templates.
- Tune the CPU and memory resources based on the performance requirements of your application.
- Regularly monitor the CPU utilization to optimize the autoscaling settings in the HPA.

* * *
