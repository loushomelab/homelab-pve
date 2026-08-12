terraform {
  required_version = ">= 1.15.0"

  cloud {
    organization = "loushomelab"

    workspaces {
      name = "homelab-pve-vms"
    }
  }

  required_providers {
    doppler = {
      source  = "dopplerhq/doppler"
      version = "~> 1.21.0"
    }

    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.111.1"
    }
  }
}

provider "proxmox" {
  endpoint  = data.doppler_secrets.this.map.PROXMOX_VE_ENDPOINT
  api_token = data.doppler_secrets.this.map.PROXMOX_VE_API_TOKEN
  insecure  = true
}

provider "doppler" {}

data "doppler_secrets" "this" {
  config  = "prd"
  project = "k8s"
}
