locals {
  talos_version = "v1.13.7"
  # Talos Image Factory schematic ID: ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515 (includes siderolabs/qemu-guest-agent)
  talos_iso_url = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/${local.talos_version}/nocloud-amd64.iso"

  target_nodes = ["r720", "1920x", "3960x"]
}

# 1. 在所有目标节点的 local 存储上下载 Talos ISO
resource "proxmox_download_file" "talos_iso" {
  for_each     = toset(local.target_nodes)
  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key

  url       = local.talos_iso_url
  file_name = "talos-${local.talos_version}-nocloud-qga-amd64.iso"
  overwrite = false
}

# 2. 部署 Control Plane 节点 (3台)
module "talos_cp" {
  source = "../modules/proxmox-vm"

  for_each = {
    "cp-01" = { node = "r720", id = 801, mac = "BC:24:11:00:00:01" }
    "cp-02" = { node = "1920x", id = 802, mac = "BC:24:11:00:00:02" }
    "cp-03" = { node = "3960x", id = 803, mac = "BC:24:11:00:00:03" }
  }

  name        = "talos-${each.key}"
  node_name   = each.value.node
  vm_id       = each.value.id
  mac_address = each.value.mac
  cores       = 4
  memory      = 4096
  iso_file_id = proxmox_download_file.talos_iso[each.value.node].id
}

# 3. 部署 Worker 节点 (3台)
module "talos_worker" {
  source = "../modules/proxmox-vm"

  for_each = {
    "worker-01" = { node = "r720", id = 811, mac = "BC:24:11:00:01:01" }
    "worker-02" = { node = "1920x", id = 812, mac = "BC:24:11:00:01:02" }
    "worker-03" = { node = "3960x", id = 813, mac = "BC:24:11:00:01:03" }
  }

  name        = "talos-${each.key}"
  node_name   = each.value.node
  vm_id       = each.value.id
  mac_address = each.value.mac
  cores       = 8
  memory      = 16384
  iso_file_id = proxmox_download_file.talos_iso[each.value.node].id
}

# --- 状态迁移块 (防止重建之前已创建好的 801 节点) ---
moved {
  from = proxmox_virtual_environment_download_file.talos_iso
  to   = proxmox_download_file.talos_iso["r720"]
}

moved {
  from = proxmox_virtual_environment_vm.talos_cp_01
  to   = module.talos_cp["cp-01"].proxmox_virtual_environment_vm.this
}

# 4. Talos Machine Secrets
resource "talos_machine_secrets" "this" {}

# 5. Control Plane Machine Configuration with Zot Mirror Patches
# tflint-ignore: terraform_unused_declarations
data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = [
    yamlencode({
      machine = {
        registries = {
          # 1. 映射常见 Registry 域名到 Zot
          mirrors = {
            "docker.io" = {
              endpoints = ["http://192.168.50.125:8080/v2/docker.io"]
            }
            "ghcr.io" = {
              endpoints = ["http://192.168.50.125:8080/v2/ghcr.io"]
            }
            "registry.k8s.io" = {
              endpoints = ["http://192.168.50.125:8080/v2/registry.k8s.io"]
            }
            "quay.io" = {
              endpoints = ["http://192.168.50.125:8080/v2/quay.io"]
            }
            "gcr.io" = {
              endpoints = ["http://192.168.50.125:8080/v2/gcr.io"]
            }
          }
          # 2. 允许 HTTP (非 HTTPS) 内部连接
          config = {
            "192.168.50.125:8080" = {
              tls = {
                insecureSkipVerify = true
              }
            }
          }
        }
      }
    })
  ]
}

# 6. Worker Machine Configuration with Zot Mirror Patches
# tflint-ignore: terraform_unused_declarations
data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = [
    yamlencode({
      machine = {
        registries = {
          # 1. 映射常见 Registry 域名到 Zot
          mirrors = {
            "docker.io" = {
              endpoints = ["http://192.168.50.125:8080/v2/docker.io"]
            }
            "ghcr.io" = {
              endpoints = ["http://192.168.50.125:8080/v2/ghcr.io"]
            }
            "registry.k8s.io" = {
              endpoints = ["http://192.168.50.125:8080/v2/registry.k8s.io"]
            }
            "quay.io" = {
              endpoints = ["http://192.168.50.125:8080/v2/quay.io"]
            }
            "gcr.io" = {
              endpoints = ["http://192.168.50.125:8080/v2/gcr.io"]
            }
          }
          # 2. 允许 HTTP (非 HTTPS) 内部连接
          config = {
            "192.168.50.125:8080" = {
              tls = {
                insecureSkipVerify = true
              }
            }
          }
        }
      }
    })
  ]
}

# 7. Talos Client Configuration (talosconfig)
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for name, node in module.talos_cp : try(node.ipv4_addresses[1][0], "")]
}

# 8. Kubernetes Kubeconfig
resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = try(module.talos_cp["cp-01"].ipv4_addresses[1][0], "192.168.50.110")
}

# 9. Talos Bootstrap Resource
resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = try(module.talos_cp["cp-01"].ipv4_addresses[1][0], "192.168.50.110")
}
