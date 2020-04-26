variable "rancher_api_url" {}
variable "rancher_token_key" {}

provider "rancher2" {
  api_url = var.rancher_api_url
  token_key = var.rancher_token_key
}

data "rancher2_node_template" "do-deb" {
  name = "do-deb"
}

resource "rancher2_cluster" "deb" {
  name = "terraform-deb"
  description = "Debian cluster created using Terraform"
  rke_config {
    network {
      plugin = "canal"
    }
    ingress {
      provider = "none"
    }
  }
}

resource "rancher2_node_pool" "deb" {
  cluster_id =  rancher2_cluster.deb.id
  name = "deb"
  hostname_prefix =  "deb"
  node_template_id = data.rancher2_node_template.do-deb.id
  quantity = 1
  control_plane = true
  etcd = true
  worker = true
}
