module "jx-eks" {
    source                 = "../.."
    create_vault_resources = var.create_vault_resources
    vault_user             = var.vault_user
}
