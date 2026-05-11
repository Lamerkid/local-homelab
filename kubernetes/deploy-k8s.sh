#!/bin/bash

set -e

SSH_KEY="$HOME/.ssh/id_rsa"
KNOWN_HOSTS="$HOME/.ssh/known_hosts"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

log_info "=== Starting Homelab Deployment ==="

log_info "Step 1: Deploying infrastructure with Terraform..."

cd terraform/
terraform init -input=false
terraform apply -auto-approve

IPS=$(terraform output -json vm_ips | jq -r '.[]')
LB_IP=$(terraform output -json lb_ip | jq -r '.[]')
MASTER_IPS=$(terraform output -json master_ips | jq -r '.[]')
WORKER_IPS=$(terraform output -json worker_ips | jq -r '.[]')

log_info "✓ VMs created:"
log_info "\\tMasters:"
for ip in $MASTER_IPS; do
  log_info "\\t\\t${ip}"
done
log_info "\\tWorkers:"
for ip in $WORKER_IPS; do
  log_info "\\t\\t${ip}"
done

log_info "Step 2: Testing connectivity..."

for ip in $IPS; do
  # Wait for SSH to be ready
  max_attempts=30
  attempt=0

  while [ $attempt -lt $max_attempts ]; do
    if nc -z $ip 22 2>/dev/null; then
      log_info "SSH ready on $ip"
      break
    fi
    attempt=$((attempt + 1))
    sleep 2
  done

  # Accept the host key
  if ssh-keyscan -H $ip >>$KNOWN_HOSTS 2>/dev/null; then
    log_info "Added host key for $ip"
  else
    log_error "Could not scan host key for $ip"
  fi
done

for ip in $IPS; do
  if ssh -i $SSH_KEY ubuntu@$ip "echo '  Connected'" 2>/dev/null; then
    log_info "✓ $ip is reachable"
  else
    log_error "✗ $ip is unreachable"
  fi
done

log_info "Step 3: Configuring with Ansible..."

ansible-playbook -i ../ansible/inventory/hosts.ini ../ansible/playbooks/*.yml

ssh -i $SSH_KEY ubuntu@${MASTER_IPS[0]} "cat /home/ubuntu/.kube/config" >$HOME/.kube/config
kubectl get nodes -o wide
echo

log_info "=== Deployment Complete! ==="
log_info "config saved to $HOME/.kube/config"
log_info "run 'kubectl get nodes' to check master and worker nodes"
