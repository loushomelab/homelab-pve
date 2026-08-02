terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.61.0"
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
      cdrom,
    ]
  }

  agent {
    enabled = false
  }

  boot_order = ["ide2", "scsi0"]

  # 关键：如果在某些节点上 KVM 硬件虚拟化不可用，可以通过 kvm_arguments 禁用硬件加速并使用 TCG，
  # 或者更简单的方法是查阅 Proxmox 配置，但由于 Terraform provider 不直接支持关闭硬件加速的布尔值，
  # 这个报错表明 3960x 节点本身的 BIOS 中虚拟化没有开启。
  
  cpu {
    cores = var.cores
    type  = "host"
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = 40
    file_format  = "raw"
    discard      = "on"
  }

  cdrom {
    enabled   = true
    file_id   = var.iso_file_id
    interface = "ide2"
  }

  network_device {
    bridge      = "vmbr0"
    mac_address = var.mac_address
  }

  operating_system {
    type = "l26"
  }

  bios = "ovmf"

  efi_disk {
    datastore_id = var.datastore_id
    file_format  = "raw"
    type         = "4m"
  }

  vga {
    type = "serial0"
  }
  serial_device {}
}
