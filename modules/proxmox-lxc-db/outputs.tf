output "ipv4_address" {
  value = split("/", var.ipv4_address)[0]
}

output "vmid" {
  value = proxmox_virtual_environment_container.this.vm_id
}

output "node_name" {
  value = proxmox_virtual_environment_container.this.node_name
}
