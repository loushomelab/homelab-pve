locals {
  talos_version = "v1.13.7"
  talos_iso_url = "https://github.com/siderolabs/talos/releases/download/${local.talos_version}/talos-amd64.iso"
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
  vm_id     = 801 # 给 CP 节点预留一个号段，比如 80x

  # 关键：忽略因为 HA 漂移导致的 node 变更，以及 DHCP/光驱 等状态变更
  lifecycle {
    ignore_changes = [
      node_name,
      ipv4_addresses,
      mac_addresses,
      cdrom, # 忽略光驱变化，允许您在系统装好后手动弹出光驱
    ]
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  # 根据您的 r720 存储，这里选择 SSD (zfspool) 作为系统盘
  disk {
    datastore_id = "SSD"
    interface    = "scsi0"
    size         = 40
    file_format  = "raw"
    discard      = "on" # 开启 SSD TRIM 支持
  }

  # 挂载 Talos 安装镜像
  cdrom {
    enabled   = true
    file_id   = proxmox_virtual_environment_download_file.talos_iso.id
    interface = "ide2"
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26" # Linux kernel
  }

  # UEFI 引导 (Talos 推荐) 需要一个 EFI 磁盘
  efi_disk {
    datastore_id = "SSD"
    file_format  = "raw"
    type         = "4m"
  }

  # 开启串口，Talos 的日志会输出到串口，方便调试
  vga {
    type = "serial0"
  }
  serial_device {}
}

output "talos_cp_01_id" {
  value = proxmox_virtual_environment_vm.talos_cp_01.id
}
