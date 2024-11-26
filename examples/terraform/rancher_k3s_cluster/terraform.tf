terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.16.0"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "5.1.0"
    }
  }
}

variable "rancher_api_url" {}
variable "rancher_token_key" {}

provider "rancher2" {
  api_url   = var.rancher_api_url
  token_key = var.rancher_token_key
}

variable "digitalocean_token" {}

resource "rancher2_cloud_credential" "do" {
  name = "do-tf02"
  digitalocean_credential_config {
    access_token = var.digitalocean_token
  }
}

resource "rancher2_machine_config_v2" "do" {
  generate_name = "do-"
  digitalocean_config {
    image  = "debian-12-x64"
    region = "fra1"
    size   = "s-2vcpu-2gb"
  }
}

resource "rancher2_cluster_v2" "tf02" {
  name                  = "tf02"
  kubernetes_version    = "v1.30.6+k3s1"
  enable_network_policy = false
  rke_config {
    machine_pools {
      name                         = "k3s"
      cloud_credential_secret_name = rancher2_cloud_credential.do.id
      control_plane_role           = true
      etcd_role                    = true
      worker_role                  = true
      quantity                     = 1
      machine_config {
        kind = rancher2_machine_config_v2.do.kind
        name = rancher2_machine_config_v2.do.name
      }
    }
  }
}
