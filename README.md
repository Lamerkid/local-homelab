# Local homelab based on KVM

## Enable virtualization on you local machine

### Check if your CPU Supports virtualization

```sh
grep -c '(vmx|svm)' /proc/cpuinfo
```

### Install KVM and management tools

debian/ubuntu

```sh
sudo apt install -y \
    qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst \
    libvirt \
    virt-install \
    virt-manager \
    virt-viewer \
    libguestfs-tools \
    virt-top
```

rhel/fedora

```sh
sudo dnf install -y \
    @virtualization \
    qemu-kvm \
    libvirt \
    virt-install \
    virt-manager \
    virt-viewer \
    libguestfs-tools \
    virt-top
```

### Enable libvirtd daemon

```sh
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
```

### Verify virtualization works

```sh
sudo virsh list --all
sudo virt-host-validate
```

## Cloud image

### Download cloud image (example: Ubuntu 22.04)

```sh
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
```

### Create base image

```sh
sudo cp jammy-server-cloudimg-amd64.img /var/lib/libvirt/vm-pool/base-ubuntu22.qcow2
sudo qemu-img info /var/lib/libvirt/vm-pool/base-ubuntu22.qcow2
```

## Terraform configuration

Inside [terraform/variables.tf](kubernetes/terraform/variables.tf) you can configure:

- Public and private SSH keys for accessing your VMs
- Path where you saved your base image
- Network configuration
- Resources for VMs
- Master and worker nodes count

## Script configuration

Inside [deploy-k8s](kubernetes/deploy-k8s.sh) you can set:

- Private SSH key for accessing your VMs `SSH_KEY="$HOME/.ssh/id_rsa"`

## Make deploy

To deploy VMs run `make deploy`

Run `make help` to list all available commands

### DNS resolve

To access hosts by domain names you need:

```sh
# Check the bridge IP (default virbr2)
ip addr show virbr2

# Use that IP as DNS (default 10.0.0.1 and homelab.local)
sudo resolvectl dns virbr2 10.0.0.1
sudo resolvectl domain virbr2 homelab.local

# Check current DNS settings for virbr2
resolvectl status virbr2
```

To remove custom DNS from network use:

```sh
sudo resolvectl revert virbr2
```
