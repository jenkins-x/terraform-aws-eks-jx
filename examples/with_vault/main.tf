module "jx-eks" {
    source                 = "../.."
    cluster_name           = var.cluster_name
    account_id             = var.account_id
    create_vault_resources = var.create_vault_resources
    vault_user             = var.vault_user
}
