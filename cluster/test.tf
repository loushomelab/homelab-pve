# 这是一个测试数据源，用于验证 Terraform 是否能成功连接到 PVE 集群并读取数据
data "proxmox_virtual_environment_nodes" "cluster_nodes" {}

output "pve_nodes" {
  value = data.proxmox_virtual_environment_nodes.cluster_nodes.names
}
