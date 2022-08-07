terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.21.0"
    }
  }
}

variable "rancher_api_url" {}

provider "rancher2" {
  alias = "bootstrap"

  api_url   = var.rancher_api_url
  bootstrap = true
}

resource "rancher2_bootstrap" "admin" {
  provider = rancher2.bootstrap

  initial_password = "bootstrap"
  password         = "asdfasdfasdf"
}

output "rancher_api_url" {
  value = rancher2_bootstrap.admin.url
}

output "rancher_token_key" {
  value     = rancher2_bootstrap.admin.token
  sensitive = true
}
