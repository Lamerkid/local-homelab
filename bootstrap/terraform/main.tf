################## Define pool ##################

resource "libvirt_pool" "storage" {
  name = local.pool.name
  type = local.pool.type
  target = {
    path = local.pool.target
  }
}

################## Define base image ##################

resource "libvirt_volume" "base_image" {
  name = "ubuntu24-base.qcow2"
  pool = libvirt_pool.storage.name

  target = {
    format = {
      type = "qcow2"
    }
  }

  create = {
    content = {
      url = local.base_image_path
    }
  }
}

################## Define network ##################

resource "libvirt_network" "homelab" {
  name      = local.network.name
  autostart = true
  forward = {
    mode = local.network.mode
    nat = {
      ports = [
        {
          start = 1024
          end   = 65535
        }
      ]
    }
  }
  bridge = {
    name  = local.network.bridge
    stp   = "on"
    delay = "0"
  }
  domain = {
    name = local.network.domain
  }
  ips = [
    {
      address = local.network.address
      prefix  = local.network.prefix
      dhcp = {
        ranges = [
          {
            start = local.network.range_start
            end   = local.network.range_end
          }
        ]
      }
    }
  ]
}
