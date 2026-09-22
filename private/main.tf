locals {
  nixos_release    = "26.05.10402.1e8bc658fc98"
  nixos_iso_url    = "https://releases.nixos.org/nixos/26.05/nixos-${local.nixos_release}/nixos-minimal-${local.nixos_release}-x86_64-linux.iso"
  nixos_iso_sha256 = "759d63493bea33a2b320c1ec82d1fdf9a73c61c08e037a526bd364294ed9580f"
}

resource "proxmox_download_file" "nixos_minimal_iso" {
  content_type       = "iso"
  datastore_id       = "local"
  node_name          = "r720"
  file_name          = "nixos-minimal-${local.nixos_release}-x86_64-linux.iso"
  url                = local.nixos_iso_url
  checksum           = local.nixos_iso_sha256
  checksum_algorithm = "sha256"
  overwrite          = false
  upload_timeout     = 1800
}

module "private" {
  source = "../modules/proxmox-vm"

  name         = "private"
  node_name    = "r720"
  vm_id        = 100
  cores        = 4
  memory       = 8192
  disk_size    = 64
  datastore_id = "SSD"
  iso_file_id  = proxmox_download_file.nixos_minimal_iso.id
  mac_address  = "BC:24:11:00:02:01"

  additional_disks = {
    state = {
      interface = "scsi1"
      size      = 64
    }
  }
}
