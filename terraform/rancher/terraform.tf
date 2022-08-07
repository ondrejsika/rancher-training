terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.16.0"
    }
  }
}

variable "do_token" {}
variable "base_domain" {}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "default" {
  name = "default"
}

data "digitalocean_domain" "default" {
  name = var.base_domain
}

resource "digitalocean_droplet" "rancher" {
  image  = "rancheros"
  name   = "rancher"
  region = "fra1"
  size   = "s-4vcpu-8gb"
  ssh_keys = [
    data.digitalocean_ssh_key.default.fingerprint
  ]
}

resource "digitalocean_record" "rancher" {
  domain = data.digitalocean_domain.default.name
  type   = "A"
  name   = digitalocean_droplet.rancher.name
  value  = digitalocean_droplet.rancher.ipv4_address
}

resource "null_resource" "cluster" {
  triggers = {
    record = digitalocean_record.rancher.fqdn
  }

  connection {
    type = "ssh"
    host = digitalocean_droplet.rancher.ipv4_address
    user = "rancher"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 60",
      "docker pull -q rancher/rancher:latest",
      // -e CATTLE_BOOTSTRAP_PASSWORD=bootstrap
      "docker run --privileged --name rancher -d --restart=always -p 80:80 -p 443:443 rancher/rancher:latest --acme-domain ${digitalocean_record.rancher.fqdn}",
    ]
  }
}

output "rancher_domain" {
  value = digitalocean_record.rancher.fqdn
}

output "rancher_api_url" {
  value = "https://${digitalocean_record.rancher.fqdn}"
}
