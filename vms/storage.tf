# 挂载 Proxmox Backup Server (PBS) 存储
resource "proxmox_storage_pbs" "pbs_lxc" {
  id          = "pbs-lxc"
  server      = data.doppler_secrets.this.map.PBS_HOST
  datastore   = data.doppler_secrets.this.map.PBS_DATASTORE
  username    = data.doppler_secrets.this.map.PBS_TF_SA_ID
  password    = data.doppler_secrets.this.map.PBS_TF_SA_TOKEN
  fingerprint = data.doppler_secrets.this.map.PBS_FINGERPRINT

  content = ["backup"]
}

# 配置 PVE 的全局备份任务
resource "proxmox_backup_job" "pbs_daily_backup" {
  id       = "pbs-daily-backup"
  storage  = proxmox_storage_pbs.pbs_lxc.id
  schedule = "02:00"
  mode     = "snapshot"
  all      = true

  mailnotification = "always"
  mailto           = [data.doppler_secrets.this.map.HOMELAB_EMAIL]
  compress         = "zstd"

  prune_backups = {
    keep-last   = "7"
    keep-daily  = "7"
    keep-weekly = "4"
  }
}

# 挂载 NFS 存储
resource "proxmox_storage_nfs" "pbstorage" {
  id      = "pbstorage"
  server  = "192.168.50.76"
  export  = "/mnt/tank/pbstorage"
  content = ["iso", "backup", "rootdir", "images", "vztmpl", "snippets"]
}
