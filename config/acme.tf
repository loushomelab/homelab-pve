# 1. ACME 账户配置 (Let's Encrypt)
resource "proxmox_acme_account" "homelab" {
  name      = "homelab"
  contact   = "mailto:${data.doppler_secrets.this.map.HOMELAB_EMAIL}"
  directory = "https://acme-v02.api.letsencrypt.org/directory"
}

# 2. ACME Cloudflare DNS-01 质询插件配置
resource "proxmox_acme_dns_plugin" "qqxyz" {
  plugin = "qqxyz"
  api    = "cf"

  data = {
    CF_Token      = data.doppler_secrets.this.map.CLOUDFLARE_API_TOKEN
    CF_Account_ID = data.doppler_secrets.this.map.CLOUDFLARE_ACCOUNT_ID
  }

  validation_delay = 30
}
