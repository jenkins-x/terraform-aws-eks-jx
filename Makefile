SHELL_SPEC_DIR ?= /var/tmp

.DEFAULT_GOAL := help

.PHONY: help
help:
	@grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: apply 
apply: ## Applies Terraform plan
	terraform apply --var-file terraform.tfvars

.PHONY: destroy 
destroy: ## Destroys Terraform infrastructure
	terraform destroy

.PHONY: init 
init: ## Init the terraform module
	terraform init

.PHONY: lint 
lint: init ## Verifies Terraform syntax
	terraform version
	terraform fmt -check -diff
	terraform validate

.PHONY: fmt
fmt: ## Reformats Terraform files accoring to standard
	terraform fmt

.PHONY: test 
test: ## Runs ShellSpec tests
	shellspec --format document --warning-as-failure

.PHONY: clean
clean: ## Deletes temporary files
	rm -rf report
	rm jx-requirements.yml
