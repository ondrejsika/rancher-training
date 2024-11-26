terraform {
  required_providers {
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
  name = "do-tf01"
  digitalocean_credential_config {
    access_token = var.digitalocean_token
  }
}

resource "rancher2_machine_config_v2" "ma" {
  generate_name = "ma-"
  digitalocean_config {
    image  = "debian-12-x64"
    region = "fra1"
    size   = "s-2vcpu-4gb"
  }
}

resource "rancher2_machine_config_v2" "wo" {
  generate_name = "wo-"
  digitalocean_config {
    image  = "debian-12-x64"
    region = "fra1"
    size   = "s-2vcpu-4gb"
  }
}

resource "rancher2_cluster_v2" "tf01" {
  name                  = "tf02"
  kubernetes_version    = "v1.30.6+rke2r1"
  enable_network_policy = false
  rke_config {
    machine_pools {
      name                         = "ma"
      cloud_credential_secret_name = rancher2_cloud_credential.do.id
      control_plane_role           = true
      etcd_role                    = true
      worker_role                  = false
      quantity                     = 1
      machine_config {
        kind = rancher2_machine_config_v2.ma.kind
        name = rancher2_machine_config_v2.ma.name
      }
    }
    machine_pools {
      name                         = "wo"
      cloud_credential_secret_name = rancher2_cloud_credential.do.id
      control_plane_role           = false
      etcd_role                    = false
      worker_role                  = true
      quantity                     = 2
      machine_config {
        kind = rancher2_machine_config_v2.wo.kind
        name = rancher2_machine_config_v2.wo.name
      }
    }
  }
}
