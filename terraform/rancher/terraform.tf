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

provider "digitalocean" {
  token = var.digitalocean_token
}

data "digitalocean_ssh_key" "default" {
  name = "default"
}

data "digitalocean_domain" "default" {
  name = var.base_domain
}

resource "digitalocean_droplet" "rancher" {
  image  = "docker-20-04"
  name   = "rancher"
  region = "fra1"
  size   = "s-4vcpu-8gb"
  ssh_keys = [
    data.digitalocean_ssh_key.default.id
  ]
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
    curl -fsSL https://ins.oxs.cz/slu-linux-amd64.sh | sudo sh
    install-slu i -v v0.44.0-dev-1
    slu install-bin-tool training-cli -v v0.5.0-dev-5
    HOME=/root training-cli rancher vm-setup
    docker pull -q rancher/rancher:latest
    sleep 60
    docker run --privileged --name rancher -d --restart=always -p 80:80 -p 443:443 -e CATTLE_BOOTSTRAP_PASSWORD=bootstrap rancher/rancher:latest --acme-domain rancher.${data.digitalocean_domain.default.name}
EOF
}

resource "digitalocean_record" "rancher" {
  domain = data.digitalocean_domain.default.name
  type   = "A"
  name   = digitalocean_droplet.rancher.name
  value  = digitalocean_droplet.rancher.ipv4_address
}

output "rancher_domain" {
  value = digitalocean_record.rancher.fqdn
}

output "rancher_api_url" {
  value = "https://${digitalocean_record.rancher.fqdn}"
}
