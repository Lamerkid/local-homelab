variable "user_name" {
  description = "User for configuration"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "Location of ssh public key"
  type        = string
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "memory" {
  description = "RAM in MB"
  type        = number
  default     = 2048
}

variable "vcpu" {
  description = "CPU cores"
  type        = number
  default     = 2
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 10
}

variable "storage_pool" {
  description = "Storage pool name"
  type        = string
}

variable "base_image" {
  description = "Path to base image"
  type        = string
}

variable "network_name" {
  description = "Network name"
  type        = string
}
