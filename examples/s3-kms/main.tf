module "eks-jx" {
  source     = "jenkins-x/eks-jx/aws"
  vault_user = var.vault_user
  use_kms    = var.use_kms
  # s3_kms_arn = <kms-arn>
}
