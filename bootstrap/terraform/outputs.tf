output "storage_pool_name" {
  description = "Name of the storage pool"
  value       = libvirt_pool.storage.name
}

output "storage_pool_path" {
  description = "Path to the storage pool"
  value       = libvirt_pool.storage.target
}

output "base_image_path" {
  description = "Path to the base image"
  value       = libvirt_volume.base_image.path
}

output "network_name" {
  description = "Name of the network"
  value       = libvirt_network.homelab.name
}

output "network_bridge" {
  description = "Bridge interface name"
  value       = libvirt_network.homelab.bridge
}
