data "libvirt_domain_interface_addresses" "vm" {
  domain = libvirt_domain.vm.name
  source = "lease"

  depends_on = [libvirt_domain.vm]
}

output "vm_ip" {
  value = data.libvirt_domain_interface_addresses.vm.interfaces[0].addrs[0].addr
}

output "vm_name" {
  description = "Name of the VM"
  value       = libvirt_domain.vm.name
}
