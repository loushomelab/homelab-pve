# 读取 Doppler 里的 PBS 和集群相关配置
data "doppler_secrets" "pbs" {
  config  = "prd"
  project = "k8s"
}

# 1. 挂载 Proxmox Backup Server (PBS) 存储
# 在 PBS 中，完全可以使用 API Token 进行认证。
# Proxmox 官方机制是将 Token ID 作为 username（例如：user@pbs!token），Token 密钥作为 password。
resource "proxmox_storage_pbs" "pbs_lxc" {
  id          = "pbs-lxc"
  server      = data.doppler_secrets.pbs.map.PBS_HOST
  datastore   = data.doppler_secrets.pbs.map.PBS_DATASTORE
  username    = data.doppler_secrets.pbs.map.PBS_TOKEN_ID
  password    = data.doppler_secrets.pbs.map.PBS_TOKEN_SECRET
  fingerprint = data.doppler_secrets.pbs.map.PBS_FINGERPRINT

  content = ["backup"]
}

# 2. 配置 PVE 的全局备份任务
resource "proxmox_backup_job" "pbs_daily_backup" {
  id       = "pbs-daily-backup"
  node     = "r720"
  storage  = proxmox_storage_pbs.pbs_lxc.id
  schedule = "02:00"
  mode     = "snapshot"
  all      = true

  mailnotification = "always"
  mailto           = [data.doppler_secrets.pbs.map.HOMELAB_EMAIL]
  compress         = "zstd"

  prune_backups = {
    keep-last   = "7"
    keep-daily  = "7"
    keep-weekly = "4"
  }
}
