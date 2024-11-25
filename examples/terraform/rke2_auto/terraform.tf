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

resource "digitalocean_droplet" "master0" {
  image     = "debian-12-x64"
  name      = "rke2-auto-ma-0"
  region    = "fra1"
  size      = "s-2vcpu-4gb"
  ssh_keys  = local.ssh_keys
  tags      = ["rke2-auto", "rke2-auto-ma"]
  user_data = <<EOF
#cloud-config
ssh_pwauth: yes
password: asdfasdf2020
chpasswd:
  expire: false
write_files:
- path: /etc/rancher/rke2/config.yaml
  permissions: "0600"
  owner: root:root
  content: |
    token: randomtoken
runcmd:
  - |
    apt update
    apt install -y curl sudo git
    curl -fsSL https://raw.githubusercontent.com/sikalabs/slu/master/install.sh | sudo sh
    curl -sfL https://get.rke2.io | INSTALL_RKE2_METHOD='tar' sh -
    systemctl enable rke2-server.service
    systemctl start rke2-server.service
    ln -sf /etc/rancher/rke2/rke2.yaml /root/.kube/config
    ln -sf /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/kubectl
    ln -sf /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/k
EOF
}

resource "digitalocean_droplet" "master" {
  count = 2

  image     = "debian-12-x64"
  name      = "rke2-auto-ma-${count.index + 1}"
  region    = "fra1"
  size      = "s-2vcpu-4gb"
  ssh_keys  = local.ssh_keys
  tags      = ["rke2-auto", "rke2-auto-ma"]
  user_data = <<EOF
#cloud-config
ssh_pwauth: yes
password: asdfasdf2020
chpasswd:
  expire: false
write_files:
- path: /etc/rancher/rke2/config.yaml
  permissions: "0600"
  owner: root:root
  content: |
    server: https://${digitalocean_droplet.master0.ipv4_address}:9345
    token: randomtoken
runcmd:
  - |
    apt update
    apt install -y curl sudo git
    curl -fsSL https://raw.githubusercontent.com/sikalabs/slu/master/install.sh | sudo sh
    curl -sfL https://get.rke2.io | INSTALL_RKE2_METHOD='tar' sh -
    systemctl enable rke2-server.service
    slu wf tcp -a ${digitalocean_droplet.master0.ipv4_address}:9345
    systemctl start rke2-server.service
    mkdir -p /root/.kube
    ln -sf /etc/rancher/rke2/rke2.yaml /root/.kube/config
    ln -sf /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/kubectl
    ln -sf /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/k
EOF
}

resource "digitalocean_droplet" "worker" {
  count = 2

  image     = "debian-12-x64"
  name      = "rke2-auto-wo-${count.index}"
  region    = "fra1"
  size      = "s-2vcpu-2gb"
  ssh_keys  = local.ssh_keys
  tags      = ["rke2-auto", "rke2-auto-wo"]
  user_data = <<EOF
#cloud-config
ssh_pwauth: yes
password: asdfasdf2020
chpasswd:
  expire: false
write_files:
- path: /etc/rancher/rke2/config.yaml
  permissions: "0600"
  owner: root:root
  content: |
    server: https://${digitalocean_droplet.master0.ipv4_address}:9345
    token: randomtoken
runcmd:
  - |
    apt update
    apt install -y curl sudo git
    curl -fsSL https://raw.githubusercontent.com/sikalabs/slu/master/install.sh | sudo sh
    curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" INSTALL_RKE2_METHOD='tar' sh -
    systemctl enable rke2-agent.service
    slu wf tcp -a ${digitalocean_droplet.master0.ipv4_address}:9345
    systemctl start rke2-agent.service
EOF
}

output "master_ips" {
  value = concat([
    digitalocean_droplet.master0.ipv4_address,
    ], [
    for node in digitalocean_droplet.master :
    node.ipv4_address
  ])
}


output "worker_ips" {
  value = [
    for node in digitalocean_droplet.worker :
    node.ipv4_address
  ]
}
