variable "do_token" {}

variable "node_count" {
  default = 3
}

variable "node_image" {
  default = "rancheros"
}

variable "ssh_key_name" {
  default = "default"
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "default" {
  name = var.ssh_key_name
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
  tags = ["rke-node"]
}

resource "digitalocean_loadbalancer" "demo" {
  name = "rke-demo"
  region = "fra1"

  droplet_tag = "rke-node"

  healthcheck {
    port = 30001
    protocol = "tcp"
  }

  forwarding_rule {
    entry_port  = 80
    target_port = 30001
    entry_protocol = "tcp"
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port  = 443
    target_port = 30002
    entry_protocol = "tcp"
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port  = 8080
    target_port = 30003
    entry_protocol = "tcp"
    target_protocol = "tcp"
  }
}

output "node_ips" {
  value = [
    for node in digitalocean_droplet.node:
      node.ipv4_address
  ]
}

output "lb_ip" {
  value = digitalocean_loadbalancer.demo.ip
}
