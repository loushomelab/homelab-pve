import {
  to = proxmox_download_file.talos_iso["r720"]
  id = "r720/local/iso/talos-v1.13.7-nocloud-qga-amd64.iso"
}

import {
  to = proxmox_download_file.talos_iso["1920x"]
  id = "1920x/local/iso/talos-v1.13.7-nocloud-qga-amd64.iso"
}

import {
  to = proxmox_download_file.talos_iso["3960x"]
  id = "3960x/local/iso/talos-v1.13.7-nocloud-qga-amd64.iso"
}

import {
  to = module.talos_cp["cp-01"].proxmox_virtual_environment_vm.this
  id = "r720/801"
}

import {
  to = module.talos_cp["cp-02"].proxmox_virtual_environment_vm.this
  id = "1920x/802"
}

import {
  to = module.talos_cp["cp-03"].proxmox_virtual_environment_vm.this
  id = "3960x/803"
}

import {
  to = module.talos_worker["worker-01"].proxmox_virtual_environment_vm.this
  id = "r720/811"
}

import {
  to = module.talos_worker["worker-02"].proxmox_virtual_environment_vm.this
  id = "1920x/812"
}

import {
  to = module.talos_worker["worker-03"].proxmox_virtual_environment_vm.this
  id = "3960x/813"
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
