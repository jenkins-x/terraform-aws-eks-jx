// ----------------------------------------------------------------------------
// Storage (logs, reports, repo)
// ----------------------------------------------------------------------------
output "lts_logs_bucket" {
  value       = module.cluster.logs_jenkins_x
  description = "The bucket where logs from builds will be stored"
}

output "lts_reports_bucket" {
  value       = module.cluster.reports_jenkins_x
  description = "The bucket where test reports will be stored"
}

output "lts_repository_bucket" {
  value       = module.cluster.repository_jenkins_x
  description = "The bucket that will serve as artifacts repository"
}


// ----------------------------------------------------------------------------
// Cluster Name
// ----------------------------------------------------------------------------
output "cluster_name" {
  value       = local.cluster_name
  description = "The name of the created cluster"
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

output "jxui_iam_role" {
  value       = module.cluster.jxui_iam_role
  description = "The IAM Role that the Jenkins X UI pod will assume to authenticate"
}

// ----------------------------------------------------------------------------
// Vault Resources
// ----------------------------------------------------------------------------
output "vault_unseal_bucket" {
  value       = module.vault.vault_unseal_bucket
  description = "The bucket that Vault will use for storage"
}

output "vault_dynamodb_table" {
  value       = module.vault.vault_dynamodb_table
  description = "The bucket that Vault will use as backend"
}

output "vault_kms_unseal" {
  value       = module.vault.kms_vault_unseal
  description = "The KMS Key that Vault will use for encryption"
}
