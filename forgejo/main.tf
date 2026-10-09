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

resource "gitea_repository" "dotfiles" {
  username    = "loushomelab"
  name        = "dotfiles"
  description = "Personal Dotfiles (Managed via Chezmoi)"
  private     = true
  auto_init   = false

  has_issues   = false
  has_wiki     = false
  has_projects = false
}

resource "gitea_org" "apple_work" {
  name        = "apple-work"
  description = "Apple Work"
  visibility  = "private"
}

resource "gitea_repository" "apple_work_testcandy" {
  username    = gitea_org.apple_work.name
  name        = "testcandy"
  description = "TestCandy macOS Native App"
  private     = true
  auto_init   = false

  has_issues   = false
  has_wiki     = false
  has_projects = false
}
