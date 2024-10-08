data "aws_caller_identity" "current" {}

// ----------------------------------------------------------------------------
// Update the kube configuration after the cluster has been created so we can
// connect to it and create the K8s resources
// ----------------------------------------------------------------------------
resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command     = "aws eks update-kubeconfig --name ${var.cluster_name} --region=${var.region}"
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

