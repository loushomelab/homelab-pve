# Tailscale subnet router advertises only 192.168.50.230/32 with
# --snat-subnet-routes=false so Traefik sees client IP 100.102.152.24.
# 192.168.50.140 is static: UniFi DHCP is off for 192.168.50.0/23,
# MetalLB uses .230-.250, and nothing answered ARP on .140.
# homelab-ansible playbooks/tailscale-router.yaml configures Tailscale using
# an OAuth client secret from Doppler; Terraform never handles that secret.
# UniFi needs a return route: 100.102.152.24/32 via 192.168.50.140.
# If grokbot-box rejoins with a new IP, reassign 100.102.152.24 in the
# Tailscale admin console; no Terraform change is needed.
resource "proxmox_download_file" "debian_cloud_image" {
  node_name          = "r720"
  datastore_id       = "local"
  content_type       = "iso"
  url                = "https://cloud.debian.org/images/cloud/trixie/20261103-2651/debian-13-genericcloud-amd64-20261103-2651.qcow2"
  file_name          = "debian-13-genericcloud-amd64-20261103-2651.img"
  checksum           = "d25999de0770d4cde1be72c299ba3ad94eac7ea8fd4d18f8cc86c69df69337e2e8a91d64465a9bfd8f2a78c566fcbcb0842eacc91c09efdef72d719d9f13b535"
  checksum_algorithm = "sha512"
  overwrite          = false
}

resource "proxmox_virtual_environment_vm" "tailscale_router" {
  name          = "tailscale-router"
  node_name     = "r720"
  vm_id         = 140
  started       = true
  on_boot       = true
  scsi_hardware = "virtio-scsi-pci"

  agent {
    enabled = false
  }

  cpu {
    cores = 1
    type  = "host"
  }

  memory {
    dedicated = 1024
  }

  disk {
    datastore_id = "SSD"
    file_id      = proxmox_download_file.debian_cloud_image.id
    interface    = "scsi0"
    size         = 8
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge      = "vmbr0"
    model       = "virtio"
    mac_address = "BC:24:11:00:03:01"
  }

  serial_device {}

  vga {
    type = "serial0"
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = "SSD"

    ip_config {
      ipv4 {
        address = "192.168.50.140/24"
        gateway = "192.168.50.1"
      }
    }

    dns {
      servers = ["192.168.50.231"]
      domain  = "home.arpa"
    }

    user_account {
      username = "lou"
      keys     = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEfrVTvGfg2PZzFfdlzvaycPdiYW7G8PhXE0ob2XM/NU Mac-Studio"]
    }
  }
}
