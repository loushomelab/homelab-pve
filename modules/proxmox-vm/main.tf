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

  cpu {
    cores = var.cores
    # 这里我们只修改 CPU 模型为 qemu64
    type  = var.node_name == "3960x" ? "qemu64" : "host"
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
