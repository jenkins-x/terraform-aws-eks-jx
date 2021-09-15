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
  secret-infra-namespace = "secret-infra"
  project                = data.aws_caller_identity.current.account_id

  workers_template_defaults_merge = [for k, v in var.workers : merge(
    local.workers_template_defaults_defaults,
    {
      kubelet_extra_args = join(" ", compact([
        join(",", compact([local.workers_template_defaults_defaults.kubelet_extra_args, contains(keys(v), "k8s_labels") ? v["k8s_labels"] : ""])),
        contains(keys(v), "k8s_taints") ? "--register-with-taints=${v["k8s_taints"]}" : ""])
      )
    },
    {
      tags = concat(local.workers_template_defaults_defaults.tags, contains(keys(v), "tags") ? v["tags"] : [])
    }, v
  )]

  workers_template_defaults = [for node in local.workers_template_defaults_merge : {
    for k, v in node : k => v if(k != "k8s_labels") && (k != "k8s_taints")
  }]

  workers_template_defaults_defaults = {
    override_instance_types = var.allowed_spot_instance_types
    root_encrypted          = var.encrypt_volume_self
    instance_type           = var.node_machine_type
    autoscaling_enabled     = "true"
    public_ip               = true
    spot_price              = (var.enable_spot_instances ? var.spot_price : null)
    subnets                 = (var.create_vpc ? module.vpc.public_subnets : var.subnets)

    root_volume_type = var.volume_type
    root_volume_size = var.volume_size
    root_iops        = var.iops

    on_demand_base_capacity = var.on_demand_base_capacity
    asg_min_size            = var.min_node_count
    asg_max_size            = var.max_node_count
    asg_desired_capacity    = var.desired_node_count
    kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=`curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle`"

    tags = [
      {
        key                 = "k8s.io/cluster-autoscaler/enabled"
        propagate_at_launch = "false"
        value               = "true"
      },
      {
        key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
        propagate_at_launch = "false"
        value               = "true"
      }
    ]
  }

  node_group_defaults = {
    ami_type         = var.node_group_ami
    disk_size        = var.node_group_disk_size
    desired_capacity = var.desired_node_count
    max_capacity     = var.max_node_count
    min_capacity     = var.min_node_count
    instance_types   = [var.node_machine_type]

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

  node_groups_extended = { for k, v in var.node_groups : k => merge(
    local.node_group_defaults,
    v,
    contains(keys(v), "k8s_labels") ? {
      # Deep merge isn't a thing in terraform, yet, so we commit these atrocities.
      k8s_labels = merge(
        local.node_group_defaults["k8s_labels"],
        v["k8s_labels"],
      )
    } : {},
  ) }
}
