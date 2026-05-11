data "libvirt_domain_interface_addresses" "vm" {
  for_each = local.all_vms

  domain = libvirt_domain.vm[each.key].name
  source = "lease"

  depends_on = [libvirt_domain.vm]
}

output "vm_ips" {
  value = {
    for name, vm in libvirt_domain.vm :
    name => data.libvirt_domain_interface_addresses.vm[name].interfaces[0].addrs[0].addr
  }
}

output "master_ips" {
  value = {
    for name, vm in libvirt_domain.vm :
    name => data.libvirt_domain_interface_addresses.vm[name].interfaces[0].addrs[0].addr
    if contains(keys(local.masters), name)
  }
}

output "worker_ips" {
  value = {
    for name, vm in libvirt_domain.vm :
    name => data.libvirt_domain_interface_addresses.vm[name].interfaces[0].addrs[0].addr
    if contains(keys(local.workers), name)
  }
}

output "lb_ip" {
  value = {
    for name, vm in libvirt_domain.vm :
    name => data.libvirt_domain_interface_addresses.vm[name].interfaces[0].addrs[0].addr
    if contains(keys(local.load_balancer), name)
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory/hosts.ini"
  content = templatefile("${path.module}/templates/inventory.tpl", {
    vms     = data.libvirt_domain_interface_addresses.vm
    masters = { for k, v in local.masters : k => v }
    workers = { for k, v in local.workers : k => v }
    lb      = { for k, v in local.load_balancer : k => v }
    ssh     = var.private_ssh
  })
}
