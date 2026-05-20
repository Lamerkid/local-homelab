.PHONY: help clean status test

help:
	@echo -e "Available commands:"
	@echo -e "  make download-img\t- Download ubuntu 24 image"
	@echo -e "  make deploy-all\t- Deploy everything"
	@echo -e "  make deploy-infra\t- Deploy infrastructure"
	@echo -e "  make deploy-k8s\t- Deploy Kubernetes"
	@echo -e ""
	@echo -e "  make destroy-infra\t- Destroy infrastructure"
	@echo -e "  make clean\t\t- Destroy infrastructure and clean the state"
	@echo -e ""
	@echo -e "  make status\t\t- Show infrastructure status"
	@echo -e "  make test\t\t- Run tests"

BOOTSTRAP_DIR = bootstrap/terraform
TERRAFORM_DIR = infrastructure/terraform
ANSIBLE_DIR = infrastructure/ansible

deploy-all: download-img deploy-infra deploy-k8s

download-img:
	@echo "☁️ Downloading cloud image..."
	cd $(BOOTSTRAP_DIR)/../scripts && ./download-image.sh

deploy-infra:
	@echo "🚀 Deploying infrastructure..."
	cd $(BOOTSTRAP_DIR) && terraform init && terraform apply -auto-approve
	cd $(TERRAFORM_DIR) && terraform init && terraform apply -auto-approve
	cd $(TERRAFORM_DIR)/../scripts && ./check-conn.sh

deploy-k8s:
	@echo "🚀 Deploying Kubernetes..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory/hosts.ini playbooks/site.yml --tags=k8s
	cd $(ANSIBLE_DIR)/../scripts && ./get-kubeconfig.sh

destroy-infra:
	@echo "💥 Destroying infrastructure..."
	cd $(TERRAFORM_DIR) && terraform destroy -auto-approve
	cd $(BOOTSTRAP_DIR) && terraform destroy -auto-approve

clean: destroy-infra
	@echo "💥 Cleaning infrastructure state..."
	rm -rf $(TERRAFORM_DIR)/.terraform
	rm -rf $(TERRAFORM_DIR)/terraform.tfstate*
	rm -rf $(BOOTSTRAP_DIR)/.terraform
	rm -rf $(BOOTSTRAP_DIR)/terraform.tfstate*

test:
	@echo "🧪 Running tests..."
	cd $(BOOTSTRAP_DIR) && terraform validate
	cd $(TERRAFORM_DIR) && terraform validate
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory/hosts.ini --syntax-check playbooks/*.yml

status:
	@echo "🖧  Infrastructure state:"
	sudo virsh net-list --all
	sudo virsh pool-list --all
	sudo virsh list --all
	sudo virsh net-dhcp-leases homelab-net
