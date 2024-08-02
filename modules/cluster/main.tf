// ----------------------------------------------------------------------------
// Query necessary data for the module
// ----------------------------------------------------------------------------
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

// ----------------------------------------------------------------------------
// Define K8s cluster configuration
// ----------------------------------------------------------------------------
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

// ----------------------------------------------------------------------------
// Update the kube configuration after the cluster has been created so we can
// connect to it and create the K8s resources
// ----------------------------------------------------------------------------
resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command     = "aws eks update-kubeconfig --name ${var.cluster_name} --region=${var.region} ${var.profile == null ? "" : format("--profile=%s", var.profile)}"
    interpreter = var.local-exec-interpreter
  }
}

// ----------------------------------------------------------------------------
// Add the Terraform generated jx-requirements.yml to a configmap so it can be
// sync'd with the Git repository
//
// https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
// ----------------------------------------------------------------------------
resource "kubernetes_config_map" "jenkins_x_requirements" {
  metadata {
    name      = "terraform-jx-requirements"
    namespace = "default"
  }
  data = {
    "jx-requirements.yml" = var.content
  }

  lifecycle {
    ignore_changes = [
      metadata,
      data
    ]
  }
}

