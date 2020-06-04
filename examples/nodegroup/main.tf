module "eks-jx" {
  source              = "jenkins-x/eks-jx/aws"
  enable_node_group   = var.enable_node_group   // set to true
  enable_worker_group = var.enable_worker_group // set to false
}
