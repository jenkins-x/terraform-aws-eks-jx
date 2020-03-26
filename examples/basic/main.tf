module "jx-eks" {
    source = "../"
    cluster_name = var.cluster_name
    account_id   = var.account_id
}
