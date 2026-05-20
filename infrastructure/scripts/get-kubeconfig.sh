#!/bin/bash

SSH_KEY="$HOME/.ssh/id_rsa"
KNOWN_HOSTS="$HOME/.ssh/homelab_known_hosts"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

MASTER_IP=$(cd ../terraform/ && terraform output -json vm_ips | jq -r '.["master-1"]')

ssh-keygen -R $MASTER_IP -f $KNOWN_HOSTS 2>/dev/null

if ssh-keyscan -H $MASTER_IP >>$KNOWN_HOSTS 2>/dev/null; then
  log_info "Added host key for master-1"
else
  log_error "Could not scan host key for master-1"
  exit
fi

#TODO remove hardcoded ubuntu user
ssh -i $SSH_KEY ubuntu@$MASTER_IP -o UserKnownHostsFile=$KNOWN_HOSTS "cat /home/ubuntu/.kube/config" >$HOME/.kube/config
kubectl get nodes -o wide
echo

log_info "config saved to $HOME/.kube/config"
