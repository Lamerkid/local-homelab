################## Load config ##################

locals {
  config   = yamldecode(file("${path.module}/../cluster-config.yaml"))
  defaults = lookup(local.config, "defaults", {})

  nodes = {
    for name, node in local.config.nodes : name => merge(local.defaults, node)
  }

  ssh_public_key  = lookup(local.config.local, "ssh_public_key_path")
  ssh_private_key = lookup(local.config.local, "ssh_private_key_path")
}

################## Read bootstrap output ##################

data "terraform_remote_state" "bootstrap" {
  backend = "local"
  config = {
    path = "../../bootstrap/terraform/terraform.tfstate"
  }
}

