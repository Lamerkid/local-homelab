.PHONY: help deploy destroy clean

help:
	@echo "Available commands:"
	@echo "  make deploy    - Full deployment (Terraform + Ansible)"
	@echo "  make destroy   - Destroy everything"
	@echo "  make clean     - Clean up state"
	@echo "  make ansible   - Run only Ansible (VMs must exist)"
	@echo "  make status    - Show deployment status"

deploy:
	cd kubernetes && ./deploy-k8s.sh

destroy:
	cd kubernetes/terraform && terraform destroy -auto-approve

clean: destroy
	rm -f kubernetes/terraform/terraform.tfstate*

ansible:
	cd kubernetes/ansible && ansible-playbook -i inventory/hosts.ini playbooks/*.yml

status:
	@echo "=== VMs ==="
	@sudo virsh list --all
	@echo "\n=== Terraform Output ==="
	@cd kubernetes/terraform && terraform output
