################## Define cloud-init disk ##################

resource "libvirt_cloudinit_disk" "vm_init" {
  name = "${var.vm_name}-cloudinit"
  user_data = templatefile("${path.module}/../../templates/user-data.tpl", {
    hostname       = var.vm_name
    username       = var.user_name
    ssh_public_key = file(var.ssh_public_key)
  })
  meta_data = templatefile("${path.module}/../../templates/meta-data.tpl", {
    hostname = var.vm_name
  })
}

resource "libvirt_volume" "vm_init_disk" {
  name = "${var.vm_name}-cloudinit.iso"
  pool = var.storage_pool

  create = {
    content = {
      url = libvirt_cloudinit_disk.vm_init.path
    }
  }
}

################## Define disk ##################

resource "libvirt_volume" "vm_disk" {
  name     = "${var.vm_name}.qcow2"
  pool     = var.storage_pool
  capacity = var.disk_size * 1024 * 1024 * 1024

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = var.base_image
    format = {
      type = "qcow2"
    }
  }
}

################## Define VM ##################

resource "libvirt_domain" "vm" {
  name        = var.vm_name
  memory      = var.memory
  memory_unit = "MiB"
  vcpu        = var.vcpu
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
            file = libvirt_volume.vm_disk.id
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
            file = libvirt_volume.vm_init_disk.id
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
            network = var.network_name
          }
        }
        wait_for_ip = {
          source = "lease"
        }
      }
    ]
  }
}
