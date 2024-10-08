data "aws_caller_identity" "current" {}

// ----------------------------------------------------------------------------
// Setup all required AWS resources as well as the EKS cluster and any k8s resources
// See https://www.terraform.io/docs/providers/aws/r/vpc.html
// See https://www.terraform.io/docs/providers/aws/r/eks_cluster.html
// ----------------------------------------------------------------------------
module "cluster" {
  source                             = "./modules/cluster"
  region                             = var.region
  vpc_id                             = var.vpc_id
  subnets                            = var.subnets
  cluster_name                       = var.cluster_name
  force_destroy                      = var.force_destroy
  use_kms_s3                         = var.use_kms_s3
  s3_kms_arn                         = var.s3_kms_arn
  s3_extra_tags                      = var.s3_extra_tags
  content                            = local.content
  jx_git_operator_values             = var.jx_git_operator_values
  jx_git_url                         = var.jx_git_url
  jx_bot_username                    = var.jx_bot_username
  jx_bot_token                       = var.jx_bot_token
  create_autoscaler_role             = var.create_autoscaler_role
  create_bucketrepo_role             = var.create_bucketrepo_role
  create_cm_role                     = var.create_cm_role
  create_cmcainjector_role           = var.create_cmcainjector_role
  create_ctrlb_role                  = var.create_ctrlb_role
  create_exdns_role                  = var.create_exdns_role
  create_pipeline_vis_role           = var.create_pipeline_vis_role
  create_asm_role                    = var.create_asm_role
  create_ssm_role                    = var.create_ssm_role
  create_tekton_role                 = var.create_tekton_role
  additional_tekton_role_policy_arns = var.additional_tekton_role_policy_arns
  tls_cert                           = var.tls_cert
  tls_key                            = var.tls_key
  local-exec-interpreter             = var.local-exec-interpreter
  enable_logs_storage                = var.enable_logs_storage
  expire_logs_after_days             = var.expire_logs_after_days
  enable_reports_storage             = var.enable_reports_storage
  enable_repository_storage          = var.enable_repository_storage
  boot_secrets                       = var.boot_secrets
  use_asm                            = var.use_asm
  boot_iam_role                      = "${var.asm_role}${var.boot_iam_role}"
  enable_acl                         = var.enable_acl
  cluster_oidc_issuer_url            = var.cluster_oidc_issuer_url
}

// ----------------------------------------------------------------------------
// Create vault if neeed
// See https://github.com/bank-vaults/bank-vaults
// ----------------------------------------------------------------------------
module "vault" {
  source         = "./modules/vault"
  resource_count = var.use_vault && !local.external_vault && var.install_vault ? 1 : 0
}

// ----------------------------------------------------------------------------
// Setup all required resources for using Velero for cluster backups
// ----------------------------------------------------------------------------
module "backup" {
  source = "./modules/backup"

  enable_backup      = var.enable_backup
  cluster_name       = var.cluster_name
  force_destroy      = var.force_destroy
  velero_username    = var.velero_username
  create_velero_role = var.create_velero_role
  enable_acl         = var.enable_acl
  s3_extra_tags      = var.s3_extra_tags
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
  force_destroy_subdomain        = var.force_destroy_subdomain
  enable_tls                     = var.enable_tls
  production_letsencrypt         = var.production_letsencrypt
  manage_apex_domain             = var.manage_apex_domain
  manage_subdomain               = var.manage_subdomain
}

module "health" {
  source               = "./modules/health"
  install_kuberhealthy = var.install_kuberhealthy
}

module "nginx" {
  source                 = "./modules/nginx"
  create_nginx           = var.create_nginx
  nginx_release_name     = var.nginx_release_name
  nginx_namespace        = var.nginx_namespace
  nginx_chart_version    = var.nginx_chart_version
  create_nginx_namespace = var.create_nginx_namespace
  nginx_values_file      = var.nginx_values_file

}
