import {
  to = postgresql_role.authentik
  id = data.doppler_secrets.this.map.AUTHENTIK_POSTGRESQL__USER
}

import {
  to = postgresql_database.authentik
  id = data.doppler_secrets.this.map.AUTHENTIK_POSTGRESQL__NAME
}

import {
  to = postgresql_role.grafana
  id = data.doppler_secrets.this.map.GRAFANA_POSTGRESQL__USER
}

import {
  to = postgresql_database.grafana
  id = data.doppler_secrets.this.map.GRAFANA_POSTGRESQL__NAME
}

import {
  to = postgresql_role.umami
  id = data.doppler_secrets.this.map.UMAMI_POSTGRESQL__USER
}

import {
  to = postgresql_database.umami
  id = data.doppler_secrets.this.map.UMAMI_POSTGRESQL__NAME
}
