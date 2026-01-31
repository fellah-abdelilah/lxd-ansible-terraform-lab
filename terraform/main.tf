terraform {
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "~> 2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "lxd" {}

############################
# CONTENEUR WEB
############################
resource "lxd_instance" "web01" {
  name  = "web01"
  image = "ubuntu:22.04"
  type  = "container"

  limits = {
    cpu    = "1"
    memory = "512MB"
  }

  config = {
    "cloud-init.user-data" = <<EOF
#cloud-config
ssh_authorized_keys:
  - ${trimspace(file("~/.ssh/id_ed25519.pub"))}
EOF
  }
}

############################
# CONTENEUR DB
############################
resource "lxd_instance" "db01" {
  name  = "db01"
  image = "ubuntu:22.04"
  type  = "container"

  limits = {
    cpu    = "1"
    memory = "512MB"
  }

  config = {
    "cloud-init.user-data" = <<EOF
#cloud-config
ssh_authorized_keys:
  - ${trimspace(file("~/.ssh/id_ed25519.pub"))}
EOF
  }
}

############################
# OUTPUTS
############################
output "web01_ip" {
  value = lxd_instance.web01.ipv4_address
}

output "db01_ip" {
  value = lxd_instance.db01.ipv4_address
}

############################
# INVENTORY ANSIBLE AUTO
############################
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory"

  content = templatefile("${path.module}/inventory.tpl", {
    web01_ip = lxd_instance.web01.ipv4_address
    db01_ip  = lxd_instance.db01.ipv4_address
  })
}
