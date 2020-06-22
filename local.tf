provider "random" {
  version = "~> 2.1"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "random_pet" "current" {
  prefix    = "tf-jx"
  separator = "-"
  keepers = {
    # Keep the name consistent on executions
    cluster_name = var.cluster_name
  }
}

locals {
  cluster_name      = var.cluster_name != "" ? var.cluster_name : random_pet.current.id
  generated_seed    = random_string.suffix.result
  oidc_provider_url = module.cluster.cluster_oidc_issuer_url
  external_vault    = var.vault_url != "" ? true : false
}
