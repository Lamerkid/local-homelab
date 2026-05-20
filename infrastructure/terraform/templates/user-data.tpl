#cloud-config
hostname: ${hostname}
manage_etc_hosts: true

users:
  - name: ${username}
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: true
    ssh_authorized_keys:
      - ${ssh_public_key}

package_update: false
package_upgrade: false

packages:
  - qemu-guest-agent
  - vim
  - net-tools
  - bridge-utils

runcmd:
  - systemctl enable ssh
  - systemctl restart ssh
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
