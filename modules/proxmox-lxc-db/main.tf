terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.61.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "proxmox_virtual_environment_file" "vendor_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_name

  source_raw {
    data      = <<-EOT
      #cloud-config
      runcmd:
        - apt-get update
        - apt-get install -y postgresql postgresql-contrib redis-server
        - systemctl enable postgresql redis-server
        # Configure PostgreSQL to listen on all interfaces
        - sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/15/main/postgresql.conf
        # Allow internal network to access PostgreSQL
        - echo "host all all 192.168.50.0/23 md5" >> /etc/postgresql/15/main/pg_hba.conf
        # Set postgres user password
        - sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${var.postgres_password}';"
        # Configure Redis if password is provided
        - |
          if [ -n "${var.redis_password}" ]; then
            sed -i "s/bind 127.0.0.1 -::1/bind 0.0.0.0/g" /etc/redis/redis.conf
            sed -i 's/# requirepass foobared/requirepass ${var.redis_password}/g' /etc/redis/redis.conf
          fi
        # Restart services
        - systemctl restart postgresql redis-server
    EOT
    file_name = "vendor-db-${var.vmid}.yaml"
  }
}

resource "proxmox_virtual_environment_container" "this" {
  name      = var.name
  node_name = var.node_name
  vm_id     = var.vmid

  initialization {
    hostname = var.name

    # Inject our cloud-init vendor script
    user_data_file_id = proxmox_virtual_environment_file.vendor_config.id

    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = "192.168.50.254"
      }
    }
  }

  disk {
    datastore_id = var.datastore_id
    size         = var.disk_size
  }

  network_interface {
    name        = "eth0"
    bridge      = "vmbr0"
    mac_address = var.mac_address
  }

  operating_system {
    template_file_id = var.template_file_id
    type             = "debian"
  }

  features {
    nesting = true
  }

  unprivileged = true
}
