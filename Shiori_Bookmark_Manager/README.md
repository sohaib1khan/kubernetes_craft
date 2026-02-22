# Shiori Bookmark Manager Deployment on Kubernetes
* * *

## **Overview**

Shiori is a simple, self-hosted bookmark manager that is designed to be minimal and fast. This guide explains how to deploy Shiori on a Kubernetes cluster using a Persistent Volume (PV) for data storage and MetalLB for load balancing.

* * *

## **Deployment Components**

### 1️⃣ **Deployment Configuration (`Deployment.yaml`)**

This defines the Shiori application pod and how it should run:

- **Image:** `ghcr.io/go-shiori/shiori:latest`
- **Port:** Exposes port `8080` internally, mapped to `80` via LoadBalancer.
- **Environment Variables:**
    - `SHIORI_DIR`: Specifies the data directory (`/srv/shiori`).
    - `SHIORI_HTTP_SECRET_KEY`: Secure secret key for session management.
- **Storage:** Mounts persistent data from the PVC `bookmark-pvc` to `/srv/shiori`.

### 2️⃣ **Service Configuration (`Service.yaml`)**

Defines the service to expose Shiori externally:

- **Type:** `LoadBalancer` (works with MetalLB).
- **Port Mapping:** External Port `80` → Internal Port `8080`.

### 3️⃣ **Storage Configuration (PV & PVC)**

Handles persistent data storage:

#### Persistent Volume (`bookmark-pv`)

- **Capacity:** `5Gi`
- **Access Mode:** `ReadWriteOnce`
- **Reclaim Policy:** `Retain` (data is preserved even if the PVC is deleted).
- **Host Path:** Data is stored on the node at `/home/k8server/bookmark_manager`.

#### Persistent Volume Claim (`bookmark-pvc`)

- **Access Mode:** `ReadWriteOnce`
- **Requests:** `5Gi` of storage.
- **Binding:** Explicitly binds to `bookmark-pv`.
- **Storage Class:** Disabled dynamic provisioning (`storageClassName: ""`).

* * *

## **Storage Details**

### **Data Directory on Host**

- **Path:** `/home/k8server/bookmark_manager`
- **Persistence:**
    - Data remains intact even if the pod or PVC is deleted (due to `Retain` policy).
    - Ensure proper permissions (`chown -R 1000:1000` and `chmod -R 755`) to avoid permission issues.

### **Reclaim Policy Explained**

- **Retain:**
    - Keeps data safe even after PVC deletion.
    - To manually clean up, delete PV **and** the data directory.

* * *

## **Deployment Instructions**

### 1️⃣ Apply the Configuration Files

```bash
kubectl apply -f bookmark-pv-pvc.yaml
kubectl apply -f bookmark-deployment.yaml
```

### 2️⃣ Verify Resources

```bash
kubectl get pods -n bookmark
kubectl get svc -n bookmark
kubectl get pv,pvc -n bookmark
```

### 3️⃣ Access Shiori

- Find the external IP assigned by MetalLB:
    
    ```bash
    kubectl get svc -n bookmark
    ```
    
- Open the IP in your browser.
    

* * *

## **Access from Other Devices**

1.  Ensure the MetalLB-assigned IP is accessible from your network.
2.  Use `http://<MetalLB-IP>` on any device connected to the same network.
3.  For remote access:
    - Configure port forwarding on your router.
    - Or set up a reverse proxy like NGINX.

* * *

## **Import Bookmarks from Firefox**

1.  **Export from Firefox:** `Bookmarks Library → Export to HTML`.
2.  **Import into Shiori:** `Settings → Import Bookmarks`.

* * *

## **Security Considerations**

- Always set a strong `SHIORI_HTTP_SECRET_KEY`.
- Secure access via HTTPS using Ingress or NGINX.
- Consider network policies to restrict access.

* * *

## **Backup Strategy**

1.  Regularly back up `/home/k8server/bookmark_manager`.
2.  Use `rsync` or scheduled cron jobs.
3.  Consider Kubernetes Volume Snapshots for automated backups.

* * *

## **Troubleshooting Tips**

- **PVC Pending:** Check PV binding and permissions.
- **Pod CrashLoopBackOff:** Verify environment variables and logs.
- **Service Not Accessible:** Confirm MetalLB is running and IP is assigned.

* * *

* * *

### Enjoy managing your bookmarks with Shiori on Kubernetes!
