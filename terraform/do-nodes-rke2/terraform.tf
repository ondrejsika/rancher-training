terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.16.0"
    }
  }
}

variable "digitalocean_token" {}

variable "node_count" {
  default = 3
}

variable "node_image" {
  default = "debian-12-x64"
}

variable "ssh_key_name" {
  default = "default"
}

provider "digitalocean" {
  token = var.digitalocean_token
}

data "digitalocean_ssh_key" "default" {
  name = var.ssh_key_name
}

resource "digitalocean_droplet" "node" {
  count = var.node_count

  image  = var.node_image
  name   = "rke2-${count.index}"
  region = "fra1"
  size   = "s-2vcpu-2gb"
  ssh_keys = [
    data.digitalocean_ssh_key.default.id
  ]
  tags      = ["rke2-node"]
  user_data = <<EOF
#cloud-config
ssh_pwauth: yes
password: asdfasdf2020
chpasswd:
  expire: false
runcmd:
  - |
    apt-get update
    apt-get install -y curl sudo git
    systemctl stop ufw
    systemctl disable ufw
EOF
}

resource "digitalocean_loadbalancer" "demo" {
  name   = "rke2-demo"
  region = "fra1"

  droplet_tag = "rke2-node"

  healthcheck {
    port     = 80
    protocol = "tcp"
  }

  forwarding_rule {
    entry_port      = 80
    target_port     = 80
    entry_protocol  = "tcp"
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port      = 443
    target_port     = 443
    entry_protocol  = "tcp"
    target_protocol = "tcp"
  }
}
output "node_ips" {
  value = [
    for node in digitalocean_droplet.node :
    node.ipv4_address
  ]
}

output "lb_ip" {
  value = digitalocean_loadbalancer.demo.ip
}
