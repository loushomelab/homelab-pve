# ==============================================================================
# 🐙 Forgejo Pull Mirror Repositories
# ==============================================================================

resource "gitea_repository" "homelab_ansible" {
  username                     = "loushomelab"
  name                         = "homelab-ansible"
  description                  = "Homelab Ansible Infrastructure (Automated Pull Mirror from GitHub)"
  private                      = true
  mirror                       = true
  migration_mirror_interval    = "1h"
  migration_service            = "github"
  migration_clone_address      = "https://github.com/loushomelab/homelab-ansible.git"
  migration_service_auth_token = data.doppler_secrets.this.map.GITHUB_PAT

  has_issues   = false
  has_wiki     = false
  has_projects = false
}
