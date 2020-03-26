module "jx-eks" {
    source                 = "../.."
    cluster_name           = var.cluster_name
    create_vault_resources = var.create_vault_resources
    vault_user             = var.vault_user
}
