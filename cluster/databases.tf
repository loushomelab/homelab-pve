# ==============================================================================
# 💽 Database LXC Templates
# ==============================================================================
resource "proxmox_virtual_environment_download_file" "debian13_lxc" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = "r720" # Default node for template download

  url       = "http://download.proxmox.com/images/system/debian-13-standard_13.0-1_amd64.tar.zst"
  file_name = "debian-13-standard.tar.zst"
}

# ==============================================================================
# 🔐 Secrets via Doppler
# ==============================================================================
data "doppler_secrets" "db" {
  config  = "prd_terraform"
  project = "k8s"
}

# Load SSH public key from local file (Assumes you have one configured)

# ==============================================================================
# 🛠️ LXC Database Containers
# ==============================================================================

# 1. Auth DB (PostgreSQL + Redis)
module "lxc_db_auth" {
  source = "../modules/proxmox-lxc-db"

  name             = "lxc-db-auth"
  node_name        = "r720"
  vmid             = 151
  ipv4_address     = "192.168.50.151/23"
  mac_address      = "BC:24:11:63:12:11"
  datastore_id     = "SSD"
  template_file_id = proxmox_virtual_environment_download_file.debian13_lxc.id

  postgres_password = data.doppler_secrets.db.map.DB_INFRA_PG_PASSWORD
  redis_password    = data.doppler_secrets.db.map.DB_INFRA_REDIS_PASSWORD
  ssh_public_key    = var.HOMELAB_CICD_SSH_PUBLIC_KEY
  ssh_private_key   = var.HOMELAB_CICD_SSH_PRIVATE_KEY
}

# 2. Obs DB (PostgreSQL Only)
module "lxc_db_obs" {
  source = "../modules/proxmox-lxc-db"

  name             = "lxc-db-obs"
  node_name        = "1920x" # Can be placed on another node for distribution
  vmid             = 152
  ipv4_address     = "192.168.50.152/23"
  mac_address      = "BC:24:11:63:12:13"
  datastore_id     = "SSD"
  template_file_id = proxmox_virtual_environment_download_file.debian13_lxc.id

  postgres_password = data.doppler_secrets.db.map.DB_INFRA_PG_PASSWORD
  redis_password    = "" # Empty redis_password skips Redis external configuration
  ssh_public_key    = var.HOMELAB_CICD_SSH_PUBLIC_KEY
  ssh_private_key   = var.HOMELAB_CICD_SSH_PRIVATE_KEY
}

# ==============================================================================
# 🐘 PostgreSQL Roles & Databases
# ==============================================================================

# --- Auth DB Provider ---
provider "postgresql" {
  alias    = "auth"
  host     = module.lxc_db_auth.ipv4_address
  port     = 5432
  database = "postgres"
  username = "postgres"
  password = data.doppler_secrets.db.map.DB_INFRA_PG_PASSWORD
  sslmode  = "disable"
}

resource "postgresql_role" "authentik" {
  provider   = postgresql.auth
  name       = "authentik"
  login      = true
  password   = data.doppler_secrets.db.map.AUTHENTIK_DB_PASSWORD
  depends_on = [module.lxc_db_auth]
}

resource "postgresql_database" "authentik" {
  provider   = postgresql.auth
  name       = "authentik"
  owner      = postgresql_role.authentik.name
  depends_on = [postgresql_role.authentik]
}

# --- Obs DB Provider ---
provider "postgresql" {
  alias    = "obs"
  host     = module.lxc_db_obs.ipv4_address
  port     = 5432
  database = "postgres"
  username = "postgres"
  password = data.doppler_secrets.db.map.DB_INFRA_PG_PASSWORD
  sslmode  = "disable"
}

resource "postgresql_role" "grafana" {
  provider   = postgresql.obs
  name       = "grafana"
  login      = true
  password   = data.doppler_secrets.db.map.DB_OBS_PG_PASSWORD
  depends_on = [module.lxc_db_obs]
}

resource "postgresql_database" "grafana" {
  provider   = postgresql.obs
  name       = "grafana"
  owner      = postgresql_role.grafana.name
  depends_on = [postgresql_role.grafana]
}

resource "postgresql_role" "umami" {
  provider   = postgresql.obs
  name       = "umami"
  login      = true
  password   = data.doppler_secrets.db.map.DB_UMAMI_PG_PASSWORD
  depends_on = [module.lxc_db_obs]
}

resource "postgresql_database" "umami" {
  provider   = postgresql.obs
  name       = "umami"
  owner      = postgresql_role.umami.name
  depends_on = [postgresql_role.umami]
}
