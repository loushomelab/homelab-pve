# ==============================================================================
# 🐘 PostgreSQL Roles & Databases
# ==============================================================================
# NOTE: The LXC containers (151 and 152) are pre-created manually via Proxmox
# Turnkey scripts (or similar). Terraform is only taking over the DB logical resources.

# --- Auth DB Provider (192.168.50.151) ---
provider "postgresql" {
  alias    = "auth"
  host     = data.doppler_secrets.this.map.DB_AUTH_POSTGRESQL__HOST
  port     = 5432
  database = "postgres"
  username = "postgres"
  password = data.doppler_secrets.this.map.DB_AUTH_POSTGRESQL__PASSWORD
  sslmode  = "disable"
}

resource "postgresql_role" "authentik" {
  provider = postgresql.auth
  name     = data.doppler_secrets.this.map.AUTHENTIK_POSTGRESQL__USER
  login    = true
  password = data.doppler_secrets.this.map.AUTHENTIK_POSTGRESQL__PASSWORD
}

resource "postgresql_database" "authentik" {
  provider = postgresql.auth
  name     = data.doppler_secrets.this.map.AUTHENTIK_POSTGRESQL__NAME
  owner    = postgresql_role.authentik.name
}

# --- Obs DB Provider (192.168.50.152) ---
provider "postgresql" {
  alias    = "obs"
  host     = data.doppler_secrets.this.map.DB_OBS_POSTGRESQL__HOST
  port     = 5432
  database = "postgres"
  username = "postgres"
  password = data.doppler_secrets.this.map.DB_OBS_POSTGRESQL__PASSWORD
  sslmode  = "disable"
}

resource "postgresql_role" "grafana" {
  provider = postgresql.obs
  name     = data.doppler_secrets.this.map.GRAFANA_POSTGRESQL__USER
  login    = true
  password = data.doppler_secrets.this.map.GRAFANA_POSTGRESQL__PASSWORD
}

resource "postgresql_database" "grafana" {
  provider = postgresql.obs
  name     = data.doppler_secrets.this.map.GRAFANA_POSTGRESQL__NAME
  owner    = postgresql_role.grafana.name
}

resource "postgresql_role" "umami" {
  provider = postgresql.obs
  name     = data.doppler_secrets.this.map.UMAMI_POSTGRESQL__USER
  login    = true
  password = data.doppler_secrets.this.map.UMAMI_POSTGRESQL__PASSWORD
}

resource "postgresql_database" "umami" {
  provider = postgresql.obs
  name     = data.doppler_secrets.this.map.UMAMI_POSTGRESQL__NAME
  owner    = postgresql_role.umami.name
}
