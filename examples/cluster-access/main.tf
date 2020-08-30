# In this example, the public endpoint access is restricted to the cidr blocks specified
module "eks-jx" {
  source                               = "jenkins-x/eks-jx/aws"
  vault_user                           = var.vault_user
  cluster_endpoint_public_access_cidrs = ["1.2.3.4/32", "5.6.7.8/32"]
}
