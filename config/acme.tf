# ACME Cloudflare DNS-01 质询插件配置
resource "proxmox_acme_dns_plugin" "qqxyz" {
  plugin           = "qqxyz"
  api              = "cf"
  validation_delay = 30

  data = {
    CF_Token      = data.doppler_secrets.this.map.CLOUDFLARE_API_TOKEN
    CF_Account_ID = data.doppler_secrets.this.map.CLOUDFLARE_ACCOUNT_ID
  }
}
