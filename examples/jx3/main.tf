provider "aws" {
  region  = var.region
  profile = var.profile
}


module "eks-jx" {
  source                               = "../../"
  vault_user                           = var.vault_user
  is_jx2                               = false
  install_kuberhealthy                 = true
  create_nginx                         = true
  cluster_version                      = "1.21"
  nginx_chart_version                  = "3.12.0"
  enable_worker_groups_launch_template = true
  volume_type                          = "gp3"
  volume_size                          = "100"
  encrypt_volume_self                  = true
}
