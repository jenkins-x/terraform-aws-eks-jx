
locals {
  create_vault_resources = var.use_vault && !var.external_vault
}
