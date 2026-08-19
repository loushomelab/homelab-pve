# 1. 持久化声明 OpenID Connect 认证领域 (Authentik Realm)
resource "proxmox_realm_openid" "authentik" {
  realm      = "authentik"
  issuer_url = "https://authentik.646499453.xyz:8443/application/o/proxmox-ve/"
  client_id  = "proxmox-ve"
  client_key = data.doppler_secrets.this.map.AUTHENTIK_OIDC_PROXMOX_SECRET

  # 用户名映射（使用 preferred_username / username）
  username_claim = "username"
  autocreate     = true

  # 组声明与同步设置
  scopes            = "openid email profile groups"
  groups_claim      = "groups"
  groups_autocreate = true
  groups_overwrite  = true
  query_userinfo    = true
  comment           = "Authentik SSO Managed by Terraform"
}

# 2. 持久化声明 Authentik 管理员组
# 注意：Proxmox VE 在同步 OIDC 组时会自动追加 "-<realm>" 后缀（即 -authentik）
resource "proxmox_virtual_environment_group" "authentik_admins" {
  group_id = "authentik-admins-authentik"
  comment  = "Authentik Administrators - Managed by Terraform"
}

# 3. 持久化赋予管理员组在 "/" 路径下的 Administrator 权限（开启传播）
resource "proxmox_acl" "authentik_admins_admin" {
  path      = "/"
  group_id  = proxmox_virtual_environment_group.authentik_admins.group_id
  role_id   = "Administrator"
  propagate = true
}
