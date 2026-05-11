################## Define network ##################

resource "libvirt_network" "homelab" {
  name      = var.network["network"]["name"]
  autostart = true
  forward = {
    mode = var.network["network"]["mode"]
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
    name  = var.network["network"]["bridge"]
    stp   = "on"
    delay = "0"
  }
  domain = {
    name = var.network["network"]["domain"]
  }
  ips = [
    {
      address = var.network["network"]["address"]
      prefix  = var.network["network"]["prefix"]
      dhcp = {
        ranges = [
          {
            start = var.network["network"]["range_start"]
            end   = var.network["network"]["range_end"]
          }
        ]
      }
    }
  ]
}

################## Define locals for k8s nodes ##################

locals {
  # Generate master configurations dynamically
  masters = {
    for i in range(var.vms["masters"]["count"]) :
    "master-${i + 1}" => {
      hostname = "k8s-master-${i + 1}"
      memory   = var.vms["masters"]["memory"]
      vcpu     = var.vms["masters"]["vcpu"]
      disk     = var.vms["masters"]["disk_size"]
    }
  }

  # Generate worker configurations dynamically
  workers = {
    for i in range(var.vms["workers"]["count"]) :
    "worker-${i + 1}" => {
      hostname = "k8s-worker-${i + 1}"
      memory   = var.vms["workers"]["memory"]
      vcpu     = var.vms["workers"]["vcpu"]
      disk     = var.vms["workers"]["disk_size"]
    }
  }

  # Conditionally create load balancer VM
  load_balancer = {
    "lb" = {
      hostname = "lb"
      memory   = var.load_balancer["lb"]["memory"]
      vcpu     = var.load_balancer["lb"]["vcpu"]
      disk     = var.load_balancer["lb"]["disk_size"]
    }
  }

  all_vms = merge(local.masters, local.workers, local.load_balancer)
}

################## Define cloud-init disks ##################

resource "libvirt_cloudinit_disk" "vm_init" {
  for_each = local.all_vms

  name = "${each.key}-cloudinit"
  user_data = templatefile("${path.module}/templates/user-data.tpl", {
    hostname = each.value.hostname
    ssh_key  = file(var.ssh)
  })
  meta_data = file("${path.module}/templates/meta-data.tpl")
}

resource "libvirt_volume" "vm_init_disk" {
  for_each = local.all_vms

  name = "${each.key}-cloudinit.iso"
  pool = "default"

  create = {
    content = {
      url = libvirt_cloudinit_disk.vm_init[each.key].path
    }
  }
}

################## Define VMs disks ##################

resource "libvirt_volume" "base_image" {
  name = "ubuntu22-base.qcow2"
  pool = "default"

  target = {
    format = {
      type = "qcow2"
    }
  }

  create = {
    content = {
      url = var.base_image_path
    }
  }
}

resource "libvirt_volume" "vm_disk" {
  for_each = local.all_vms

  name     = "${each.key}.qcow2"
  pool     = "default"
  capacity = each.value.disk

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.base_image.path
    format = {
      type = "qcow2"
    }
  }
}

################## Define VMs ##################

resource "libvirt_domain" "vm" {
  for_each = local.all_vms

  name        = each.value.hostname
  memory      = each.value.memory
  memory_unit = "MiB"
  vcpu        = each.value.vcpu
  type        = "kvm"
  running     = true

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
  }

  features = {
    acpi = true
    apic = {
      eoi = "on"
    }
    smm = {
      state = "on"
    }
    vm_port = {
      state = "off"
    }
  }

  cpu = {
    mode = "host-passthrough"
  }

  devices = {
    disks = [
      {
        source = {
          file = {
            file = libvirt_volume.vm_disk[each.key].id
          }
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
        driver = {
          name    = "qemu"
          type    = "qcow2"
          discard = "unmap"
        }
      },
      {
        device = "cdrom"
        source = {
          file = {
            file = libvirt_volume.vm_init_disk[each.key].id
          }
        }
        target = {
          dev = "sda"
          bus = "sata"
        }
        driver = {
          name = "qemu"
          type = "raw"
        }
      }
    ]
    interfaces = [
      {
        model = {
          type = "virtio"
        }
        source = {
          network = {
            network = "homelab"
          }
        }
        wait_for_ip = {
          source = "lease"
        }
      }
    ]
  }
}
