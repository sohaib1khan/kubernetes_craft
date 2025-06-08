# WireGuard VPN with wg-easy on Kubernetes

A complete Kubernetes deployment for WireGuard VPN server using wg-easy web interface. This template provides an easy-to-manage VPN solution with persistent storage and MetalLB load balancer integration.

## 🌟 Features

- **wg-easy Web UI** - Easy client management with QR codes
- **Persistent Storage** - Host path storage for configuration persistence
- **MetalLB Integration** - LoadBalancer service with static IP assignment
- **Ready-to-Deploy** - Single YAML file deployment
- **Production Ready** - Resource limits, security contexts, and proper volumes

## 📋 Prerequisites

### Required Components
- **Kubernetes Cluster** (K3s, K8s, etc.)
- **MetalLB** - For LoadBalancer services
- **Host Directory** - For persistent volume storage
- **WireGuard Kernel Module** - Available in Linux kernel 5.6+

### System Requirements
- Kubernetes 1.19+
- Linux host with WireGuard support
- Available IP range in MetalLB pool

### Check Prerequisites
```bash
# Verify Kubernetes
kubectl version --short

# Verify MetalLB
kubectl get pods -n metallb-system

# Check WireGuard kernel module
lsmod | grep wireguard
# or
modinfo wireguard

# Check kernel version (5.6+ includes WireGuard)
uname -r
```

## 🚀 Quick Deployment

### 1. Prepare Host Directory
```bash
# Create directory for persistent storage
sudo mkdir -p /home/k8server/wireguard
sudo chown -R $(whoami):$(whoami) /home/k8server/wireguard

# Verify permissions
ls -la /home/k8server/wireguard
```

### 2. Configure IP Address
Edit the deployment file and set your desired IP address:

```yaml
# In Service section
annotations:
  metallb.universe.tf/loadBalancer-IPs: 192.168.1.XXX  # Your desired IP

# In Deployment section  
- name: WG_HOST
  value: "192.168.1.XXX"  # Same IP as above
```

**Note**: If you don't specify a static IP, MetalLB will assign one automatically. Make sure to update `WG_HOST` to match the assigned IP.

### 3. Deploy to Kubernetes
```bash
# Apply the deployment
kubectl apply -f wireguard-deployment.yaml

# Verify deployment
kubectl get all -n wireguard
kubectl get pv,pvc -n wireguard
```

### 4. Check Service Status
```bash
# Get assigned LoadBalancer IP
kubectl get svc -n wireguard
# Note the EXTERNAL-IP value

# If IP differs from your WG_HOST setting, update it:
kubectl patch deployment wireguard-deployment -n wireguard -p '{"spec":{"template":{"spec":{"containers":[{"name":"wg-easy","env":[{"name":"WG_HOST","value":"192.168.1.XXX"}]}]}}}}'
```

### 5. Access Web UI
```bash
# Get the external IP
EXTERNAL_IP=$(kubectl get svc wireguard-service -n wireguard -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Access WireGuard UI at: http://$EXTERNAL_IP:51821"

# Open in browser
# http://EXTERNAL_IP:51821
```

## ⚙️ Configuration Options

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `WG_HOST` | - | **Required**: Server IP/domain for client configs |
| `WG_PORT` | `51820` | WireGuard UDP port |
| `WG_DEFAULT_ADDRESS` | `10.8.0.x` | Internal VPN subnet |
| `WG_DEFAULT_DNS` | `1.1.1.1,1.0.0.1` | DNS servers for clients |
| `WG_ALLOWED_IPS` | `0.0.0.0/0` | Traffic routing (0.0.0.0/0 = all traffic) |
| `WG_PERSISTENT_KEEPALIVE` | `25` | Keepalive interval in seconds |
| `INSECURE` | `true` | Allow HTTP access (set false for production) |
| `PASSWORD` | - | Optional: Pre-set admin password |

### Resource Configuration
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Storage Configuration
- **Path**: `/home/k8server/wireguard`
- **Size**: `1Gi` (adjustable)
- **Type**: `hostPath` with `DirectoryOrCreate`

## 🎯 Initial Setup

### First Time Access
1. Open web browser to `http://EXTERNAL_IP:51821`
2. Complete the setup wizard:
   - Click "Continue"
   - Create admin username and password (min 12 characters)
   - Configure server settings
   - Click "Sign In"

### Creating VPN Clients
1. Click **"+ New Client"**
2. Enter client name
3. Set expiration date (optional)
4. Click **"Create Client"**
5. Download `.conf` file or scan QR code

## 📱 Client Setup

### Desktop (Windows/Linux/macOS)
1. Download WireGuard client from [wireguard.com](https://www.wireguard.com/install/)
2. Import the `.conf` file downloaded from web UI
3. Activate the tunnel

### Mobile (iOS/Android)
1. Install WireGuard app from App Store/Play Store
2. Scan QR code from wg-easy web interface
3. Activate the tunnel

### Linux with NetworkManager
```bash
# Import configuration
nmcli connection import type wireguard file client.conf

# Connect
nmcli connection up client-name
```

## 🔧 Management Commands

### Check Deployment Status
```bash
# Get all resources
kubectl get all -n wireguard

# Check pod logs
kubectl logs -f deployment/wireguard-deployment -n wireguard

# Check persistent volumes
kubectl get pv,pvc -n wireguard

# Check service and IP
kubectl get svc -n wireguard -o wide
```

### Update Configuration
```bash
# Update WG_HOST (if IP changes)
kubectl patch deployment wireguard-deployment -n wireguard -p '{"spec":{"template":{"spec":{"containers":[{"name":"wg-easy","env":[{"name":"WG_HOST","value":"NEW_IP_HERE"}]}]}}}}'

# Update resource limits
kubectl patch deployment wireguard-deployment -n wireguard -p '{"spec":{"template":{"spec":{"containers":[{"name":"wg-easy","resources":{"limits":{"memory":"1Gi","cpu":"1000m"}}}]}}}}'

# Scale deployment (not recommended for VPN)
kubectl scale deployment wireguard-deployment -n wireguard --replicas=1
```

### Backup and Restore
```bash
# Backup configuration
sudo tar -czf wireguard-backup-$(date +%Y%m%d).tar.gz /home/k8server/wireguard/

# View backup contents
tar -tzf wireguard-backup-*.tar.gz

# Restore (stop deployment first)
kubectl scale deployment wireguard-deployment -n wireguard --replicas=0
sudo tar -xzf wireguard-backup-*.tar.gz -C /
kubectl scale deployment wireguard-deployment -n wireguard --replicas=1
```

## 🛠️ Troubleshooting

### Common Issues

#### Pod Won't Start
```bash
# Check pod status and events
kubectl describe pod -n wireguard -l app=wireguard

# Check logs
kubectl logs -n wireguard -l app=wireguard

# Common causes:
# - Missing WireGuard kernel module
# - Insufficient permissions
# - Storage issues
```

#### Can't Access Web UI
```bash
# Check service
kubectl get svc -n wireguard

# Test connectivity
curl -I http://EXTERNAL_IP:51821

# Check if port is open in container
kubectl exec -n wireguard deployment/wireguard-deployment -- netstat -tlnp

# Port forward as alternative
kubectl port-forward -n wireguard svc/wireguard-service 8080:51821
# Then access: http://localhost:8080
```

#### MetalLB IP Issues
```bash
# Check MetalLB logs
kubectl logs -n metallb-system -l app=metallb

# Check IP pool configuration
kubectl get ipaddresspool -n metallb-system
kubectl get configmap -n metallb-system

# Verify IP not in use
kubectl get svc -A | grep YOUR_DESIRED_IP
```

#### Storage Problems
```bash
# Check PV/PVC status
kubectl get pv,pvc -n wireguard

# Check host directory permissions
sudo ls -la /home/k8server/wireguard/
sudo chown -R $(whoami):$(whoami) /home/k8server/wireguard/

# Check available disk space
df -h /home/k8server/
```

### Advanced Debugging
```bash
# Exec into container
kubectl exec -it -n wireguard deployment/wireguard-deployment -- /bin/bash

# Check WireGuard interface inside container
wg show

# Check environment variables
env | grep WG_

# Check file permissions
ls -la /etc/wireguard/
```

## 🔒 Security Considerations

### Production Checklist
- [ ] Set `INSECURE: "false"` and use HTTPS reverse proxy
- [ ] Restrict web UI access to trusted networks only
- [ ] Use strong admin passwords (12+ characters)
- [ ] Regular backup of configurations
- [ ] Monitor client connections
- [ ] Keep wg-easy image updated

### Firewall Configuration
```bash
# Allow WireGuard VPN traffic (UDP 51820)
# This port must be open on your router/firewall

# Restrict web UI access (TCP 51821) to trusted IPs only
# Example: Only allow access from management network
```

### Network Security
- Use strong client names and manage expiration dates
- Regularly review connected clients
- Monitor unusual traffic patterns
- Consider split-tunneling vs full-tunneling based on needs

## 📊 Monitoring

### Check Connected Clients
```bash
# View via web UI (recommended)
# Access http://EXTERNAL_IP:51821

# Via command line
kubectl exec -n wireguard deployment/wireguard-deployment -- wg show
```

### Resource Monitoring
```bash
# Check resource usage
kubectl top pod -n wireguard

# Check logs for connection events
kubectl logs -n wireguard deployment/wireguard-deployment | grep -i client
```

## 🔄 Updates and Maintenance

### Update wg-easy Image
```bash
# Update to latest version
kubectl set image deployment/wireguard-deployment -n wireguard wg-easy=ghcr.io/wg-easy/wg-easy:latest

# Check rollout status
kubectl rollout status deployment/wireguard-deployment -n wireguard

# Rollback if needed
kubectl rollout undo deployment/wireguard-deployment -n wireguard
```

### Cleanup
```bash
# Remove deployment but keep data
kubectl delete -f wireguard-deployment.yaml
# PV with 'Retain' policy will keep your data

# Complete cleanup (removes data)
kubectl delete namespace wireguard
kubectl delete pv wireguard-pv
sudo rm -rf /home/k8server/wireguard/
```

## 📝 Customization Template

### For Different Environments
```yaml
# Development
WG_DEFAULT_ADDRESS: "10.8.0.x"    # Dev network
metallb.universe.tf/loadBalancer-IPs: 192.168.1.240

# Staging  
WG_DEFAULT_ADDRESS: "10.9.0.x"    # Staging network
metallb.universe.tf/loadBalancer-IPs: 192.168.1.241

# Production
WG_DEFAULT_ADDRESS: "10.10.0.x"   # Prod network
metallb.universe.tf/loadBalancer-IPs: 192.168.1.242
INSECURE: "false"                  # Require HTTPS
```

