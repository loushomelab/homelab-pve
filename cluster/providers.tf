terraform {
  required_version = ">= 1.15.0"

  cloud {
    organization = "loushomelab" # Please change this if your HCP organization name is different

    workspaces {
      name = "homelab-pve"
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

    minio = {
      source  = "aminueza/minio"
      version = "~> 3.40.1"
    }

    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.111.1"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.7.0"
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

# 全局 Doppler 数据源，避免多文件并发重复请求 Doppler API
data "doppler_secrets" "this" {
  config  = "prd"
  project = "k8s"
}


