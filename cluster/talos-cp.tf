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

  # 修复 2：关闭 QEMU Guest Agent，Talos 在初始化完成前或未显式开启时，不会提供 agent 响应。
  # 关闭它会让 Terraform 在发出创建命令后立即返回成功，而不再死等。
  agent {
    enabled = false
  }

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
