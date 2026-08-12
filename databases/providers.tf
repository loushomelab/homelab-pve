terraform {
  required_version = ">= 1.15.0"

  cloud {
    organization = "loushomelab"

    workspaces {
      name = "homelab-pve-databases"
    }
  }

  required_providers {
    doppler = {
      source  = "dopplerhq/doppler"
      version = "~> 1.21.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.25.0"
    }
  }
}

provider "doppler" {}

data "doppler_secrets" "this" {
  config  = "prd"
  project = "k8s"
}
