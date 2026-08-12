terraform {
  required_version = ">= 1.15.0"

  cloud {
    organization = "loushomelab"

    workspaces {
      name = "homelab-pve-talos"
    }
  }

  required_providers {
    doppler = {
      source  = "dopplerhq/doppler"
      version = "~> 1.21.0"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.11.0"
    }
  }
}

provider "doppler" {}

# tflint-ignore: terraform_unused_declarations
data "doppler_secrets" "this" {
  config  = "prd"
  project = "k8s"
}
