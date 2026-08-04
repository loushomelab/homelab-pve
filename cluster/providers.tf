terraform {
  required_version = ">= 1.15.0"

  cloud {
    organization = "loushomelab" # Please change this if your HCP organization name is different

    workspaces {
      name = "homelab-pve-cluster"
    }
  }

  required_providers {
    doppler = {
      source  = "dopplerhq/doppler"
      version = "~> 1.7.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.25.0"
    }

    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.61.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24.0"
    }
  }
}

provider "proxmox" {
  # Configuration options are best passed via environment variables in HCP Terraform:
  # PROXMOX_VE_ENDPOINT (e.g. https://192.168.1.x:8006/) - Suggest using an HA IP/Load Balancer IP or just one stable node
  # PROXMOX_VE_API_TOKEN (e.g. root@pam!terraform=...)
  insecure = true
}

provider "doppler" {
  # Doppler Token should be provided via HCP Terraform Environment Variable: DOPPLER_TOKEN
}

