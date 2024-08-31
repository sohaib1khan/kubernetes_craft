# Setting Up K3s

This guide provides detailed steps to set up K3s on a Fedora system. It includes instructions for ensuring your system is up to date, configuring SSH and firewall settings, installing K3s, and configuring `kubectl` for managing your Kubernetes cluster.

## Prerequisites

- A Fedora OS installation.
- Basic knowledge of Linux command line.
- Internet connection for downloading packages and scripts.

## Step 1: Update Your System

Before installing any new software, it's essential to ensure your Fedora system is up to date. This can be done using the following commands:

```
sudo dnf update && sudo dnf upgrade -y && sudo dnf autoremove -y

```

This command will update all installed packages to the latest version and remove any unnecessary packages.

## Step 2: Configure SSH (Optional)

If you plan to manage your Fedora machine remotely via SSH, ensure that SSH is configured and running. By default, Fedora may already have SSH installed. You can check its status and enable it if necessary:

```
sudo systemctl enable sshd
sudo systemctl start sshd

```

Make sure that port 22 (or any other port you're using for SSH) is open in the firewall if you want to access the machine from outside your local network.

## Step 3: Check Firewall Rules

To ensure that your k3s server can be accessed, you need to check and configure the firewall settings.

### Allow Traffic on Port 6443

Port `6443` is used by K3s for the Kubernetes API server. You'll need to ensure that this port is open in your firewall:

#### For firewalld:

```
sudo firewall-cmd --add-port=6443/tcp --permanent
sudo firewall-cmd --reload

```

This will permanently open port 6443 and reload the firewall to apply the changes.

## Step 4: Install K3s

K3s provides a convenient installation script that installs it as a service on systemd-based systems like Fedora.

### Install Script

Run the following command to download and install K3s:

```
curl -sfL https://get.k3s.io | sh -

```

This script will:

- Download and install the K3s binary along with its dependencies.
- Configure the K3s service to automatically restart after a node reboot or if the process crashes or is killed.
- Install additional utilities including `kubectl`, `crictl`, `ctr`, `k3s-killall.sh`, and `k3s-uninstall.sh`.
- Write a [kubeconfig](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) file to `/etc/rancher/k3s/k3s.yaml`.

### Verify Installation

After the installation is complete, check the status of the K3s service to ensure it is running correctly:

```
sudo systemctl status k3s

```

If K3s is running properly, you should see that the service is active.

## Step 5: Configure kubectl

By default, `kubectl` is available via `sudo k3s kubectl`. To make it accessible without needing `sudo`, you can configure it as follows:

```
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
sudo chown $(id -u):$(id -g) /etc/rancher/k3s/k3s.yaml

mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

```

This configuration allows you to use `kubectl` commands directly from your user account without needing elevated permissions.

```
[microserver@microserver ~]$ kubectl get nodes
NAME          STATUS   ROLES                  AGE   VERSION
microserver   Ready    control-plane,master   47m   v1.30.4+k3s1
[microserver@microserver ~]$ kubectl get pods -A | grep svclb
kube-system   svclb-traefik-37974bbd-m6jvh              2/2     Running     2 (36m ago)   47m

```

&nbsp;

## Conclusion

You have now successfully set up K3s on your Fedora system. You can manage your Kubernetes cluster using `kubectl` and start deploying applications. If you encounter any issues, refer to the K3s documentation or the Fedora support community for assistance.
