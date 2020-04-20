output "vault_user_id" {
  value       = module.eks-jx.vault_user_id
  description = "The Vault IAM user id if one got created"
}

output "vault_user_secret" {
  value       = module.eks-jx.vault_user_secret
  description = "The Vault IAM user secret if one got created"
}
