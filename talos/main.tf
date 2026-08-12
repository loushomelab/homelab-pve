locals {
  talos_version         = "v1.13.7"
  schematic_id          = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
  talos_installer_image = "factory.talos.dev/installer/${local.schematic_id}:${local.talos_version}"

  controlplane_nodes = ["cp-01", "cp-02", "cp-03"]
  worker_nodes       = ["worker-01", "worker-02", "worker-03"]
}

# 1. 引用 01-vms Workspace 的输出状态获取节点 IP
data "terraform_remote_state" "vms" {
  backend = "remote"

  config = {
    organization = "loushomelab"
    workspaces = {
      name = "homelab-pve-vms"
    }
  }
}

# 2. Talos Machine Secrets
resource "talos_machine_secrets" "this" {}

# 3. Control Plane Machine Configuration with Zot Mirror Patches
data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = local.talos_installer_image
        }
        sysctls = {
          "net.ipv6.conf.all.disable_ipv6"     = "1"
          "net.ipv6.conf.default.disable_ipv6" = "1"
        }
        registries = {
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

# 4. Worker Machine Configuration with Zot Mirror Patches
data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = local.talos_installer_image
        }
        sysctls = {
          "net.ipv6.conf.all.disable_ipv6"     = "1"
          "net.ipv6.conf.default.disable_ipv6" = "1"
        }
        registries = {
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

# 5. 应用 Machine Configuration 到 Control Plane 节点
resource "talos_machine_configuration_apply" "controlplane" {
  for_each                    = toset(local.controlplane_nodes)
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = try(data.terraform_remote_state.vms.outputs.talos_control_plane_ips[each.key], "")
}

# 6. 应用 Machine Configuration 到 Worker 节点
resource "talos_machine_configuration_apply" "worker" {
  for_each                    = toset(local.worker_nodes)
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = try(data.terraform_remote_state.vms.outputs.talos_worker_ips[each.key], "")
}

# 7. 自动 Bootstrap 首个 Control Plane 节点
resource "talos_machine_bootstrap" "this" {
  depends_on           = [talos_machine_configuration_apply.controlplane]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = try(data.terraform_remote_state.vms.outputs.talos_control_plane_ips["cp-01"], "192.168.50.110")
}

# 8. 生成 Talos 客户端配置 (talosconfig)
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for ip in values(data.terraform_remote_state.vms.outputs.talos_control_plane_ips) : ip]
}

# 9. 自动生成 Kubernetes Kubeconfig
resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = try(data.terraform_remote_state.vms.outputs.talos_control_plane_ips["cp-01"], "192.168.50.110")
}
