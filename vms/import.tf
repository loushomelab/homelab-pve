import {
  to = proxmox_download_file.talos_iso["r720"]
  id = "r720/local:iso/talos-v1.13.7-nocloud-qga-amd64.iso"
}

import {
  to = proxmox_download_file.talos_iso["1920x"]
  id = "1920x/local:iso/talos-v1.13.7-nocloud-qga-amd64.iso"
}

import {
  to = proxmox_download_file.talos_iso["3960x"]
  id = "3960x/local:iso/talos-v1.13.7-nocloud-qga-amd64.iso"
}

import {
  to = proxmox_storage_pbs.pbs_lxc
  id = "pbs-lxc"
}

import {
  to = proxmox_backup_job.pbs_daily_backup
  id = "pbs-daily-backup"
}

import {
  to = proxmox_storage_nfs.pbstorage
  id = "pbstorage"
}
