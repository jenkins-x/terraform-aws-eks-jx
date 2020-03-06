resource "aws_s3_bucket" "vault-unseal-bucket" {
  count = var.create_vault_resources ? 1 : 0
  bucket_prefix = "vault-unseal-${var.cluster_name}-"
  acl    = "private"

  tags = {
    Name        = "Vault unseal bucket"
  }

  versioning {
    enabled = false
  }
}

resource "aws_dynamodb_table" "vault-dynamodb-table" {
  count = var.create_vault_resources ? 1 : 0
  name           = "vault-unseal-${var.cluster_name}-random19210290120"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 2
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
    Name        = "vault-dynamo-db-table"
  }
}

resource "aws_kms_key" "kms_vault_unseal" {
  count = var.create_vault_resources ? 1 : 0
  description             = "KMS Key for bank vault unseal"
  policy                  = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EnableIAMUserPermissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${var.account_id}:user/${var.vault_user}",
                    "arn:aws:iam::${var.account_id}:root"
                ]
            },
            "Action": "kms:*",
            "Resource": "*"
        }
    ]
}
POLICY
}

data "aws_iam_policy_document" "vault_iam_user_policy_document" {
  count = var.create_vault_resources ? 1 : 0
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
  count = var.create_vault_resources ? 1 : 0
  name_prefix = "vault_${var.region}-"
  description = "Vault Policy for the provided IAM User"
  policy      = data.aws_iam_policy_document.vault_iam_user_policy_document[0].json
}

resource "aws_iam_user_policy_attachment" "attach_vault_policy_to_user" {
  count = var.create_vault_resources ? 1 : 0
  user       = var.vault_user
  policy_arn = aws_iam_policy.aws_vault_user_policy[0].arn
}
