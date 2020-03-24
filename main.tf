terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

module "jx" {
  source                         = "./jx"
  region                         = var.region
  cluster_name                   = var.cluster_name
  apex_domain                    = var.apex_domain
  subdomain                      = var.subdomain
  tls_email                      = var.tls_email
  enable_logs_storage            = var.enable_logs_storage
  enable_reports_storage         = var.enable_reports_storage
  enable_repository_storage      = var.enable_repository_storage
  enable_external_dns            = var.enable_external_dns
  create_and_configure_subdomain = var.create_and_configure_subdomain
  enable_tls                     = var.enable_tls
  production_letsencrypt         = var.production_letsencrypt
}

module "vault" {
  source                 = "./vault"
  create_vault_resources = var.create_vault_resources
  cluster_name           = var.cluster_name
  account_id             = var.account_id
  vault_user             = var.vault_user
}

# jx-requirements.yml file generation

resource "local_file" "jx-requirements" {
  depends_on = [
    module.jx,
    module.vault
  ]
  content = templatefile("${path.module}/jx/jx-requirements.yml.tpl", {
    cluster_name                = var.cluster_name
    region                      = var.region
    enable_logs_storage         = var.enable_logs_storage
    logs_storage_bucket         = module.jx.logs-jenkins-x
    enable_reports_storage      = var.enable_reports_storage
    reports_storage_bucket      = module.jx.reports-jenkins-x
    enable_repository_storage   = var.enable_repository_storage
    repository_storage_bucket   = module.jx.repository-jenkins-x
    create_vault_resources      = var.create_vault_resources
    vault_kms_key               = module.vault.kms_vault_unseal 
    vault_bucket                = module.vault.vault_unseal_bucket
    vault_dynamodb_table        = module.vault.vault_dynamodb_table
    vault_user                  = var.vault_user
    enable_external_dns         = var.enable_external_dns
    domain                      = trimprefix(join(".", [var.subdomain, var.apex_domain]), ".")
    enable_tls                  = var.enable_tls
    tls_email                   = var.tls_email
    use_production_letsencrypt  = var.production_letsencrypt
  })
  filename = "../${path.module}/jx-requirements.yml"
}
