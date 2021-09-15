module "eks-jx" {
  source = "jenkins-x/eks-jx/aws"

  allowed_spot_instance_types          = ["m5.large", "m5a.large", "m5d.large", "m5ad.large", "m5n.large"]
  spot_price                           = "0.09"
  enable_spot_instances                = true
  enable_worker_groups_launch_template = true

  workers = var.workers
}
