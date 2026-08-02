locals {
  talos_version = "v1.13.7"
  talos_iso_url = "https://github.com/siderolabs/talos/releases/download/${local.talos_version}/metal-amd64.iso"
}

# 1. 下载 Talos ISO 到 r720 的 local 存储
resource "proxmox_virtual_environment_download_file" "talos_iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "r720"

  url       = local.talos_iso_url
  file_name = "talos-${local.talos_version}-amd64.iso"
}

# 2. 部署 Control Plane 虚拟机
resource "proxmox_virtual_environment_vm" "talos_cp_01" {
  name      = "talos-cp-01"
  node_name = "r720"
  vm_id     = 801 

  lifecycle {
    ignore_changes = [
      node_name,
      ipv4_addresses,
      mac_addresses,
      cdrom,
    ]
  }

  agent {
    enabled = true
  }

  # 关键修复 1：明确指定启动顺序，先尝试从 CDROM (ide2) 启动，再从硬盘 (scsi0) 启动
  boot_order = ["ide2", "scsi0"]

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "Ceph-pool"
    interface    = "scsi0"
    size         = 40
    file_format  = "raw"
    discard      = "on"
  }

  cdrom {
    enabled   = true
    file_id   = proxmox_virtual_environment_download_file.talos_iso.id
    interface = "ide2"
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26" 
  }

  # 关键修复 2：因为我们指定了 efi_disk，必须明确指定主板 BIOS 类型为 UEFI (OVMF)
  bios = "ovmf"

  efi_disk {
    datastore_id = "Ceph-pool"
    file_format  = "raw"
    type         = "4m"
  }

  vga {
    type = "serial0"
  }
  serial_device {}
}

output "talos_cp_01_id" {
  value = proxmox_virtual_environment_vm.talos_cp_01.id
}
