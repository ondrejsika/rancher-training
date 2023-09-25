terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.16.0"
    }
  }
}

variable "digitalocean_token" {}
variable "base_domain" {}

variable "node_count" {
  default = 3
}

variable "node_image" {
  default = "docker-20-04"
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

data "digitalocean_domain" "default" {
  name = var.base_domain
}

resource "digitalocean_droplet" "node" {
  count = var.node_count

  image  = var.node_image
  name   = "node${count.index}"
  region = "fra1"
  size   = "s-2vcpu-2gb"
  ssh_keys = [
    data.digitalocean_ssh_key.default.id
  ]
  tags      = ["bm-node"]
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

resource "digitalocean_record" "node" {
  count = var.node_count

  domain = data.digitalocean_domain.default.name
  type   = "A"
  name   = "node${count.index}"
  value  = digitalocean_droplet.node[count.index].ipv4_address
}

resource "digitalocean_loadbalancer" "demo" {
  name   = "bm-demo"
  region = "fra1"

  droplet_tag = "bm-node"

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

resource "digitalocean_record" "k8s" {
  domain = data.digitalocean_domain.default.name
  type   = "A"
  name   = "k8s"
  value  = digitalocean_loadbalancer.demo.ip
}

resource "digitalocean_record" "k8s_wildcard" {
  domain = data.digitalocean_domain.default.name
  type   = "CNAME"
  name   = "*.${digitalocean_record.k8s.name}"
  value  = "${digitalocean_record.k8s.fqdn}."
}

output "k8s_base_domain" {
  value = digitalocean_record.k8s.fqdn
}
