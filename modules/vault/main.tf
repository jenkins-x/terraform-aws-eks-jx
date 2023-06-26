// ----------------------------------------------------------------------------
// If the Vault IAM user does exist create one
// See https://www.terraform.io/docs/providers/aws/r/iam_user.html
// ----------------------------------------------------------------------------

data "aws_partition" "current" {}
locals {
  encryption_algo = var.use_kms_s3 ? "aws:kms" : "AES256"
}

resource "aws_iam_user" "jenkins-x-vault" {
  count = !var.external_vault && var.vault_user == "" && var.use_vault ? 1 : 0

  name = "jenkins-x-vault"
}

resource "aws_iam_access_key" "jenkins-x-vault" {
  count = !var.external_vault && var.vault_user == "" && var.use_vault ? 1 : 0

  user = aws_iam_user.jenkins-x-vault[0].name
}

data "aws_caller_identity" "current" {}

data "aws_iam_user" "vault_user" {
  count = local.create_vault_resources ? 1 : 0

  user_name  = var.vault_user == "" ? aws_iam_user.jenkins-x-vault[0].name : var.vault_user
  depends_on = [aws_iam_user.jenkins-x-vault]
}

// ----------------------------------------------------------------------------
// Vault S3 bucket
// See https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
// ----------------------------------------------------------------------------
resource "aws_s3_bucket" "vault-unseal-bucket" {
  count = local.create_vault_resources ? 1 : 0

  bucket_prefix = "vault-unseal-${lower(var.cluster_name)}-"
  tags = {
    Name = "Vault unseal bucket"
  }
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_acl" "vault-unseal-bucket" {
  count  = local.create_vault_resources && var.enable_acl ? 1 : 0
  bucket = aws_s3_bucket.vault-unseal-bucket[0].bucket
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "vault-unseal-bucket" {
  count  = local.create_vault_resources && var.enable_acl ? 1 : 0
  bucket = aws_s3_bucket.vault-unseal-bucket[0].bucket

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "vault-unseal-bucket" {
  count  = local.create_vault_resources ? 1 : 0
  bucket = aws_s3_bucket.vault-unseal-bucket[0].bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vault-unseal-bucket" {
  count  = local.create_vault_resources ? 1 : 0
  bucket = aws_s3_bucket.vault-unseal-bucket[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.encryption_algo
      kms_master_key_id = var.s3_kms_arn
    }
  }
}

// ----------------------------------------------------------------------------
// Vault DynamoDB Table
// See https://www.terraform.io/docs/providers/aws/r/dynamodb_table.html
// ----------------------------------------------------------------------------
resource "aws_dynamodb_table" "vault-dynamodb-table" {
  count = local.create_vault_resources ? 1 : 0

  name           = "vault-unseal-${var.cluster_name}-${local.vault_seed}"
  billing_mode   = (var.enable_provisioned_dynamodb ? "PROVISIONED" : "PAY_PER_REQUEST")
  read_capacity  = (var.enable_provisioned_dynamodb ? var.billing_rcu : null)
  write_capacity = (var.enable_provisioned_dynamodb ? var.billing_wcu : null)
  hash_key       = "Path"
  range_key      = "Key"

  attribute {
    name = "Path"
    type = "S"
  }

  attribute {
    name = "Key"
    type = "S"
  }

  tags = {
    Name = "vault-dynamo-db-table"
  }

  lifecycle {
    ignore_changes = [
      read_capacity,
      write_capacity
    ]
  }
}

// ----------------------------------------------------------------------------
// Vault KMS Key
// See https://www.terraform.io/docs/providers/aws/r/kms_key.html
// ----------------------------------------------------------------------------
resource "aws_kms_key" "kms_vault_unseal" {
  count = local.create_vault_resources ? 1 : 0

  description         = "KMS Key for bank vault unseal"
  enable_key_rotation = var.enable_key_rotation
  policy              = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EnableIAMUserPermissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "${length(data.aws_iam_user.vault_user) > 0 ? data.aws_iam_user.vault_user[0].arn : ""}",
                    "${data.aws_caller_identity.current.arn}",
                    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
                ]
            },
            "Action": "kms:*",
            "Resource": "*"
        }
    ]
}
POLICY
}

// ----------------------------------------------------------------------------
// Permissions that will need to be attached to the provides IAM Username
// We will use this IAM User's private keys to authenticate the Vault pod
// against AWS
// ----------------------------------------------------------------------------
data "aws_iam_policy_document" "vault_iam_user_policy_document" {
  count = local.create_vault_resources ? 1 : 0

  depends_on = [
    aws_dynamodb_table.vault-dynamodb-table,
    aws_s3_bucket.vault-unseal-bucket,
    aws_kms_key.kms_vault_unseal,
  ]

  statement {
    sid    = "DynamoDB"
    effect = "Allow"

    actions = [
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource",
      "dynamodb:DescribeReservedCapacityOfferings",
      "dynamodb:DescribeReservedCapacity",
      "dynamodb:ListTables",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:CreateTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:Scan",
      "dynamodb:DescribeTable",
    ]

    resources = [aws_dynamodb_table.vault-dynamodb-table[0].arn]
  }

  statement {
    sid    = "S3"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]

    resources = ["${aws_s3_bucket.vault-unseal-bucket[0].arn}/*"]
  }

  statement {
    sid    = "S3List"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.vault-unseal-bucket[0].arn]
  }

  statement {
    sid    = "KMS"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
    ]

    resources = [aws_kms_key.kms_vault_unseal[0].arn]
  }
}

resource "aws_iam_policy" "aws_vault_user_policy" {
  count = local.create_vault_resources ? 1 : 0

  name_prefix = "vault_${var.region}-"
  description = "Vault Policy for the provided IAM User"
  policy      = data.aws_iam_policy_document.vault_iam_user_policy_document[0].json
}

resource "aws_iam_user_policy_attachment" "attach_vault_policy_to_user" {
  count = local.create_vault_resources ? 1 : 0

  user       = data.aws_iam_user.vault_user[0].user_name
  policy_arn = aws_iam_policy.aws_vault_user_policy[0].arn
}
