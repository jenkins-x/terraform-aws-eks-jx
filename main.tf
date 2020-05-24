// ----------------------------------------------------------------------------
// Enforce Terraform version
//
// ----------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12.17"
}

// ----------------------------------------------------------------------------
// Configure providers
// ----------------------------------------------------------------------------
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

// ----------------------------------------------------------------------------
// Setup all required AWS resources as well as the EKS cluster and any k8s resources
// See https://www.terraform.io/docs/providers/aws/r/vpc.html
// See https://www.terraform.io/docs/providers/aws/r/eks_cluster.html
// ----------------------------------------------------------------------------
module "cluster" {
  source                = "./modules/cluster"
  cluster_name          = local.cluster_name
  cluster_version       = var.cluster_version
  desired_node_count    = var.desired_node_count
  min_node_count        = var.min_node_count
  max_node_count        = var.max_node_count
  node_machine_type     = var.node_machine_type
  spot_price            = var.spot_price
  vpc_name              = var.vpc_name
  vpc_subnets           = var.vpc_subnets
  vpc_cidr_block        = var.vpc_cidr_block
  force_destroy         = var.force_destroy
  enable_spot_instances = var.enable_spot_instances
  enable_key_name       = var.enable_key_name
  key_name	 	= var.key_name
  volume_type		= var.volume_type
  volume_size		= var.volume_size
}

// ----------------------------------------------------------------------------
// Setup all required resources for using the  bank-vaults operator
// See https://github.com/banzaicloud/bank-vaults
// ----------------------------------------------------------------------------
module "vault" {
  source        = "./modules/vault"
  cluster_name  = local.cluster_name
  vault_user    = var.vault_user
  force_destroy = var.force_destroy
}

// ----------------------------------------------------------------------------
// Setup all required Route 53 resources if External DNS / Cert Manager is enabled
// ----------------------------------------------------------------------------
module "dns" {
  source                         = "./modules/dns"
  apex_domain                    = var.apex_domain
  subdomain                      = var.subdomain
  tls_email                      = var.tls_email
  enable_external_dns            = var.enable_external_dns
  create_and_configure_subdomain = var.create_and_configure_subdomain
  enable_tls                     = var.enable_tls
  production_letsencrypt         = var.production_letsencrypt
}

// ----------------------------------------------------------------------------
// Let's generate jx-requirements.yml 
// ----------------------------------------------------------------------------
resource "local_file" "jx-requirements" {
  depends_on = [
    module.vault,
    module.cluster
  ]
  content = templatefile("${path.module}/jx-requirements.yml.tpl", {
    cluster_name               = local.cluster_name
    region                     = var.region
    enable_logs_storage        = var.enable_logs_storage
    logs_storage_bucket        = length(module.cluster.logs_jenkins_x) > 0 ? module.cluster.logs_jenkins_x[0] : ""
    enable_reports_storage     = var.enable_reports_storage
    reports_storage_bucket     = length(module.cluster.reports_jenkins_x) > 0 ? module.cluster.reports_jenkins_x[0] : ""
    enable_repository_storage  = var.enable_repository_storage
    repository_storage_bucket  = length(module.cluster.repository_jenkins_x) > 0 ? module.cluster.repository_jenkins_x[0] : ""
    vault_kms_key              = module.vault.kms_vault_unseal
    vault_bucket               = module.vault.vault_unseal_bucket
    vault_dynamodb_table       = module.vault.vault_dynamodb_table
    vault_user                 = var.vault_user
    enable_external_dns        = var.enable_external_dns
    domain                     = module.dns.domain
    enable_tls                 = var.enable_tls
    tls_email                  = var.tls_email
    use_production_letsencrypt = var.production_letsencrypt
  })
  filename = "${path.cwd}/jx-requirements.yml"
}
