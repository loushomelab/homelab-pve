output "homelab_ansible_clone_url" {
  description = "Forgejo internal clone URL"
  value       = gitea_repository.homelab_ansible.clone_url
}

output "dotfiles_clone_url" {
  description = "Forgejo internal clone URL for dotfiles"
  value       = gitea_repository.dotfiles.clone_url
}
