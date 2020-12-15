// ----------------------------------------------------------------------------
// Jenkins X Requirements
// ----------------------------------------------------------------------------
output "jx_requirements" {
  description = "The jx-requirements rendered output"
  value       = local.content
}

// ----------------------------------------------------------------------------
// Storage (backup, logs, reports, repo)
// ----------------------------------------------------------------------------
output "backup_bucket_url" {
  value       = module.backup.backup_bucket_url
  description = "The bucket where backups from velero will be stored"
}

output "lts_logs_bucket" {
  value       = length(module.cluster.logs_jenkins_x) > 0 ? module.cluster.logs_jenkins_x[0] : ""
  description = "The bucket where logs from builds will be stored"
}

output "lts_reports_bucket" {
  value       = length(module.cluster.reports_jenkins_x) > 0 ? module.cluster.reports_jenkins_x[0] : ""
  description = "The bucket where test reports will be stored"
}

output "lts_repository_bucket" {
  value       = length(module.cluster.repository_jenkins_x) > 0 ? module.cluster.repository_jenkins_x[0] : ""
  description = "The bucket that will serve as artifacts repository"
}

// ----------------------------------------------------------------------------
// Cluster Name
// ----------------------------------------------------------------------------
output "cluster_name" {
  value       = local.cluster_name
  description = "The name of the created cluster"
}

output "cluster_oidc_issuer_url" {
  value       = module.cluster.cluster_oidc_issuer_url
  description = "The Cluster OIDC Issuer URL"
}


// ----------------------------------------------------------------------------
// Generated IAM Roles
// ----------------------------------------------------------------------------
output "cert_manager_iam_role" {
  value       = module.cluster.cert_manager_iam_role
  description = "The IAM Role that the Cert Manager pod will assume to authenticate"
}

output "tekton_bot_iam_role" {
  value       = module.cluster.tekton_bot_iam_role
  description = "The IAM Role that the build pods will assume to authenticate"
}

output "external_dns_iam_role" {
  value       = module.cluster.external_dns_iam_role
  description = "The IAM Role that the External DNS pod will assume to authenticate"
}

output "cm_cainjector_iam_role" {
  value       = module.cluster.cm_cainjector_iam_role
  description = "The IAM Role that the CM CA Injector pod will assume to authenticate"
}

output "controllerbuild_iam_role" {
  value       = module.cluster.controllerbuild_iam_role
  description = "The IAM Role that the ControllerBuild pod will assume to authenticate"
}

output "cluster_autoscaler_iam_role" {
  value       = module.cluster.cluster_autoscaler_iam_role
  description = "The IAM Role that the Jenkins X UI pod will assume to authenticate"
}

output "pipeline_viz_iam_role" {
  value       = module.cluster.pipeline_viz_iam_role
  description = "The IAM Role that the pipeline visualizer pod will assume to authenticate"
}

// ----------------------------------------------------------------------------
// Vault Resources
// ----------------------------------------------------------------------------
output "vault_unseal_bucket" {
  value       = module.vault.vault_unseal_bucket
  description = "The Vault storage bucket"
}

output "vault_dynamodb_table" {
  value       = module.vault.vault_dynamodb_table
  description = "The Vault DynamoDB table"
}

output "vault_kms_unseal" {
  value       = module.vault.kms_vault_unseal
  description = "The Vault KMS Key for encryption"
}

output "vault_user_id" {
  value       = length(module.vault.vault_user_id) > 0 ? module.vault.vault_user_id[0] : ""
  description = "The Vault IAM user id"
}

output "vault_user_secret" {
  value       = length(module.vault.vault_user_secret) > 0 ? module.vault.vault_user_secret[0] : ""
  description = "The Vault IAM user secret"
}

// ----------------------------------------------------------------------------
// DNS
// ----------------------------------------------------------------------------
output "subdomain_nameservers" {
  value = module.dns.subdomain_nameservers
}

// ----------------------------------------------------------------------------
// Connection string
// ----------------------------------------------------------------------------
output "connect" {
  description = <<EOT
"The cluster connection string to use once Terraform apply finishes,
this command is already executed as part of the apply, you may have to provide the region and
profile as environment variables "
EOT
  value       = "aws eks update-kubeconfig --name ${var.cluster_name}"
}