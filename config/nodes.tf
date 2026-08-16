locals {
  pve_domain_suffix = "pve.646499453.xyz"
  pve_nodes = toset([
    "r720",
    "1920x",
    "3960x",
    "n100x8"
  ])
}

# 1. 批量配置 4 个 PVE 节点的系统 DNS Search Domain
resource "proxmox_virtual_environment_dns" "node_dns" {
  for_each  = local.pve_nodes
  node_name = each.value

  domain = local.pve_domain_suffix
}

# 2. 批量配置 4 个 PVE 节点的原生 ACME TLS 证书
resource "proxmox_acme_certificate" "pve_node_cert" {
  for_each  = local.pve_nodes
  node_name = each.value

  # 直接指定 PVE 中已手动创建好的 ACME 账号名称
  account = "homelab"

  domains = [
    {
      domain = "${each.value}.${local.pve_domain_suffix}"
      plugin = proxmox_acme_dns_plugin.qqxyz.plugin
    }
  ]

  depends_on = [
    proxmox_virtual_environment_dns.node_dns,
    proxmox_acme_dns_plugin.qqxyz
  ]
}
