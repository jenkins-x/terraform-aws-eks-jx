resource "random_string" "suffix" {
  length  = 8
  special = false
}

// ----------------------------------------------------------------------------
// Module local variables
// ----------------------------------------------------------------------------
locals {
  generated_seed         = random_string.suffix.result
  oidc_provider_url      = replace(var.create_eks ? module.eks.cluster_oidc_issuer_url : data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
  jenkins-x-namespace    = "jx"
  cluster_trunc          = substr(var.cluster_name, 0, 35)
  cert-manager-namespace = "cert-manager"

  node_group_defaults = {
    launch_template_id      = null
    launch_template_version = null

    # Provider default which is 'ON_DEMAND'. We don't set it explicitly to avoid changes to existing clusters provisioned with this module
    capacity_type = var.enable_spot_instances ? "SPOT" : null

    k8s_labels = {
      "jenkins-x.io/name"       = var.cluster_name
      "jenkins-x.io/part-of"    = "jx-platform"
      "jenkins-x.io/managed-by" = "terraform"
    }

    additional_tags = {
      aws_managed = "true"
    }
  }

  node_groups_extended = length(var.node_groups) > 0 ? { for k, v in var.node_groups : k => merge(
    local.node_group_defaults,
    v,
    {
      # Deep merge isn't a thing in terraform, yet, so we commit these atrocities.
      k8s_labels = merge(
        local.node_group_defaults["k8s_labels"],
        v["k8s_labels"],
      )
    },
    ) } : {
    eks-jx-node-group = merge(
      {
        ami_type         = var.node_group_ami
        disk_size        = var.node_group_disk_size
        desired_capacity = var.desired_node_count
        max_capacity     = var.max_node_count
        min_capacity     = var.min_node_count
        instance_types   = [var.node_machine_type]
      },
      local.node_group_defaults
    )
  }
}
