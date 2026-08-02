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

  # 关闭 3960x 的 KVM 硬件虚拟化 (通过 machine 块的设置)
  machine = var.node_name == "3960x" ? "q35" : ""
  
  # 由于无法加载 kvm_amd，必须显式在操作系统配置里告诉 Proxmox 不要用 KVM
  operating_system {
    type = "l26"
  }
  
  # 虽然 terraform-provider-proxmox 没有 boolean 的 kvm = false
  # 但设置了 cpu_type 为 kvm64 (非 host) 并且 accel=tcg 会好些
  # 在 3960x 上使用 qemu64 替代 host，以防止尝试使用宿主机不支持的虚拟化指令
  cpu {
    cores = var.cores
    type  = var.node_name == "3960x" ? "qemu64" : "host"
  }
  
  # 我们需要通过 kvm_arguments 强行关闭它
  kvm_arguments = var.node_name == "3960x" ? "-machine accel=tcg" : ""

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
