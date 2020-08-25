module "eks-jx" {
  source                               = "jenkins-x/eks-jx/aws"
  enable_worker_group                  = false
  enable_worker_groups_launch_template = true
  allowed_spot_instance_types          = ["m5.large", "m5a.large", "m5d.large", "m5ad.large", "t3.large", "t3a.large"]
  lt_desired_nodes_per_subnet          = 2
  lt_min_nodes_per_subnet              = 2
  lt_max_nodes_per_subnet              = 3
}
