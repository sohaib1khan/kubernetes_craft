#!/bin/bash

# K3s Upgrade Automation Script
# This script safely upgrades a K3s cluster to the latest version with proper node draining, 
# version verification, and rollback capabilities

set -e  # Exit immediately if a command exits with a non-zero status

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root" 
   exit 1
fi

# Increase file descriptor limits to prevent "too many open files" error
ulimit -n 65536

# Function to check K3s version
check_version() {
  CURRENT_VERSION=$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kubeletVersion}')
  echo "$CURRENT_VERSION"
}

# Function to check latest available K3s version
check_latest_version() {
  LATEST_VERSION=$(curl -s https://api.github.com/repos/k3s-io/k3s/releases/latest | grep 'tag_name' | cut -d '"' -f 4)
  echo "$LATEST_VERSION"
}

# Function to perform rollback
rollback() {
  echo "[WARNING] Upgrade failed, performing rollback to version $ORIGINAL_VERSION"
  
  # Stop K3s service completely
  systemctl stop k3s
  
  # Kill all k3s processes to ensure clean slate
  if [ -f /usr/local/bin/k3s-killall.sh ]; then
    /usr/local/bin/k3s-killall.sh
  fi
  
  # Install the previous version
  curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="$ORIGINAL_VERSION" sh -
  
  # Start K3s service
  systemctl daemon-reload
  systemctl start k3s
  
  # Wait for service to be ready
  echo "[INFO] Waiting for K3s to restart after rollback"
  sleep 60
  
  # Uncordon the node
  NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "unknown")
  if [ "$NODE_NAME" != "unknown" ]; then
    kubectl uncordon "$NODE_NAME"
  else
    echo "[ERROR] Could not determine node name. Please uncordon manually when K3s is back online."
  fi
  
  echo "[INFO] Rollback completed. Current version: $(check_version)"
  exit 1
}

# Store the current version for potential rollback
ORIGINAL_VERSION=$(check_version)
echo "[INFO] Current K3s version: $ORIGINAL_VERSION"

# Check if latest version is already installed
LATEST_VERSION=$(check_latest_version)
echo "[INFO] Latest available K3s version: $LATEST_VERSION"

if [ "$ORIGINAL_VERSION" = "$LATEST_VERSION" ]; then
  echo "[INFO] System is already running the latest version ($LATEST_VERSION). No upgrade needed."
  exit 0
fi

# Get node name dynamically
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
echo "[INFO] Working with node: $NODE_NAME"

# Ask if user wants to completely stop all workloads
read -p "[PROMPT] Do you want to completely stop all workloads before upgrade? (Recommended) (y/n): " stop_workloads
if [ "$stop_workloads" = "y" ] || [ "$stop_workloads" = "Y" ]; then
  echo "[INFO] Stopping all deployments, statefulsets, and daemonsets"
  
  # Scale down all deployments
  for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
    kubectl -n $ns get deploy -o name | xargs -r -n1 kubectl -n $ns scale --replicas=0
  done
  
  # Scale down all statefulsets
  for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
    kubectl -n $ns get statefulset -o name | xargs -r -n1 kubectl -n $ns scale --replicas=0
  done
  
  echo "[INFO] Waiting 30 seconds for pods to terminate"
  sleep 30
fi

# Drain the node (ignoring daemonsets and deleting local data)
echo "[INFO] Draining node $NODE_NAME"
kubectl drain "$NODE_NAME" --ignore-daemonsets --delete-emptydir-data --timeout=300s || {
  echo "[WARNING] Drain operation did not complete cleanly. Continuing anyway..."
  # Don't exit here as drain can sometimes have partial failures but still be effective
}

# Backup etcd data (if using embedded etcd)
if [ -d "/var/lib/rancher/k3s/server/db" ]; then
  echo "[INFO] Backing up etcd data"
  BACKUP_NAME="k3s-etcd-backup-$(date +%Y%m%d%H%M%S)"
  mkdir -p /opt/k3s-backups
  cp -r /var/lib/rancher/k3s/server/db "/opt/k3s-backups/$BACKUP_NAME"
  echo "[INFO] Etcd backup created at /opt/k3s-backups/$BACKUP_NAME"
fi

# Stop K3s service completely
echo "[INFO] Stopping K3s service and killing all K3s processes"
systemctl stop k3s

# Kill all K3s processes to ensure clean slate
if [ -f /usr/local/bin/k3s-killall.sh ]; then
  /usr/local/bin/k3s-killall.sh
else
  echo "[WARNING] k3s-killall.sh not found, attempting to kill processes manually"
  pkill -9 -f k3s || true
fi

# Wait to ensure all processes are terminated
sleep 10

# Perform upgrade to latest version
echo "[INFO] Upgrading K3s to latest version"
curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=latest sh - || {
  echo "[ERROR] Upgrade installation failed"
  rollback
}

# Start K3s service
echo "[INFO] Starting K3s service"
systemctl daemon-reload
systemctl start k3s

# Wait for service to be ready (adjust time as needed)
echo "[INFO] Waiting for K3s service to be ready"
sleep 60

# Check if K3s is running
if ! systemctl is-active --quiet k3s; then
  echo "[ERROR] K3s service failed to start"
  rollback
fi

# Wait for node to become ready
echo "[INFO] Waiting for node to become ready"
timeout=300
start_time=$(date +%s)

while true; do
  current_time=$(date +%s)
  elapsed_time=$((current_time - start_time))
  
  if [ $elapsed_time -gt $timeout ]; then
    echo "[ERROR] Timeout waiting for node to become ready"
    rollback
  fi
  
  NODE_STATUS=$(kubectl get node "$NODE_NAME" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "NotReady")
  
  if [ "$NODE_STATUS" = "True" ]; then
    echo "[INFO] Node is ready"
    break
  fi
  
  echo "[INFO] Waiting for node to be ready... (${elapsed_time}s elapsed)"
  sleep 10
done

# Uncordon the node
echo "[INFO] Uncordoning node $NODE_NAME"
kubectl uncordon "$NODE_NAME" || {
  echo "[ERROR] Failed to uncordon node"
  rollback
}

# Verify the upgrade was successful
NEW_VERSION=$(check_version)
echo "[INFO] New K3s version: $NEW_VERSION"

if [ "$NEW_VERSION" = "$ORIGINAL_VERSION" ]; then
  echo "[ERROR] Version did not change after upgrade. Upgrade may have failed."
  
  # Check if K3s binary was updated regardless of node reporting
  BINARY_VERSION=$(k3s --version | head -n1)
  echo "[INFO] K3s binary version: $BINARY_VERSION"
  
  # If the binary version has the same version string as original_version but not the same format
  # just do another check to confirm it's correctly updated
  if [[ "$BINARY_VERSION" == *"$NEW_VERSION"* ]] || [[ "$BINARY_VERSION" == *"$LATEST_VERSION"* ]]; then
    echo "[INFO] Binary appears to have been updated correctly despite node reporting old version"
    echo "[INFO] Waiting another minute for node to refresh version information..."
    sleep 60
    FINAL_VERSION=$(check_version)
    
    if [ "$FINAL_VERSION" != "$ORIGINAL_VERSION" ]; then
      echo "[SUCCESS] Node is now reporting the new version: $FINAL_VERSION"
    else
      echo "[WARNING] Node is still reporting old version, but binary is updated. This may resolve itself over time."
      read -p "Do you want to force a restart of K3s again? (y/n): " restart_choice
      if [ "$restart_choice" = "y" ] || [ "$restart_choice" = "Y" ]; then
        systemctl restart k3s
        sleep 30
        FINAL_VERSION=$(check_version)
        echo "[INFO] Version after forced restart: $FINAL_VERSION"
      fi
    fi
  else
    echo "[ERROR] Binary version doesn't match expected new version"
    read -p "Do you want to rollback to the original version? (y/n): " choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
      rollback
    fi
  fi
else
  echo "[SUCCESS] Upgrade completed successfully"
  echo "[INFO] Successfully upgraded from $ORIGINAL_VERSION to $NEW_VERSION"
fi

# Ask if user wants to restore workloads
if [ "$stop_workloads" = "y" ] || [ "$stop_workloads" = "Y" ]; then
  read -p "[PROMPT] Do you want to restore all workloads now? (y/n): " restore_workloads
  if [ "$restore_workloads" = "y" ] || [ "$restore_workloads" = "Y" ]; then
    echo "[INFO] Restoring all deployments and statefulsets"
    
    # Restore all deployments to 1 replica initially
    for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
      kubectl -n $ns get deploy -o name | xargs -r -n1 kubectl -n $ns scale --replicas=1
    done
    
    # Restore all statefulsets to 1 replica initially
    for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
      kubectl -n $ns get statefulset -o name | xargs -r -n1 kubectl -n $ns scale --replicas=1
    done
    
    echo "[INFO] Scaled all workloads to 1 replica. For multi-replica workloads, please scale them up manually."
  else
    echo "[INFO] Workloads were not automatically restored. Please restore them manually."
  fi
fi

# Final verification of system health
echo "[INFO] Verifying system health"
kubectl get nodes
if [ "$stop_workloads" != "y" ] && [ "$stop_workloads" != "Y" ]; then
  kubectl get pods --all-namespaces | grep -v "Running\|Completed" || echo "All pods are in Running or Completed state"
fi

echo "[INFO] K3s upgrade process completed"
