data "libvirt_domain_interface_addresses" "vm" {
  for_each = local.nodes

  domain = module.vm[each.key].vm_name
  source = "lease"

  depends_on = [module.vm]
}

output "vm_ips" {
  value = {
    for name, vm in module.vm :
    name => data.libvirt_domain_interface_addresses.vm[name].interfaces[0].addrs[0].addr
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory/hosts.ini"
  content = templatefile("${path.module}/templates/inventory.tpl", {
    vms   = data.libvirt_domain_interface_addresses.vm
    nodes = local.nodes
    ssh   = local.ssh_private_key
  })
}
