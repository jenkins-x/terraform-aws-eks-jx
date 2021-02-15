module "eks-jx" {
  source               = "../../"
  vault_user           = var.vault_user
  is_jx2               = false
  install_kuberhealthy = true
}
