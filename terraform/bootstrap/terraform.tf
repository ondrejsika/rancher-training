variable "rancher_api_url" {}

provider "rancher2" {
  alias = "bootstrap"

  api_url   = var.rancher_api_url
  bootstrap = true
}

resource "rancher2_bootstrap" "admin" {
  provider = rancher2.bootstrap

  password = "asdfasdf"
}

output "rancher_api_url" {
  value = rancher2_bootstrap.admin.url
}

output "rancher_token_key" {
  value = rancher2_bootstrap.admin.token
  sensitive = true
}
