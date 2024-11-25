terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.16.0"
    }
  }
}

variable "digitalocean_token" {}

provider "digitalocean" {
  token = var.digitalocean_token
}

locals {
  ondrejsika = "0b:e9:c2:df:2e:89:89:6f:92:dc:b7:60:83:20:21:c0"
  lab        = "a4:3f:f9:bd:18:45:a2:e2:0c:94:94:09:a6:1a:dd:ef"
  ssh_keys = [
    local.ondrejsika,
    local.lab,
  ]
}
resource "digitalocean_droplet" "master" {
  count = 3

  image     = "debian-12-x64"
  name      = "rke2-manual-ma-${count.index}"
  region    = "fra1"
  size      = "s-2vcpu-4gb"
  ssh_keys  = local.ssh_keys
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
    apt-get install -y curl sudo git open-iscsi nfs-client
    curl -fsSL https://raw.githubusercontent.com/sikalabs/slu/master/install.sh | sudo sh
    systemctl stop ufw
    systemctl disable ufw
EOF
}

resource "digitalocean_droplet" "worker" {
  count = 2

  image     = "debian-12-x64"
  name      = "rke2-manual-wo-${count.index}"
  region    = "fra1"
  size      = "s-2vcpu-2gb"
  ssh_keys  = local.ssh_keys
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
    apt-get install -y curl sudo git open-iscsi nfs-client
    curl -fsSL https://raw.githubusercontent.com/sikalabs/slu/master/install.sh | sudo sh
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
