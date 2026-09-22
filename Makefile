SHELL := /usr/bin/env bash

TERRAFORM ?= terraform
STACKS ?= config databases forgejo minio private talos vms

.DEFAULT_GOAL := check

.PHONY: check fmt fmt-check init validate version

version:
	@$(TERRAFORM) version

fmt:
	@$(TERRAFORM) fmt -recursive

fmt-check:
	@$(TERRAFORM) fmt -check -recursive

init:
	@set -euo pipefail; \
	for stack in $(STACKS); do \
		echo "==> Initializing $$stack"; \
		TF_IN_AUTOMATION=true $(TERRAFORM) -chdir="$$stack" init -input=false; \
	done

validate:
	@set -euo pipefail; \
	for stack in $(STACKS); do \
		echo "==> Validating $$stack"; \
		TF_IN_AUTOMATION=true $(TERRAFORM) -chdir="$$stack" validate; \
	done

check: fmt-check validate
