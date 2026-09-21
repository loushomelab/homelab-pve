# Homelab PVE Agent Contract

`KB_POLICY_VERSION: v2`

This is an independent Git repository. When working here, resolve the active root with `git rev-parse --show-toplevel` and follow this file; do not rely on a parent repository's `AGENTS.md` or local skills. The agent works from this repository; the Obsidian Vault is only an approved knowledge destination.

## Required workflow

Before non-trivial Proxmox, Terraform, Talos VM, storage, HA, provider, state migration, incident, recovery, or architecture work, dynamically discover `~/.obsidian-vault/*`, read matching Vault `AGENTS.md`, and search the unique Homelab Vault for existing `Systems/Proxmox/` or `Systems/Talos/` guidance.

At close, classify the task as exactly one of:

- `updated`: explicit user approval, Vault merge and validation completed;
- `no-durable-knowledge`: no reusable fact, with reason;
- `pending-user-approval`: target path and outline presented, no write performed;
- `blocked`: Vault, destination, security, locking, merge, validation, or write failure.

Durable knowledge includes verified fixes, reusable runbooks, architecture/ownership decisions, compatibility constraints, regressions, recovery procedures, and cross-repository contracts. Formatting, spelling, lockfile-only changes, unverified experiments, and ordinary one-off values normally do not create notes.

## Vault write boundary

Durable knowledge goes to the discovered Homelab Vault, never to a repository `notes/` shadow. Prefer an existing `Systems/Proxmox/` or `Systems/Talos/` note. Before writing, present the exact target path and outline and wait for explicit approval. Re-read under an advisory lock, merge instead of overwrite, validate frontmatter/code fences/Wikilinks/duplicates/secrets, and use atomic replacement. A new Vault directory requires explicit approval. Never auto-commit or auto-push the Vault.

## Security

Never record tokens, passwords, private keys, cookies, certificates, `.env`, Terraform state, Doppler output, secret values, or PII. Use placeholders. Distinguish repository evidence from runtime verification; do not claim live state without a live check. If safe merging fails, preserve the target and report `blocked`.

## Terraform execution contract

This repository is an independent VCS source for the HCP Terraform workspace `loushomelab/homelab-pve-cluster` defined in `cluster/providers.tf`.

- All Terraform changes enter through Git/VCS and the workspace's configured remote or approved runner path.
- `terraform apply` MUST NOT run on a workstation. The configured HCP/runner path is authoritative for state, locking, plan, approval, and apply.
- Local `terraform fmt`, `validate`, static analysis, and other read-only checks MAY run; local state or local apply is never an alternative execution path.
- A pull request or VCS revision MUST produce a plan whose scope is reviewed before apply. A new VM plan MUST show no replacement, destroy, or unrelated mutation of existing PVE resources.
- Runtime PVE facts override stale examples and defaults after a non-destructive live check. The planned `private` VM uses datastore ID `SSD`, node `r720`, and the existing `pbstorage` backup path.

## Ownership boundary

Terraform owns the PVE VM, disks, NIC/MAC, CPU, memory, ISO/template attachment, and backup-related infrastructure objects. It MUST NOT run `nixos-rebuild`, edit guest files, install Docker, deploy Compose workloads, or manage application data.

The independent `NixOSs/NixOS-Private` repository owns the guest OS and guest lifecycle. Day-zero installation is a one-time bootstrap exception; normal changes are VCS-reviewed, built, and deployed by the NixOS delivery path.
