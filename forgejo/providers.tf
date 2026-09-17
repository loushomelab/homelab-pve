terraform {
  required_version = ">= 1.15.0"

  cloud {
    organization = "loushomelab"

    workspaces {
      name = "homelab-pve-forgejo"
    }
  }

  required_providers {
    doppler = {
      source  = "dopplerhq/doppler"
      version = "~> 1.21.0"
    }
    gitea = {
      source  = "Lerentis/gitea"
      version = "~> 0.16.0"
    }
  }
}

provider "doppler" {}

data "doppler_secrets" "this" {
  config  = "prd"
  project = "k8s"
}

provider "gitea" {
  base_url = "https://forgejo.646499453.xyz:8443"
  token    = data.doppler_secrets.this.map.FORGEJO_ADMIN_TOKEN
}
