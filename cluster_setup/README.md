# Kubernetes Cluster Setup

This folder contains the essential files and scripts to set up a Kubernetes cluster using Ansible and Terraform. It's organized to provide a smooth workflow from provisioning infrastructure to installing and configuring Kubernetes components.

## Structure

### Ansible

The `ansible` directory contains the Ansible playbooks and scripts to configure the nodes and set up the Kubernetes cluster.

- `bin/`: Contains various shell scripts to initialize the Kubernetes master, install necessary components, set up networking, and more.
- `cleanup_knownhosts`: A utility to clean known hosts (useful for repeated deployments).
- `hosts.ini`: Ansible inventory file defining the nodes.
- `reboot.yaml`: Ansible playbook for rebooting nodes.
- `setup_k8s_cluster.yml`: The main Ansible playbook to set up the Kubernetes cluster.

### Terraform

The `terraform` directory houses the Terraform configuration files.

- `main.tf`: Main Terraform configuration file.
- `providers.tf`: Configuration for Terraform providers.
- `variables.tf`: Terraform variables and their default values.

## Usage

1. Start by provisioning the required infrastructure using the Terraform scripts.
2. Once the infrastructure is ready, utilize the Ansible playbooks and scripts to set up and configure the Kubernetes cluster.

For specific instructions on how to use each script or playbook, refer to their respective headers or documentation.

---

This is a high-level overview. Depending on the complexity of the scripts and configurations, more detailed documentation might be necessary. But overall its a straightforward setup.
