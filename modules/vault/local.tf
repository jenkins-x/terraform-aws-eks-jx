resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  vault_seed             = random_string.suffix.result
  create_vault_resources = var.use_vault && !var.external_vault
}
