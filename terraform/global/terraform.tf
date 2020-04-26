variable "do_token" {}
variable "rancher_api_url" {}
variable "rancher_token_key" {}

provider "digitalocean" {
  token = var.do_token
}

provider "rancher2" {
  api_url = var.rancher_api_url
  token_key = var.rancher_token_key
}

# === Cloud Credentials ===

resource "rancher2_cloud_credential" "do" {
  name = "do"
  description = "do"
  digitalocean_credential_config {
    access_token  = var.do_token
  }
}

# === Node Templates ===

resource "rancher2_node_template" "do-deb" {
  name = "do-deb"
  description = "Debian @ DO"
  cloud_credential_id = rancher2_cloud_credential.do.id
  digitalocean_config {
    image = "debian-9-x64"
    region = "fra1"
    size = "s-2vcpu-4gb"
  }
}

resource "rancher2_node_template" "do-ros" {
  name = "do-ros"
  description = "RancherOS @ DO"
  cloud_credential_id = rancher2_cloud_credential.do.id
  digitalocean_config {
    image = "rancheros"
    region = "fra1"
    size = "s-2vcpu-4gb"
    ssh_user = "rancher"
  }
}

# === Users ===

resource "rancher2_user" "foo" {
  name = "Foo User"
  username = "foo"
  password = "foo"
  enabled = true
}

resource "rancher2_global_role_binding" "foo" {
  name = "foo"
  global_role_id = "user"
  user_id = rancher2_user.foo.id
}

resource "rancher2_user" "bar" {
  name = "Bar User"
  username = "bar"
  password = "bar"
  enabled = true
}

resource "rancher2_global_role_binding" "bar" {
  name = "bar"
  global_role_id = "user"
  user_id = rancher2_user.bar.id
}
