variable "do_token" {}

variable "ssh_key_name" {
  default = "default"
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "default" {
  name = var.ssh_key_name
}

resource "digitalocean_droplet" "ros" {
  image  = "rancheros"
  name   = "ros"
  region = "fra1"
  size   = "s-1vcpu-1gb"
  ssh_keys = [
    data.digitalocean_ssh_key.default.id
  ]
}

output "ros_ip" {
  value = digitalocean_droplet.ros.ipv4_address
}
