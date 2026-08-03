output "vm_id" {
  value = proxmox_virtual_environment_vm.this.id
}

output "ipv4_addresses" {
  description = "The IPv4 addresses reported by the QEMU guest agent"
  value       = proxmox_virtual_environment_vm.this.ipv4_addresses
}

output "mac_address" {
  description = "The MAC address of the VM"
  value       = proxmox_virtual_environment_vm.this.network_device[0].mac_address
}
