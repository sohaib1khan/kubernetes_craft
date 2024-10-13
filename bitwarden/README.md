# Vaultwarden Kubernetes Deployment

This directory contains the configuration to deploy [Vaultwarden](https://github.com/dani-garcia/vaultwarden) on a Kubernetes cluster. Vaultwarden is an unofficial Bitwarden server implementation written in Rust. It can be self-hosted and is designed to be lightweight and scalable.

## Prerequisites

Before deploying Vaultwarden on your Kubernetes cluster, ensure that the following prerequisites are met:

- A running Kubernetes cluster (e.g., k3s, minikube, or any other Kubernetes setup).
- `kubectl` installed and configured to access your cluster.
- **MetalLB** or any Load Balancer installed and configured for your Kubernetes cluster if using a local environment.
- Ensure you have an external IP address available for MetalLB if you're using it in a home lab setup.
- A Persistent Storage directory set up on your Kubernetes nodes (for hostPath storage).

### Preconfigured Variables:
- Vaultwarden will run at port `8084` (changeable in the `Service` definition).
- Data will be stored at `/PATH/TO/bitwarden` (customize this in the `hostPath` section).

## Deployment Instructions

### Step 1: Clone the Repository

```bash
git clone <https://github.com/sohaib1khan/kubernetes_craft.git
cd bitwarden
```

### Step 2: Customize the Configuration

Before applying the YAML configuration to your Kubernetes cluster, customize the following:

1.  **Domain URL**: Replace `DOMAIN` environment variable value with your Vaultwarden domain:

```
- name: DOMAIN
  value: "https://your-vaultwarden-domain.com"

```

&nbsp;2.  **Admin Token**: Replace the `ADMIN_TOKEN` with a custom token. This token is required to access the admin interface:

```
- name: ADMIN_TOKEN
  value: "your_custom_admin_token"

```

&nbsp;3. **Storage Path**: Update the `hostPath` for persistent storage. This directory will be used to store Vaultwarden data such as the database and attachments:

```
hostPath:
  path: /home/k8server/bitwarden  # Replace with your desired path

```

4. **Whitelisted Signup Domains**: If you want to limit signups to specific email domains, customize the `SIGNUPS_DOMAINS_WHITELIST` value:

```
- name: SIGNUPS_DOMAINS_WHITELIST
  value: "user1@gmail.com,user2@gmail.com"

```

5. **LoadBalancer IP**: If you are using **MetalLB** in a local environment, configure the `loadBalancerIP` with a static IP from the MetalLB pool:

```
loadBalancerIP: 192.168.1.247  # Update this with an available IP address from your environment

```

### Step 3: Apply the Configuration

Once you have customized the configuration, deploy Vaultwarden using `kubectl`:

```
kubectl apply -f vaultwarden-deployment.yaml

```

### Step 4: Verify the Deployment

Check the status of the Vaultwarden pod:

```
kubectl get pods

```

You should see a pod named `vaultwarden` in the `Running` state.

To check the external IP assigned by MetalLB (or your load balancer), use the following command:

```
kubectl get svc vaultwarden

```

Access your Vaultwarden instance via the external IP or domain at `http://<EXTERNAL-IP>:8084`.

### Step 5: Access the Admin Interface

To access the admin panel, navigate to the following URL and use the **admin token** configured in the environment variables:

```
http://<EXTERNAL-IP>:8084/admin

```

## Customization

### Environment Variables

- **DOMAIN**: The URL where Vaultwarden will be hosted (e.g., `https://your-vaultwarden-domain.com`).
- **ADMIN_TOKEN**: A custom token that you must set to access the admin panel.
- **LOGIN_RATELIMIT_MAX_BURST / SECONDS**: Customize the rate limiting behavior for login attempts.
- **SIGNUPS_ALLOWED**: Set to `false` to disable user signups. Set to `true` to allow public signups.
- **SIGNUPS_DOMAINS_WHITELIST**: Limit signups to specific email domains by adding them here.

### Volume Mount

- **Persistent Volume**: The Vaultwarden instance uses a hostPath to store its data. Ensure that the directory specified in the `hostPath` exists on the node and has the appropriate permissions.

If you want to use a different storage class (e.g., NFS or cloud-based persistent volumes), modify the `volume` section accordingly.

### Scaling

The current configuration is set to run a single replica of Vaultwarden (`replicas: 1`). If you want to scale it, adjust the `replicas` field in the `Deployment` spec:

```
replicas: 3  # Example for 3 replicas

```

Ensure that your persistent storage is shared (e.g., NFS, or cloud storage) when scaling across multiple replicas.

## Troubleshooting

- **Pod not starting?** Check the logs to see if there are any errors:

```
kubectl logs <vaultwarden-pod-name>

```

- **Data not being saved?** Ensure that the `hostPath` directory exists on the Kubernetes node and has appropriate write permissions.

```
sudo chmod 777 /PATH/TO/bitwarden

```

- **Service not accessible?** Verify that the external IP is assigned and that the port `8084` is open in your environment. Also, ensure that MetalLB (or your Load Balancer) is correctly configured.
