# Local homelab

- ✔ Hypervisor ✔
  - [KVM/libvirt](/docs/Virtualization.md)
- ✔ IaC ✔
  - Terraform
    - Providers
      - dmacvicar/libvirt
      - hashicorp/local
- ✔ Configuration management ✔
  - Ansible
- CI/CD
  - Gitlab CI
  - ArgoCD
- Secrets
  - Hashicorp Vault
- Ingress
  - NGINX Ingress
- ✔ Orchestration ✔
  - Kubernetes
    - kubeadm
    - HAProxy
    - Calico
- Database
  - PostgreSQL
- Monitoring
  - Prometheus
  - Grafana
- Logging
  - Loki/ELK

## Infrastructure as code

Bootstrap configuration is defined in [bootstrap/bootstrap-config.yaml](bootstrap/bootstrap-config.yaml):

- Base image
- Storage pool
- Network

Infrastructure configuration is defined in [infrastructure/cluster-config.yaml](infrastructure/cluster-config.yaml):

- VM nodes
- Defaults
- Local ssh keys

### Helper scripts

[bootstrap/scripts](bootstrap/scripts):

- download-image.sh - wgets current ubuntu 24 and places it close to virt pool

[infrastructure/scripts](infrastructure/scripts)

- check-conn.sh - runs after VMs is created and checks ssh connectivity
- get-kubeconfig.sh - runs after k8s is configured, clones `~/.kube/config` locally

## Configuration Management

Ansible configuration of deployed servers is is located at [infrastructure/ansible](infrastructure/ansible)

## Sequence diagram example

Example diagram how infrastructure and kubernetes cluster are deployed.
All user inputs automated with [Makefile](Makefile)
Run `make help` to see all the commands.

```mermaid
sequenceDiagram
    participant User
    participant Bootstrap
    participant Infrastructure
    participant Module
    participant Libvirt
    participant Ansible
    participant Kubernetes

    User->>Bootstrap: Download base image
    Bootstrap-->>User: Base image ready
    User->>Bootstrap: terraform apply (with bootstrap_config.yaml)
    Libvirt->>Bootstrap: Read base image
    Bootstrap->>Libvirt: Create storage pool
    Libvirt-->>Bootstrap: Pool created
    Bootstrap->>Libvirt: Create NAT network
    Libvirt-->>Bootstrap: Network ready
    Bootstrap-->>User: Bootstrap complete (outputs saved)

    User->>Infrastructure: terraform apply (with cluster_config.yaml)
    Infrastructure->>Bootstrap: Read outputs via remote_state
    Bootstrap-->>Infrastructure: pool_name, network_name, base_image_path
    
    loop For each node in cluster_config.yaml
        Infrastructure->>Module: Call vm module
        Module->>Libvirt: Create cloud-init ISO
        Module->>Libvirt: Create COW disk
        Module->>Libvirt: Define VM domain
        Libvirt-->>Module: VM created
        Module-->>Infrastructure: VM ID and IP
    end
    
    Infrastructure->>Libvirt: Wait for DHCP leases
    Libvirt-->>Infrastructure: IP addresses assigned
    Infrastructure->>Infrastructure: Generate Ansible inventory
    Infrastructure-->>User: Infrastructure ready

    User->>Infrastructure: Check connection
    Infrastructure-->>User: Hosts are available
    rect rgb(111, 156, 101)
      User->>Ansible: ansible-playbook site.yml
      Ansible->>Infrastructure: Read inventory
      Infrastructure-->>Ansible: Hosts and IPs
      
      rect rgb(99, 139, 204)
        Ansible->>Kubernetes: Install containerd on all nodes
        Ansible->>Kubernetes: Install kubeadm/kubelet/kubectl
        Ansible->>Kubernetes: Initialize first master
        Ansible->>Kubernetes: Install CNI (Calico)
        Ansible->>Kubernetes: Join additional masters
        Ansible->>Kubernetes: Join workers
        Kubernetes-->>Ansible: Cluster ready
        Ansible-->>User: Playbook completed
        User->>Infrastructure: Get kube config
        Infrastructure->>Kubernetes: Clone remote config
        Kubernetes-->>User: Created ~/.kube/config
      end
    end
```
