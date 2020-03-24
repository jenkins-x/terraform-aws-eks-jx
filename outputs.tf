output "lts_logs_bucket" {
  value = module.jx.logs-jenkins-x
}

output "lts_reports_bucket" {
  value = module.jx.reports-jenkins-x
}

output "lts_repository_bucket" {
  value = module.jx.repository-jenkins-x
}

output "cluster_name" {
  value = var.cluster_name
}

output "cert_manager_iam_role" {
  value = module.jx.cert_manager_iam_role
}

output "tekton_bot_iam_role" {
  value = module.jx.tekton_bot_iam_role
}

output "external_dns_iam_role" {
  value = module.jx.external_dns_iam_role
}

output "cm_cainjector_iam_role" {
  value = module.jx.cm_cainjector_iam_role
}

output "controllerbuild_iam_role" {
  value = module.jx.controllerbuild_iam_role
}

output "jxui_iam_role" {
  value = module.jx.jxui_iam_role
}

output "vault_unseal_bucket" {
  value = module.vault.vault_unseal_bucket
}

output "vault_dynamodb_table" {
  value = module.vault.vault_dynamodb_table
}

output "vault_kms_unseal" {
  value = module.vault.kms_vault_unseal
}