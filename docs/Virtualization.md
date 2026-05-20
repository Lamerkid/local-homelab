# Enable virtualization on you local machine

## Check if your CPU Supports virtualization

```sh
grep -c '(vmx|svm)' /proc/cpuinfo
```

## Install KVM and management tools

- ubuntu
  [KVM hypervisor: a beginners’ guide](https://ubuntu.com/blog/kvm-hyphervisor)
- fedora
  [Virtualization – Getting Started](https://docs.fedoraproject.org/en-US/quick-docs/virtualization-getting-started/)

## Enable libvirtd daemon

```sh
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
```

## Verify virtualization works

```sh
sudo virsh list --all
sudo virt-host-validate
```
