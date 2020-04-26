variable "rancher_api_url" {}
variable "rancher_token_key" {}

provider "rancher2" {
  api_url = var.rancher_api_url
  token_key = var.rancher_token_key
}

data "rancher2_node_template" "do-ros" {
  name = "do-ros"
}

resource "rancher2_cluster" "ros" {
  name = "terraform-ros"
  description = "RancherOS cluster created using Terraform"
  rke_config {
    network {
      plugin = "canal"
    }
    ingress {
      provider = "none"
    }
  }
}

resource "rancher2_node_pool" "ros" {
  cluster_id =  rancher2_cluster.ros.id
  name = "ros"
  hostname_prefix =  "ros"
  node_template_id = data.rancher2_node_template.do-ros.id
  quantity = 1
  control_plane = true
  etcd = true
  worker = true
}
