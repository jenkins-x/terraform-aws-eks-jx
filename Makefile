ifeq ($(OS),Windows_NT)
    OS := windows
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        OS := linux
    endif
    ifeq ($(UNAME_S),Darwin)
        OS := darwin
    endif
endif

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

tfsec: ## Installs tfsec
	curl -L "$$(curl -s https://api.github.com/repos/liamg/tfsec/releases/latest | grep -o -E "https://.+?-$(OS)-amd64(.exe)?")" > tfsec;\
	chmod +x ./tfsec

check-tfsec: ## Check if tfsec is installed
	./tfsec --version

.PHONY: run-tfsec
run-tfsec: tfsec check-tfsec ## Runs tfsec
	./tfsec . -e AWS002,AWS017

.PHONY: test
test: ## Runs ShellSpec tests
	shellspec --format document --warning-as-failure

.PHONY: clean
clean: ## Deletes temporary files
	rm -rf report
	rm -f jx-requirements.yml
	rm -f tfsec

.PHONY: markdown-table
markdown-table: ## Creates markdown tables for in- and output of this module
	terraform-docs markdown table .
