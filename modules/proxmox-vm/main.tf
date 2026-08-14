terraform {
  required_version = ">= 1.5.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.111.1"
    }
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  name      = var.name
  node_name = var.node_name
  vm_id     = var.vm_id

  lifecycle {
    ignore_changes = [
      node_name,
      agent,
    ]
  }

  # 显式确保创建后处于开机状态
  started = true

  # 禁用 QEMU Agent 探测，避免 Day 0 未启动 Agent 时 Proxmox Provider 在 Refresh/Plan 阶段轮询超时
  agent {
    enabled = false
  }

  boot_order = ["scsi0", "ide2"]

  cpu {
    cores = var.cores
    # 全部恢复为 host，因为 3960x 已经开启了硬件虚拟化
    type = "host"
  }

  memory {
    dedicated = var.memory
  }

  scsi_hardware = "virtio-scsi-pci" # Ensure VirtIO SCSI (NOT Single)

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = 40
    file_format  = "raw"
    discard      = "on"
    cache        = "writethrough"
    ssd          = true
  }

  cdrom {
    file_id   = var.iso_file_id
    interface = "ide2"
  }

  network_device {
    bridge      = "vmbr0"
    mac_address = var.mac_address
    model       = "virtio"
  }

  operating_system {
    type = "l26"
  }

  bios    = "ovmf"
  machine = "q35"

  efi_disk {
    datastore_id = var.datastore_id
    file_format  = "raw"
    type         = "4m"
  }

  vga {
    type = "std"
  }
  serial_device {}
}
