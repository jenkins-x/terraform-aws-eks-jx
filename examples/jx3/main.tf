provider "aws" {
  region  = var.region
  profile = var.profile
}


module "eks-jx" {
  source               = "../../"
  vault_user           = var.vault_user
  is_jx2               = false
  install_kuberhealthy = true
  create_nginx         = true
  cluster_version      = "1.20"
  nginx_chart_version  = "3.12.0"
}
