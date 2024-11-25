terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.16.0"
    }
  }
}

variable "digitalocean_token" {}

variable "ssh_key_name" {
  default = "default"
}

provider "digitalocean" {
  token = var.digitalocean_token
}

data "digitalocean_ssh_key" "default" {
  name = var.ssh_key_name
}

resource "digitalocean_droplet" "master" {
  count = 3

  image  = "debian-12-x64"
  name   = "rke2-manual-ma-${count.index}"
  region = "fra1"
  size   = "s-2vcpu-2gb"
  ssh_keys = [
    data.digitalocean_ssh_key.default.id
  ]
  tags      = ["rke2-manual", "rke2-manual-ma"]
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

resource "digitalocean_droplet" "worker" {
  count = 2

  image  = "debian-12-x64"
  name   = "rke2-manual-wo-${count.index}"
  region = "fra1"
  size   = "s-2vcpu-2gb"
  ssh_keys = [
    data.digitalocean_ssh_key.default.id
  ]
  tags      = ["rke2-manual", "rke2-manual-wo"]
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

output "master_ips" {
  value = [
    for node in digitalocean_droplet.master :
    node.ipv4_address
  ]
}


output "worker_ips" {
  value = [
    for node in digitalocean_droplet.worker :
    node.ipv4_address
  ]
}
