variable "ssh" {
  description = "SSH key for VMs configuration"
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_ssh" {
  description = "SSH key for accessing VMs"
  default     = "~/.ssh/id_rsa"
}

variable "base_image_path" {
  description = "Path where the base cloud image is located"
  default     = "/var/lib/libvirt/images/base-ubuntu22.qcow2"
}

variable "network" {
  description = "Network configuration"
  default = {
    "network" = {
      name        = "homelab"
      mode        = "nat"
      bridge      = "virbr2"
      domain      = "homelab.local"
      address     = "10.0.0.1"
      prefix      = "24"
      range_start = "10.0.0.10"
      range_end   = "10.0.0.30"
    }
  }
}

variable "load_balancer" {
  description = "Enable HAProxy load balancer for multi-master clusters"
  default = {
    "lb" = {
      memory    = 512
      vcpu      = 1
      disk_size = 10 * 1024 * 1024 * 1024
    }
  }
}

variable "vms" {
  description = "VM configurations"
  default = {
    "masters" = {
      count     = 1
      memory    = 2048
      vcpu      = 2
      disk_size = 10 * 1024 * 1024 * 1024
    }
    "workers" = {
      count     = 1
      memory    = 2048
      vcpu      = 2
      disk_size = 10 * 1024 * 1024 * 1024
    }
  }
}


