module "eks-jx" {
  source              = "jenkins-x/eks-jx/aws"
  enable_worker_group = var.enable_worker_group // set to false
}
