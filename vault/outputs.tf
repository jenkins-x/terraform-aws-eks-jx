

output "kms_vault_unseal" {
    value = var.create_vault_resources ? aws_kms_key.kms_vault_unseal[0].id : null
}

output "vault_unseal_bucket" {
    value = var.create_vault_resources ? aws_s3_bucket.vault-unseal-bucket[0].id : null
}

output "vault_dynamodb_table" {
    value = var.create_vault_resources ? aws_dynamodb_table.vault-dynamodb-table[0].id : null
}
