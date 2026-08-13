locals {
  talos_version         = "v1.13.7"
  schematic_id          = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
  talos_installer_image = "factory.talos.dev/installer/${local.schematic_id}:${local.talos_version}"

  controlplane_nodes = {
    "cp-01" = "192.168.50.110"
    "cp-02" = "192.168.50.112"
    "cp-03" = "192.168.50.114"
  }

  worker_nodes = {
    "worker-01" = "192.168.50.111"
    "worker-02" = "192.168.50.113"
    "worker-03" = "192.168.50.115"
  }
}

# 1. Talos Machine Secrets
resource "talos_machine_secrets" "this" {}

# 2. Control Plane Machine Configuration with Zot Mirror Patches
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
            "factory.talos.dev" = {
              endpoints    = ["http://192.168.50.125:8080/v2/factory.talos.dev"]
              overridePath = true
            }
            "docker.io" = {
              endpoints    = ["http://192.168.50.125:8080/v2/docker.io"]
              overridePath = true
            }
            "ghcr.io" = {
              endpoints    = ["http://192.168.50.125:8080/v2/ghcr.io"]
              overridePath = true
            }
            "registry.k8s.io" = {
              endpoints    = ["http://192.168.50.125:8080/v2/registry.k8s.io"]
              overridePath = true
            }
            "quay.io" = {
              endpoints    = ["http://192.168.50.125:8080/v2/quay.io"]
              overridePath = true
            }
            "gcr.io" = {
              endpoints    = ["http://192.168.50.125:8080/v2/gcr.io"]
              overridePath = true
            }
          }
        }
      }
    })
  ]
}

# 3. Worker Machine Configuration with Zot Mirror Patches
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
            "factory.talos.dev" = {
              endpoints    = ["http://192.168.50.125:8080/v2/factory.talos.dev"]
              overridePath = true
            }
            "docker.io" = {
              endpoints    = ["http://192.168.50.125:8080/v2/docker.io"]
              overridePath = true
            }
            "ghcr.io" = {
              endpoints    = ["http://192.168.50.125:8080/v2/ghcr.io"]
              overridePath = true
            }
            "registry.k8s.io" = {
              endpoints    = ["http://192.168.50.125:8080/v2/registry.k8s.io"]
              overridePath = true
            }
            "quay.io" = {
              endpoints    = ["http://192.168.50.125:8080/v2/quay.io"]
              overridePath = true
            }
            "gcr.io" = {
              endpoints    = ["http://192.168.50.125:8080/v2/gcr.io"]
              overridePath = true
            }
          }
        }
      }
    })
  ]
}

# 4. 应用 Machine Configuration 到 Control Plane 节点
resource "talos_machine_configuration_apply" "controlplane" {
  for_each                    = local.controlplane_nodes
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value
}

# 5. 应用 Machine Configuration 到 Worker 节点
resource "talos_machine_configuration_apply" "worker" {
  for_each                    = local.worker_nodes
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value
}

# 6. 自动 Bootstrap 首个 Control Plane 节点
resource "talos_machine_bootstrap" "this" {
  depends_on           = [talos_machine_configuration_apply.controlplane]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controlplane_nodes["cp-01"]
}

# 7. 生成 Talos 客户端配置 (talosconfig)
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = values(local.controlplane_nodes)
}

# 8. 自动生成 Kubernetes Kubeconfig
resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controlplane_nodes["cp-01"]
}
