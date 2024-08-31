#!/bin/bash

# Function to update and upgrade the system
update_system() {
    if [ -f /etc/debian_version ]; then
        echo "Updating system for Debian/Ubuntu..."
        sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
    elif [ -f /etc/redhat-release ] || [ -f /etc/fedora-release ]; then
        echo "Updating system for RHEL/Fedora/AlmaLinux..."
        sudo dnf update && sudo dnf upgrade -y && sudo dnf autoremove -y
    else
        echo "Unsupported OS"
        exit 1
    fi
}

# Function to configure the firewall
configure_firewall() {
    if [ -f /etc/redhat-release ] || [ -f /etc/fedora-release ]; then
        echo "Configuring firewall for RHEL/Fedora/AlmaLinux..."
        sudo firewall-cmd --add-port=6443/tcp --permanent
        sudo firewall-cmd --reload
    elif [ -f /etc/debian_version ]; then
        echo "Configuring firewall for Debian/Ubuntu..."
        sudo ufw allow 6443/tcp
        sudo ufw reload
    else
        echo "Unsupported OS"
        exit 1
    fi
}

# Function to install K3s
install_k3s() {
    echo "Installing K3s..."
    curl -sfL https://get.k3s.io | sh -
}

# Function to configure kubectl
configure_kubectl() {
    echo "Configuring kubectl..."
    sudo chmod 644 /etc/rancher/k3s/k3s.yaml
    sudo chown $(id -u):$(id -g) /etc/rancher/k3s/k3s.yaml

    mkdir -p $HOME/.kube
    sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

# Function to check K3s installation
check_k3s_status() {
    echo "Checking K3s status..."
    sudo systemctl status k3s
}

# Main function
main() {
    update_system
    configure_firewall
    install_k3s
    configure_kubectl
    check_k3s_status
}

# Run the main function
main
