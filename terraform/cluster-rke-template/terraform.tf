variable "rancher_api_url" {}
variable "rancher_token_key" {}
variable "slack_channel" {}
variable "slack_hook_url" {}

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

data "rancher2_user" "foo" {
    username = "foo"
}

resource "rancher2_cluster_role_template_binding" "foo" {
  name = "foo"
  cluster_id = rancher2_cluster.ros-template.id
  role_template_id = "cluster-admin"
  user_id = data.rancher2_user.foo.id
}

resource "rancher2_project" "proj1" {
  name = "proj1"
  cluster_id = rancher2_cluster.ros-template.id
  resource_quota {
    project_limit {
      limits_cpu = "2000m"
      limits_memory = "2000Mi"
      requests_storage = "2Gi"
    }
    namespace_default_limit {
      limits_cpu = "2000m"
      limits_memory = "500Mi"
      requests_storage = "1Gi"
    }
  }
  container_resource_limit {
    limits_cpu = "20m"
    limits_memory = "20Mi"
    requests_cpu = "1m"
    requests_memory = "1Mi"
  }
}

resource "rancher2_namespace" "proj1-prod" {
  name = "${rancher2_project.proj1.name}-prod"
  project_id = rancher2_project.proj1.id
  resource_quota {
    limit {
      limits_cpu = "100m"
      limits_memory = "100Mi"
      requests_storage = "1Gi"
    }
  }
  container_resource_limit {
    limits_cpu = "20m"
    limits_memory = "20Mi"
    requests_cpu = "1m"
    requests_memory = "1Mi"
  }
}

resource "rancher2_namespace" "proj1-dev" {
  name = "${rancher2_project.proj1.name}-dev"
  project_id = rancher2_project.proj1.id
  resource_quota {
    limit {
      limits_cpu = "50m"
      limits_memory = "50Mi"
      requests_storage = "1Gi"
    }
  }
  container_resource_limit {
    limits_cpu = "20m"
    limits_memory = "20Mi"
    requests_cpu = "1m"
    requests_memory = "1Mi"
  }
}

data "rancher2_user" "bar" {
    username = "bar"
}

resource "rancher2_project_role_template_binding" "bar" {
  name = "foo"
  project_id = rancher2_project.proj1.id
  role_template_id = "project-member"
  user_id = data.rancher2_user.bar.id
}

# === Notifiers ===

resource "rancher2_notifier" "slack" {
  name = "slack"
  cluster_id = rancher2_cluster.ros-template.id
  send_resolved = "true"

  slack_config {
    default_recipient = var.slack_channel
    url = var.slack_hook_url
  }
}
