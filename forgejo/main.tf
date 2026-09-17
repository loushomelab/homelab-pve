# ==============================================================================
# 🐙 Forgejo Repositories
# ==============================================================================

resource "gitea_repository" "homelab_ansible" {
  username    = "loushomelab"
  name        = "homelab-ansible"
  description = "Homelab Ansible Infrastructure"
  private     = true
  auto_init   = false

  has_issues   = false
  has_wiki     = false
  has_projects = false
}
