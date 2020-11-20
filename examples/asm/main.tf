module "eks-jx" {
  source                               = "../../"
  region                               = var.region
  use_vault                            = var.use_vault
  use_asm                              = var.use_asm
  is_jx2                               = false
  cluster_version                      = "1.18"
  enable_worker_groups_launch_template = true
  encrypt_volume_self                  = true
}
