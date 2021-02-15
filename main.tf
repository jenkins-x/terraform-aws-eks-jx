// ----------------------------------------------------------------------------
// Configure providers
// ----------------------------------------------------------------------------
provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes {
    host                   = module.cluster.cluster_host
    cluster_ca_certificate = module.cluster.cluster_ca_certificate
    token                  = module.cluster.cluster_token
  }
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

data "aws_caller_identity" "current" {}

// ----------------------------------------------------------------------------
// Setup all required AWS resources as well as the EKS cluster and any k8s resources
// See https://www.terraform.io/docs/providers/aws/r/vpc.html
// See https://www.terraform.io/docs/providers/aws/r/eks_cluster.html
// ----------------------------------------------------------------------------
module "cluster" {
  source                                = "./modules/cluster"
  region                                = var.region
  create_eks                            = var.create_eks
  create_vpc                            = var.create_vpc
  cluster_name                          = local.cluster_name
  cluster_version                       = var.cluster_version
  desired_node_count                    = var.desired_node_count
  min_node_count                        = var.min_node_count
  max_node_count                        = var.max_node_count
  node_machine_type                     = var.node_machine_type
  spot_price                            = var.spot_price
  encrypt_volume_self                   = var.encrypt_volume_self
  vpc_name                              = var.vpc_name
  public_subnets                        = var.public_subnets
  private_subnets                       = var.private_subnets
  vpc_cidr_block                        = var.vpc_cidr_block
  enable_nat_gateway                    = var.enable_nat_gateway
  single_nat_gateway                    = var.single_nat_gateway
  force_destroy                         = var.force_destroy
  enable_spot_instances                 = var.enable_spot_instances
  node_group_disk_size                  = var.node_group_disk_size
  enable_worker_group                   = var.enable_worker_group
  cluster_in_private_subnet             = var.cluster_in_private_subnet
  map_accounts                          = var.map_accounts
  map_roles                             = var.map_roles
  map_users                             = var.map_users
  enable_key_name                       = var.enable_key_name
  key_name                              = var.key_name
  volume_type                           = var.volume_type
  volume_size                           = var.volume_size
  iops                                  = var.iops
  use_kms_s3                            = var.use_kms_s3
  s3_kms_arn                            = var.s3_kms_arn
  is_jx2                                = var.is_jx2
  content                               = local.content
  cluster_endpoint_public_access        = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs  = var.cluster_endpoint_public_access_cidrs
  cluster_endpoint_private_access       = var.cluster_endpoint_private_access
  cluster_endpoint_private_access_cidrs = var.cluster_endpoint_private_access_cidrs
  enable_worker_groups_launch_template  = var.enable_worker_groups_launch_template
  allowed_spot_instance_types           = var.allowed_spot_instance_types
  lt_desired_nodes_per_subnet           = var.lt_desired_nodes_per_subnet
  lt_min_nodes_per_subnet               = var.lt_min_nodes_per_subnet
  lt_max_nodes_per_subnet               = var.lt_max_nodes_per_subnet
  jx_git_url                            = var.jx_git_url
  jx_bot_username                       = var.jx_bot_username
  jx_bot_token                          = var.jx_bot_token
  cluster_encryption_config             = var.cluster_encryption_config
  create_autoscaler_role                = var.create_autoscaler_role
  create_bucketrepo_role                = var.create_bucketrepo_role
  create_cm_role                        = var.create_cm_role
  create_cmcainjector_role              = var.create_cmcainjector_role
  create_ctrlb_role                     = var.create_ctrlb_role
  create_exdns_role                     = var.create_exdns_role
  create_pipeline_vis_role              = var.create_pipeline_vis_role
  create_tekton_role                    = var.create_tekton_role
  additional_tekton_role_policy_arns    = var.additional_tekton_role_policy_arns
}

// ----------------------------------------------------------------------------
// Setup all required resources for using the  bank-vaults operator
// See https://github.com/banzaicloud/bank-vaults
// ----------------------------------------------------------------------------
module "vault" {
  source         = "./modules/vault"
  cluster_name   = local.cluster_name
  vault_user     = var.vault_user
  force_destroy  = var.force_destroy
  external_vault = local.external_vault
  use_vault      = var.use_vault
}

// ----------------------------------------------------------------------------
// Setup all required resources for using Velero for cluster backups
// ----------------------------------------------------------------------------
module "backup" {
  source = "./modules/backup"

  enable_backup      = var.enable_backup
  cluster_name       = local.cluster_name
  force_destroy      = var.force_destroy
  velero_username    = var.velero_username
  create_velero_role = var.create_velero_role
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
  manage_apex_domain             = var.manage_apex_domain
  manage_subdomain               = var.manage_subdomain
}

module "health" {
  source               = "./modules/health"
  is_jx2               = var.is_jx2
  install_kuberhealthy = var.install_kuberhealthy
}
