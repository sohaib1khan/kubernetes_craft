variable "pm_user" {
  description = "Proxmox username"
  type        = string
}

variable "pm_password" {
  description = "Proxmox password (or API token)"
  type        = string
  sensitive   = true
}

variable "master_user" {
  description = "Master node user"
  type        = string
}

variable "master_password" {
  description = "Master node password"
  type        = string
  sensitive   = true
}

variable "worker_user" {
  description = "Worker node user"
  type        = string
}

variable "worker_password" {
  description = "Worker node password"
  type        = string
  sensitive   = true
}
