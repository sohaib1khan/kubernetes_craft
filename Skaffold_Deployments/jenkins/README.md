# Jenkins Deployment on Kubernetes with Skaffold

This directory contains the necessary configuration to deploy Jenkins on a Kubernetes cluster using Skaffold. Jenkins is deployed as a single-node application, utilizing persistent storage on the host machine, and is exposed via a MetalLB load balancer.

## Project Structure

```
jenkins/
├── k8s
│   ├── jenkins-deployment.yaml   # Kubernetes deployment configuration for Jenkins
│   └── jenkins-service.yaml      # Kubernetes service configuration for Jenkins
└── skaffold.yaml                 # Skaffold configuration to manage the Kubernetes deployment

```

## Requirements

- Kubernetes (single-node or multi-node cluster)
- Skaffold (for continuous development and deployment)
- MetalLB (for LoadBalancer service support)
- k3s (for lightweight Kubernetes on a single node)
- Host machine with persistent volume mounted at `/home/k8server/jenkins`

## Jenkins Configuration

- **Deployment**

The Jenkins deployment is defined in `k8s/jenkins-deployment.yaml`. It specifies the following:

- Jenkins LTS image (`jenkins/jenkins:lts`)
- Exposes two ports: `8080` for the Jenkins web UI and `50000` for the Jenkins agent
- Mounted volumes:
    - `/var/jenkins_home` on the host machine at `/home/k8server/jenkins`
    - Docker socket and binary for Jenkins to manage Docker containers on the host
- **Service**

The Jenkins service is defined in `k8s/jenkins-service.yaml`. This service is of type `LoadBalancer`, which utilizes MetalLB to expose the Jenkins UI and agent externally.

### Persistent Volumes

The Jenkins data is stored persistently on the host machine at `/home/k8server/jenkins`. This ensures that Jenkins data is preserved across container restarts.

## Skaffold Configuration

The Skaffold configuration (`skaffold.yaml`) is used for managing the deployment and service using `kubectl`:

```
apiVersion: skaffold/v2beta29
kind: Config
metadata:
  name: jenkins-k8s
deploy:
  kubectl:
    manifests:
      - ./k8s/jenkins-deployment.yaml
      - ./k8s/jenkins-service.yaml

```

This configuration allows Skaffold to deploy the Jenkins resources defined in the `k8s/` directory using the `kubectl` deployer.

## Deployment Steps

**Ensure MetalLB is Installed:** Make sure MetalLB is properly configured in your Kubernetes cluster. This will allow the `LoadBalancer` service to expose Jenkins externally.

**Run Skaffold:** To deploy Jenkins to the Kubernetes cluster using Skaffold, run the following command:

```
skaffold run

```

- This will apply the deployment and service YAML files and deploy Jenkins to your cluster.
    
- **Access Jenkins:** Once deployed, you can access Jenkins through the external IP assigned by MetalLB. You can retrieve the IP by running:
    

```
kubectl get svc jenkins-service

```

- Then, open your browser and navigate to `http://<external-ip>:8080`.
    
- **Initial Jenkins Setup:** The initial Jenkins setup requires an administrator password, which can be found by running:
    

```
kubectl exec -it <jenkins-pod> -- cat /var/jenkins_home/secrets/initialAdminPassword

```

Replace `<jenkins-pod>` with the name of your Jenkins pod.

&nbsp;

This setup provides a scalable and maintainable way to deploy Jenkins on Kubernetes with persistent storage and continuous deployment support using Skaffold. By utilizing MetalLB, Jenkins is exposed externally, ready for integration and continuous integration tasks.
