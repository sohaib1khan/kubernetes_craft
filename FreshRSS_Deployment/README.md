# FreshRSS Kubernetes Deployment

## Prerequisites
Before deploying FreshRSS, ensure you have the following setup:

- A running Kubernetes cluster.
- `kubectl` configured to interact with your cluster.
- MetalLB or a similar LoadBalancer service set up (for LoadBalancer IP assignment).
- Proper namespace (`freshrss`) created or ensure it's created as part of deployment.

## Kubernetes Manifests Overview

### 1. **CronJob** (`freshrss-update`)
- **Purpose:** Automates the update of RSS feeds every 30 minutes.
- **Container:** Utilizes `curlimages/curl:latest` to send a POST request to FreshRSS's API endpoint.
- **Schedule:** Runs every 30 minutes as defined by the cron expression `*/30 * * * *`.
- **Restart Policy:** Configured to restart only on failure, ensuring reliability without unnecessary restarts.

### 2. **Deployment** (`freshrss`)
- **Purpose:** Deploys the FreshRSS application.
- **Replicas:** Set to 1, ensuring a single instance is running.
- **Image:** Uses the `freshrss/freshrss:latest` image.
- **Ports:** Exposes container port `80` for HTTP traffic.
- **Environment Variable:**
  - `TZ`: Configured to `America/New_York` for timezone settings.
- **Storage:** Mounts a persistent volume at `/var/www/FreshRSS/data` to ensure data persistence.

### 3. **Service** (`freshrss-service`)
- **Purpose:** Exposes the FreshRSS deployment to external networks.
- **Type:** LoadBalancer for easy access using an IP.
- **IP Assignment:** Static IP `192.168.1.213` is assigned via MetalLB.
- **Ports:** Listens on port `80`, mapping it to the same container port.

### 4. **Persistent Volume (PV)** (`freshrss-pv`)
- **Purpose:** Provides persistent storage for FreshRSS data.
- **Capacity:** Allocates `5Gi` of storage.
- **Access Mode:** `ReadWriteOnce` - suitable for single node read/write operations.
- **Reclaim Policy:** `Retain` to prevent data deletion even after the PVC is deleted.
- **Host Path:** Maps to `/home/k8server/freshRSS_K8s` on the host machine.

### 5. **Persistent Volume Claim (PVC)** (`freshrss-pvc`)
- **Purpose:** Requests storage from the Persistent Volume.
- **Capacity:** Requests `5Gi` of storage.
- **Binding:** Binds directly to `freshrss-pv`.
- **Storage Class:** Dynamic provisioning disabled (`storageClassName: ""`).

## Deployment Instructions

1. **Create the Namespace:**  
   ```bash
   kubectl create namespace freshrss
   ```

2. **Apply the Manifests:**  
   Save the configuration to `freshrss-deployment.yaml` and apply:
   ```bash
   kubectl apply -f freshrss-deployment.yaml
   ```

3. **Verify Deployments:**  
   ```bash
   kubectl get pods -n freshrss
   kubectl get svc -n freshrss
   ```

4. **Access FreshRSS:**  
   Open your browser and navigate to `http://192.168.1.213`.

## Storage Setup Details

- **Persistent Volume (PV):** Configured with `hostPath`, storing data at `/home/k8server/freshRSS_K8s` on the host machine. This ensures data is retained even if the pod restarts.
- **Persistent Volume Claim (PVC):** Claims storage from the PV, binding the data directory within the container to the persistent volume.
- **Reclaim Policy:** `Retain` ensures that even if the PVC is deleted, the data remains intact on the host.

> **Note:** Ensure that the host path `/home/k8server/freshRSS_K8s` has proper permissions for read/write operations.

## Maintenance
- **Updating Feeds:** Handled automatically by the CronJob every 30 minutes.
- **Scaling:** Adjust the `replicas` field in the Deployment manifest to scale FreshRSS instances.
- **Backup:** Regularly back up the `/home/k8server/freshRSS_K8s` directory to secure your data.

