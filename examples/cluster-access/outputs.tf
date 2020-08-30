output "jx_requirements" {
  value       = module.eks-jx.jx_requirements
  description = "The templated jx-requirements.yml"
}

output "vault_user_id" {
  value       = module.eks-jx.vault_user_id
  description = "The Vault IAM user id"
}

output "vault_user_secret" {
  value       = module.eks-jx.vault_user_secret
  description = "The Vault IAM user secret"
}
