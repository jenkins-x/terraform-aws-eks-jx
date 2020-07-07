
// ----------------------------------------------------------------------------
// The created KMS Key ID
// ----------------------------------------------------------------------------
output "kms_vault_unseal" {
  value = length(aws_kms_key.kms_vault_unseal) > 0 ? aws_kms_key.kms_vault_unseal[0].id : ""

}

// ----------------------------------------------------------------------------
// The created S3 Bucket ID
// ----------------------------------------------------------------------------
output "vault_unseal_bucket" {
  value = length(aws_s3_bucket.vault-unseal-bucket) > 0 ? aws_s3_bucket.vault-unseal-bucket[0].id : ""
}

// ----------------------------------------------------------------------------
// The created DynamoDB ID
// ----------------------------------------------------------------------------
output "vault_dynamodb_table" {
  value = length(aws_dynamodb_table.vault-dynamodb-table) > 0 ? aws_dynamodb_table.vault-dynamodb-table[0].id : ""
}

// ----------------------------------------------------------------------------
// The Vault user id if one got created
// ----------------------------------------------------------------------------
output "vault_user_id" {
  value = var.vault_user == "" ? aws_iam_access_key.jenkins-x-vault.*.id : []
}

// ----------------------------------------------------------------------------
// The Vault user secret if one got created
// ----------------------------------------------------------------------------
output "vault_user_secret" {
  value = var.vault_user == "" ? aws_iam_access_key.jenkins-x-vault.*.secret : []
}
