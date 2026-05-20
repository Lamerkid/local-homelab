locals {
  config = yamldecode(file("${path.module}/../bootstrap-config.yaml"))

  pool = {
    name   = local.config.pool.name
    type   = local.config.pool.type
    target = local.config.pool.target
  }

  base_image_path = local.config.base_image.path

  network = {
    name        = local.config.network.name
    mode        = local.config.network.mode
    bridge      = local.config.network.bridge
    domain      = local.config.network.domain
    address     = local.config.network.address
    prefix      = local.config.network.prefix
    range_start = local.config.network.range_start
    range_end   = local.config.network.range_end
  }
}
