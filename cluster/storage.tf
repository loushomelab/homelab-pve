# ==============================================================================
# 📦 Proxmox Backup Server (PBS) Datastore - iSCSI & LVM Cluster Storage
# ==============================================================================
# This configuration defines the shared block storage for the PBS LXC container.
# It enables high-availability (HA) and live migration (drift) of the PBS LXC
# between different nodes in the PVE cluster by utilizing LVM-on-iSCSI.

resource "proxmox_virtual_environment_storage" "pbs_iscsi" {
  storage_id    = "pbstorage-iscsi"
  nodes         = ["n100x8", "r720", "1920x", "3960x"]
  content_types = ["images"]

  iscsi {
    portal = "192.168.50.76:3260"
    target = "iqn.2005-10.org.freenas.ctl:pbstorage"
  }
}

resource "proxmox_virtual_environment_storage" "pbs_lvm" {
  storage_id    = "pbstorage-lvm"
  nodes         = ["n100x8", "r720", "1920x", "3960x"]
  content_types = ["images", "rootdir"]

  lvm {
    vg_name     = "pbstorage-vg"
    base_volume = proxmox_virtual_environment_storage.pbs_iscsi.storage_id
    shared      = true
  }
}
