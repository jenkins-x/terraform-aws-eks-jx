provider "aws" {
  region  = var.region
  profile = var.profile
}

module "eks-jx" {
  source                         = "../../"
  fargate_nodes_for_jx_pipelines = true
  # More details https://docs.aws.amazon.com/eks/latest/userguide/fargate.html
  # NAT needed by EKS Fargate
  enable_nat_gateway  = true
  single_nat_gateway  = true
  cluster_version     = "1.21"
  nginx_chart_version = "3.12.0"
}
