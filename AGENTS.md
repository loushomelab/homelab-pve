# AGENTS.md - Homelab Proxmox VE (PVE) Terraform Repository Guide

This repository (`homelab-pve`) manages the infrastructure layer for Lou's Homelab, specifically Proxmox VE virtual machines, global node configurations, PostgreSQL databases/roles, and MinIO S3 storage assets via Terraform and Doppler.

---

## 🏗️ Architecture & Boundaries

1. **LXC Containers Management**:
   - **Manual / Helper-Script Provisioned**: Physical LXC containers (e.g., PostgreSQL DB instances, HCP TF Agents) are created via Proxmox Helper-Scripts (Community/Turnkey scripts) on PVE.
   - **Terraform Logical Control**: Terraform does **NOT** manage the lifecycle of database LXC containers themselves; it manages the **logical entities inside them** (PostgreSQL roles, databases, permissions) via the `cyrilgdn/postgresql` provider.

2. **VMs & Cluster Nodes**:
   - Talos Linux VMs (Control Plane & Worker nodes) are provisioned via `bpg/proxmox` using modular definitions (`modules/proxmox-vm`).

3. **Secrets & Credentials Management**:
   - **Doppler**: Centralized secrets management (`project = "k8s"`, `config = "prd"`).
   - All connection strings, root credentials, user passwords, and API tokens must be pulled from Doppler (`data.doppler_secrets.this.map.<KEY>`).
   - **NEVER** hardcode credentials or commit plaintext secrets into `.tf`, `.tfvars`, or YAML files.

4. **Terraform Cloud / HCP Workspaces**:
   - Organization: `loushomelab`
   - Workspaces:
     - `homelab-pve-config`: Node DNS, ACME certificates, OpenID auth.
     - `homelab-pve-databases`: PostgreSQL roles & databases.
     - `homelab-pve-vms`: Talos Control Plane & Worker VMs.
     - `homelab-pve-minio`: MinIO S3 buckets and IAM policies.
     - `homelab-pve-private`: Private NixOS VM boundary.

---

## 📁 Directory Structure & Responsibilities

```text
homelab-pve/
├── config/             # PVE Node-level settings (DNS, ACME TLS, OpenID Auth)
├── databases/          # PostgreSQL Roles & Logical Databases (Auth DB, Obs DB, App DB)
├── minio/              # MinIO S3 Buckets & IAM User/Policy attachments
├── modules/
│   └── proxmox-vm/     # Reusable module for Proxmox VM provisioning
├── private/            # Private NixOS VM boundary
├── talos/              # Talos Linux bootstrap and machine configs
├── vms/                # Talos VM instances across PVE nodes
└── inventory/          # Network blueprints & environment variable definitions
```

---

## 🐘 Database Provisioning Workflow (e.g., Forgejo / New Services)

When adding a database for a new service (such as Forgejo):

1. **Host Selection / LXC Setup**:
   - Determine whether the service belongs to an existing DB LXC or requires a new one:
     - `192.168.50.151` (LXC 151, `auth`): Auth/Identity services (e.g., Authentik).
     - `192.168.50.152` (LXC 152, `obs`): Observability/Analytics (e.g., Grafana, Umami).
     - `192.168.50.15x` (LXC 15x, `apps`): Dedicated application / git services (e.g., Forgejo).
   - If creating a new LXC, deploy it with Proxmox Helper-Scripts, assign a static IP, and verify connectivity (`5432`).

2. **Register Secrets in Doppler**:
   - Add database user, password, and database name to Doppler (`project: k8s`, `config: prd`):
     - `<SERVICE>_POSTGRESQL__USER`
     - `<SERVICE>_POSTGRESQL__PASSWORD`
     - `<SERVICE>_POSTGRESQL__NAME`

3. **Define Resources in `databases/main.tf`**:
   - Define `postgresql_role.<service>` and `postgresql_database.<service>`.
   - Ensure the correct provider alias is assigned (`postgresql.auth`, `postgresql.obs`, `postgresql.apps`, etc.).

4. **Import & State Management**:
   - If the database was pre-seeded during container installation, add `import {}` blocks in `databases/import.tf` to bring them cleanly into Terraform state without drift.

---

## 🛠️ Code Conventions & Rules for Agents

1. **Terraform Formatting & Validation**:
   - Always run `terraform fmt -check` and ensure configurations adhere to idiomatic HCL2 syntax.
   - Run `tflint` if modifications touch modules or variable schemas.
2. **Provider Separation**:
   - Keep provider declarations in `providers.tf` and resource definitions in `main.tf`.
   - Never combine unrelated infrastructure domains into a single directory.
3. **Safety Protocol**:
   - Do not execute destructive operations (`terraform destroy`, deleting state files, force dropping DBs) without explicit user confirmation.
   - Always inspect `git diff` before suggesting or committing changes.
