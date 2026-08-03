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
    enabled = true
  }

  boot_order = ["ide2", "scsi0"]

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
    enabled   = true
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
    type = "serial0"
  }
  serial_device {}
}
