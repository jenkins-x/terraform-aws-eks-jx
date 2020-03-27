
// ----------------------------------------------------------------------------
// The created KMS Key ID
// ----------------------------------------------------------------------------
output "kms_vault_unseal" {
    value = aws_kms_key.kms_vault_unseal.id
}

// ----------------------------------------------------------------------------
// The created S3 Bucket ID
// ----------------------------------------------------------------------------
output "vault_unseal_bucket" {
    value = aws_s3_bucket.vault-unseal-bucket.id
}

// ----------------------------------------------------------------------------
// The created DynamoDB ID
// ----------------------------------------------------------------------------
output "vault_dynamodb_table" {
    value = aws_dynamodb_table.vault-dynamodb-table.id
}
