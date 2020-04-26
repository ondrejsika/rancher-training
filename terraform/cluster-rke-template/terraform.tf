variable "rancher_api_url" {}
variable "rancher_token_key" {}

provider "rancher2" {
  api_url = var.rancher_api_url
  token_key = var.rancher_token_key
}

data "rancher2_node_template" "do-ros" {
  name = "do-ros"
}

data "rancher2_cluster_template" "default" {
  name = "default"
}

resource "rancher2_cluster" "ros-template" {
  name = "terraform-template"
  description = "RancherOS cluster from template created using Terraform"
  cluster_template_id = data.rancher2_cluster_template.default.id
  cluster_template_revision_id = data.rancher2_cluster_template.default.template_revisions.0.id
}

resource "rancher2_node_pool" "ros-template" {
  cluster_id =  rancher2_cluster.ros-template.id
  name = "ros-template"
  hostname_prefix =  "ros-template"
  node_template_id = data.rancher2_node_template.do-ros.id
  quantity = 1
  control_plane = true
  etcd = true
  worker = true
}
