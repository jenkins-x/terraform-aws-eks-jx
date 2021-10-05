module "eks-jx" {
  source                          = "jenkins-x/eks-jx/aws"
  fargate_nodes_for_jx_pipelines  = true
  # More details https://docs.aws.amazon.com/eks/latest/userguide/fargate.html
  # NAT needed by EKS Fargate
  enable_nat_gateway              = true
  single_nat_gateway              = true
}
