# Homelab Proxmox VE (PVE) Terraform

本仓库包含以下相互独立的 Terraform root modules：

| 目录 | HCP Terraform workspace |
| --- | --- |
| `config` | `homelab-pve-config` |
| `databases` | `homelab-pve-databases` |
| `forgejo` | `homelab-pve-forgejo` |
| `minio` | `homelab-pve-minio` |
| `talos` | `homelab-pve-talos` |
| `vms` | `homelab-pve-vms` |

## 本地环境

1. 安装 `.terraform-version` 指定的 Terraform 版本。`tfenv`、`tenv` 等版本管理器会自动读取该文件。
2. 执行 `terraform login`，登录 `app.terraform.io`。本地初始化及验证需要访问各 workspace 和 provider registry。
3. 初始化所有 root modules：

   ```shell
   make init
   ```

4. 修改代码后执行静态检查：

   ```shell
   make check
   ```

也可以通过 `STACKS` 只处理指定的 root module，例如 `make init STACKS=vms`。`make fmt` 会格式化仓库内的全部 Terraform 文件；提交前请保留各 root module 的 `.terraform.lock.hcl` 更新。

## VCS 工作流

本仓库由 HCP Terraform 的 VCS-driven workflow 管理。请通过分支和 Pull Request 提交变更，由关联 workspace 生成 speculative plan；合并后的正式 run 和 apply 也应在 HCP Terraform 中审核和执行。

**不要在本地执行 `terraform apply`。** Makefile 有意不提供 `apply` target，避免绕过远端 workspace 的审批、变量和审计流程。本地命令仅用于初始化、格式化及验证配置。
