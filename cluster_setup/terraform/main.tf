locals {
  vm_ips = {
    "k8s-master"  = "192.168.1.60"
    "k8s-worker1" = "192.168.1.61"
    "k8s-worker2" = "192.168.1.62"
    "k8s-worker3" = "192.168.1.63"
  }
}

resource "proxmox_vm_qemu" "vm_instance" {
  count       = 4
  name        = count.index == 0 ? "k8s-master" : "k8s-worker${count.index}"
  target_node = "pve"
  clone       = "ubuntutemplate20"

  os_type    = "cloud-init"
  cores      = 3
  sockets    = 1
  memory     = 8048
  ciuser     = count.index == 0 ? var.master_user : var.worker_user
  cipassword = count.index == 0 ? var.master_password : var.worker_password

  disk {
    type    = "virtio"
    storage = "S1"
    size    = "50G"
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  ipconfig0 = "gw=192.168.1.1,ip=192.168.1.${60 + count.index}/24"

  sshkeys = <<-EOF
    ${file(var.ssh_public_key)}
  EOF


}

output "vm_ip_addresses" {
  value = [for name, ip in local.vm_ips : ip]
}

output "ciuser_output" {
  value       = var.master_user
  description = "Output the VM user name for master"
}

output "ciuser2_output" {
  value       = var.worker_user
  description = "Output the VM user name for worker"
}
