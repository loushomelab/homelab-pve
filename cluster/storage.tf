# ==============================================================================
# 📦 Proxmox Backup Server (PBS) Datastore - LVM Cluster Storage
# ==============================================================================
# This configuration defines the shared LVM block storage for the PBS LXC container.
# It enables high-availability (HA) and live migration (drift) of the PBS LXC
# between different nodes in the PVE cluster by utilizing LVM-on-iSCSI.
#
# NOTE: The base iSCSI storage ("pbstorage-iscsi") has been manually configured
# on the PVE host via 'pvesm add' to handle the iSCSI portal logins natively.

resource "proxmox_storage_lvm" "pbs_lvm" {
  id           = "pbstorage-lvm"
  nodes        = ["n100x8", "r720", "1920x", "3960x"]
  volume_group = "pbstorage-vg"
  content      = ["images", "rootdir"]
  shared       = true
}
