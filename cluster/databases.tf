# ==============================================================================
# 🔐 Secrets via Doppler
# ==============================================================================
data "doppler_secrets" "db" {
  config  = "prd_terraform"
  project = "k8s"
}

# ==============================================================================
# 🐘 PostgreSQL Roles & Databases
# ==============================================================================
# NOTE: The LXC containers (151 and 152) are pre-created manually via Proxmox 
# Turnkey scripts (or similar). Terraform is only taking over the DB logical resources.

# --- Auth DB Provider (192.168.50.151) ---
provider "postgresql" {
  alias    = "auth"
  host     = "192.168.50.151"
  port     = 5432
  database = "postgres"
  username = "postgres"
  password = data.doppler_secrets.db.map.DB_INFRA_PG_PASSWORD
  sslmode  = "disable"
}

resource "postgresql_role" "authentik" {
  provider = postgresql.auth
  name     = "authentik"
  login    = true
  password = data.doppler_secrets.db.map.AUTHENTIK_DB_PASSWORD
}

resource "postgresql_database" "authentik" {
  provider = postgresql.auth
  name     = "authentik"
  owner    = postgresql_role.authentik.name
}

# --- Obs DB Provider (192.168.50.152) ---
provider "postgresql" {
  alias    = "obs"
  host     = "192.168.50.152"
  port     = 5432
  database = "postgres"
  username = "postgres"
  password = data.doppler_secrets.db.map.DB_INFRA_PG_PASSWORD
  sslmode  = "disable"
}

resource "postgresql_role" "grafana" {
  provider = postgresql.obs
  name     = "grafana"
  login    = true
  password = data.doppler_secrets.db.map.DB_OBS_PG_PASSWORD
}

resource "postgresql_database" "grafana" {
  provider = postgresql.obs
  name     = "grafana"
  owner    = postgresql_role.grafana.name
}

resource "postgresql_role" "umami" {
  provider = postgresql.obs
  name     = "umami"
  login    = true
  password = data.doppler_secrets.db.map.DB_UMAMI_PG_PASSWORD
}

resource "postgresql_database" "umami" {
  provider = postgresql.obs
  name     = "umami"
  owner    = postgresql_role.umami.name
}
