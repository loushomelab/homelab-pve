# 读取 Doppler 里的 PBS 和集群相关配置
# 注意：前提是当前绑定的 DOPPLER_TOKEN 对应的项目/环境中包含以下 Secret
data "doppler_secrets" "pbs" {}

# 1. 将 PBS 挂载为 PVE 的全局存储
resource "proxmox_virtual_environment_storage" "pbs_cluster_storage" {
  content_types = ["backup"]
  
  datastore_id  = "pbs-lxc" 
  
  pbs {
    server      = data.doppler_secrets.pbs.map.PBS_HOST
    datastore   = data.doppler_secrets.pbs.map.PBS_DATASTORE
    username    = data.doppler_secrets.pbs.map.PBS_TOKEN_ID
    password    = data.doppler_secrets.pbs.map.PBS_TOKEN_SECRET
    fingerprint = data.doppler_secrets.pbs.map.PBS_FINGERPRINT
  }
}

# 2. 全局每日备份计划
resource "proxmox_virtual_environment_cluster_backup" "daily_all_vms" {
  node_name  = "r720" 
  
  storage_id = proxmox_virtual_environment_storage.pbs_cluster_storage.datastore_id

  schedule = "02:00"
  mode     = "snapshot"
  all      = true

  mail_notification = "always"
  mail_to           = data.doppler_secrets.pbs.map.HOMELAB_EMAIL
  
  compress = "zstd"

  retention {
    keep_last   = 7
    keep_daily  = 7
    keep_weekly = 4
  }
}