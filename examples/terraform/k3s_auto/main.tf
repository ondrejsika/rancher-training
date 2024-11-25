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

resource "digitalocean_droplet" "main" {
  image  = "debian-12-x64"
  name   = "k3s-auto"
  region = "fra1"
  size   = "s-2vcpu-2gb"
  ssh_keys = [
    "0b:e9:c2:df:2e:89:89:6f:92:dc:b7:60:83:20:21:c0",
  ]
  user_data = <<EOF
#cloud-config
ssh_pwauth: yes
password: asdfasdf2020
chpasswd:
  expire: false
write_files:
- path: /etc/rancher/k3s/config.yaml
  permissions: "0600"
  owner: root:root
  content: |
    disable:
      - traefik
runcmd:
  - |
    apt update
    apt install -y curl sudo git
    curl -fsSL https://raw.githubusercontent.com/sikalabs/slu/master/install.sh | sudo sh
    curl -sfL https://get.k3s.io | sh -
EOF
}

output "ip" {
  value = digitalocean_droplet.main.ipv4_address
}
