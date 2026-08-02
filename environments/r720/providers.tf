terraform {
  required_version = ">= 1.15.0"

  cloud {
    organization = "loushomelab" # Please change this if your HCP organization name is different

    workspaces {
      name = "homelab-pve-r720"
    }
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.61.0"
    }
  }
}

provider "proxmox" {
  # Configuration options are best passed via environment variables in HCP Terraform:
  # PROXMOX_VE_ENDPOINT (e.g. https://192.168.1.x:8006/)
  # PROXMOX_VE_API_TOKEN (e.g. root@pam!terraform=...)
  insecure = true
}
