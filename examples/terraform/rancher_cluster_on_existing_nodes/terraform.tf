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

resource "rancher2_cluster_v2" "tf04" {
  name                  = "tf04"
  kubernetes_version    = "v1.30.6+rke2r1"
  enable_network_policy = false
  rke_config {}
}
