# Make setup
WORK_DIR := $(realpath $(dir $(firstword $(MAKEFILE_LIST))))

# Terraform variables
TF := terraform
TFL := tflint
TFD := terraform-docs
PLAN_FILE := $(WORK_DIR)/terraform.tfplan

##@ Help
# from https://www.thapaliya.com/en/writings/well-documented-makefiles/
default: help
.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ CI tasks

.PHONY: clean
clean: ## Removes all generated files from the working directory
	rm -rf .terraform*
	rm -rf $(PLAN_FILE)

.PHONY: install
install: validate ## Installs plugins required for developing this library
	$(TF) init
	$(TF) get -update
	$(TFL) --init

.PHONY: validate
validate: ## Validates all project dependencies are installed
	@command -v $(TF) >/dev/null 2>&1 || { echo >&2 "Unable to continue: 'terraform' is not installed"; exit 1; }
	@command -v $(TFL) >/dev/null 2>&1 || { echo >&2 "Unable to continue: 'tflint' is not installed"; exit 1; }
	@command -v $(TFD) >/dev/null 2>&1 || { echo >&2 "Unable to continue: 'terraform-docs' is not installed"; exit 1; }

.PHONY: lint
lint: ## Lints the project to discover any potential errors
	$(TFL) --recursive --config "$(WORK_DIR)/.tflint.hcl"
	$(TF) fmt -recursive -check -diff

.PHONY: format
format: ## Formats all Terraform files into a canonical format
	$(TF) fmt -recursive

.PHONY: create-module 
create-module: ## Create a new module, usage: make create-module NAME=<name>
ifeq ($(NAME),)
	$(error NAME argument is not set)
else
	rm -rf "$(WORK_DIR)/aws/$(NAME)"
	mkdir -p "$(WORK_DIR)/aws/$(NAME)"
	cp --recursive --force "$(WORK_DIR)/templates/terraform-module/." "$(WORK_DIR)/aws/$(NAME)"
endif

.PHONY: generate-docs
generate-docs: ## Generates the documentation for all modules
	@echo "Updating module documentation within '$(WORK_DIR)/aws'"
	@find "$(WORK_DIR)/aws" -name "provider.tf" -type f -exec sh -c '$(TFD) --config $(WORK_DIR)/.terraform-docs.yml $$(dirname $$1)' sh {} \;
