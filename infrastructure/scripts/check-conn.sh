#!/bin/bash

set -e

SSH_KEY="$HOME/.ssh/id_rsa"
KNOWN_HOSTS="$HOME/.ssh/homelab_known_hosts"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

log_info "Checking SSH connectivity to all VMs..."

cd ../terraform
touch $KNOWN_HOSTS

ips=$(terraform output -json vm_ips | jq -r '.[]')

for ip in $ips; do
  # Wait for SSH to be ready
  max_attempts=30
  attempt=0

  while [ $attempt -lt $max_attempts ]; do
    if nc -z $ip 22 2>/dev/null; then
      log_info "SSH ready on $ip"
      break
    fi
    attempt=$((attempt + 1))
    log_warn "attempt $attempt"
    sleep 2
  done

  ssh-keygen -R $ip -f $KNOWN_HOSTS 2>/dev/null

  # Accept the host key
  if ssh-keyscan -H $ip >>$KNOWN_HOSTS 2>/dev/null; then
    log_info "Added host key for $ip"
  else
    log_error "Could not scan host key for $ip"
  fi
done

#TODO remove hardcoded ubuntu user
for ip in $ips; do
  if ssh -o UserKnownHostsFile=$KNOWN_HOSTS -i $SSH_KEY ubuntu@$ip "echo 'Connected'" 2>/dev/null; then
    log_info "✓ $ip is reachable"
  else
    log_error "✗ $ip is unreachable"
  fi
done
