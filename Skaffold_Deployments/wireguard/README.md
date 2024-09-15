# WireGuard Kubernetes Deployment
This directory  provides a Kubernetes deployment for [WireGuard](https://www.wireguard.com/), allowing you to run WireGuard in a Kubernetes cluster using a PersistentVolume to store configuration and keys.

## Files

- `k8s/deployment.yaml`: The Kubernetes manifest for deploying WireGuard.
- `skaffold.yaml`: Configuration for using [Skaffold](https://skaffold.dev/) to manage deployment.

## Prerequisites

Before deploying WireGuard on Kubernetes, make sure you have the following:

- A running Kubernetes cluster
- `kubectl` installed and configured to interact with your cluster
- `Skaffold` installed (optional, if using Skaffold for deployment)
- Sufficient privileges to create PersistentVolumes and PersistentVolumeClaims

## Steps to Deploy WireGuard on Kubernetes

### 1. Clone the Repository

```
cd wireguard-k8s

```

### 2. Update the Configuration

Modify the Kubernetes manifest (`k8s/deployment.yaml`) as needed:

- **PersistentVolume**: Update the `path` under `hostPath` to specify where you want to store WireGuard configuration files.
- **Environment Variables**: Set the correct `PUID`, `PGID`, `TZ`, `SERVERURL`, etc., as per your requirements.

### 3. Set Permissions and Ownership for the Persistent Storage

Make sure the directory where the PersistentVolume is mounted has the correct ownership and permissions. This is necessary to avoid permission issues inside the container.

1.  **Create the Directory (if it doesn't exist)**:

```
sudo mkdir -p /path/to/your/data
```

2. **Change Ownership**: Ensure the directory is owned by the user and group IDs that match the values set in the `PUID` and `PGID` environment variables (default is `1000:1000`).

```
sudo chown -R 1000:1000 /path/to/your/data

```

3. **Set Permissions**: Set the correct permissions on the directory to ensure the container can read and write data.

```
sudo chmod -R 755 /path/to/your/data
```

4. Deploy WireGuard

If you're using Skaffold for deployment, you can run:

```
skaffold dev
```

Alternatively, you can apply the Kubernetes manifest directly using `kubectl`:

```
kubectl apply -f k8s/deployment.yaml

```

5. Verify the Deployment

Check that the WireGuard pod is running:

```
kubectl get pods

```

Once the pod is running, you can retrieve peer information using:

```
kubectl exec -it <wireguard-pod-name> -- /app/show-peer <peer-number>

```

6. Expose the Service

WireGuard is exposed as a `LoadBalancer` service. Once deployed, the service will be available on port `51820/UDP`. You can get the external IP by running:

```
kubectl get svc
```

7. Configure WireGuard Clients

The WireGuard configuration files for peers are stored in the `/config` directory inside the container. You can access them by exec'ing into the pod:

```
kubectl exec -it <wireguard-pod-name> -- /bin/sh
ls /config

```

Use these configuration files or QR codes to configure your WireGuard clients.

## Notes

- **Security Context**: This deployment runs the container as `root` to ensure the necessary capabilities are available (e.g., `NET_ADMIN`, `SYS_MODULE`).
- **Peer Configuration**: By default, 3 peers are created. Adjust the `PEERS` environment variable as needed in `deployment.yaml`.
