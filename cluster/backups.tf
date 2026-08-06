# 1. 将 PBS 挂载为 PVE 的全局存储
resource "proxmox_virtual_environment_storage" "pbs_cluster_storage" {
  content_types = ["backup"]
  
  datastore_id  = "pbs-lxc" 
  
  pbs {
    server      = var.PBS_HOST
    datastore   = var.PBS_DATASTORE
    username    = var.PBS_TOKEN_ID
    password    = var.PBS_TOKEN_SECRET
    fingerprint = var.PBS_FINGERPRINT
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
  mail_to           = var.HOMELAB_EMAIL
  
  compress = "zstd"

  retention {
    keep_last   = 7
    keep_daily  = 7
    keep_weekly = 4
  }
}