module "eks-jx" {
  source                    = "jenkins-x/eks-jx/aws"
  vault_user                = var.vault_user
  cluster_in_private_subnet = true
  enable_nat_gateway        = true
  single_nat_gateway        = true
}
