module "vm" {
  for_each = local.nodes

  source = "${path.module}/modules/vm"

  ssh_public_key = local.ssh_public_key
  user_name      = each.value.user
  vm_name        = each.value.hostname
  memory         = each.value.memory
  vcpu           = each.value.vcpu
  disk_size      = each.value.disk
  storage_pool   = data.terraform_remote_state.bootstrap.outputs.storage_pool_name
  base_image     = data.terraform_remote_state.bootstrap.outputs.base_image_path
  network_name   = data.terraform_remote_state.bootstrap.outputs.network_name
}
