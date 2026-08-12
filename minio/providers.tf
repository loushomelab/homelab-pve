terraform {
  required_version = ">= 1.15.0"

  cloud {
    organization = "loushomelab"

    workspaces {
      name = "homelab-pve-minio"
    }
  }

  required_providers {
    doppler = {
      source  = "dopplerhq/doppler"
      version = "~> 1.21.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "~> 3.40.1"
    }
  }
}

provider "doppler" {}

data "doppler_secrets" "this" {
  config  = "prd"
  project = "k8s"
}
