output "homelab_ansible_clone_url" {
  description = "Forgejo internal clone URL"
  value       = gitea_repository.homelab_ansible.clone_url
}
