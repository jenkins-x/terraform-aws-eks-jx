// ----------------------------------------------------------------------------
// Create bucket for storing Velero backups 
//
// https://github.com/vmware-tanzu/velero
// https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
// https://github.com/vmware-tanzu/velero-plugin-for-aws#create-s3-bucket
// ----------------------------------------------------------------------------
locals {
  encryption_algo = var.use_kms_s3 ? "aws:kms" : "AES256"
}

resource "aws_s3_bucket" "backup_bucket" {
  count         = var.enable_backup ? 1 : 0
  bucket_prefix = "backup-${lower(var.cluster_name)}-"
  tags          = merge(var.s3_default_tags, var.s3_extra_tags)
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_acl" "backup_bucket" {
  count  = var.enable_backup && var.enable_acl ? 1 : 0
  bucket = aws_s3_bucket.backup_bucket[0].bucket
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "backup_bucket" {
  count  = var.enable_backup && var.enable_acl ? 1 : 0
  bucket = aws_s3_bucket.backup_bucket[0].bucket

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backup_bucket" {
  count  = var.enable_backup ? 1 : 0
  bucket = aws_s3_bucket.backup_bucket[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.encryption_algo
      kms_master_key_id = var.s3_kms_arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backup_bucket" {
  count  = var.enable_backup ? 1 : 0
  bucket   = aws_s3_bucket.backup_bucket[0].id
  rule {
    status = "Enabled"
    id     = "abort_incomplete_uploads"
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

// ----------------------------------------------------------------------------
// Setup IAM User and Policies for Velero
//
// https://github.com/vmware-tanzu/velero-plugin-for-aws#set-permissions-for-velero
// https://github.com/vmware-tanzu/velero/issues/3143
// ----------------------------------------------------------------------------
resource "aws_iam_user" "velero" {
  count = var.enable_backup ? 1 : 0
  name  = var.velero_username
}

resource "aws_iam_access_key" "velero" {
  count = var.enable_backup ? 1 : 0
  user  = aws_iam_user.velero[0].name
  depends_on = [
    aws_iam_user.velero
  ]
}

data "aws_iam_policy_document" "velero" {
  count = var.enable_backup && var.create_velero_role ? 1 : 0
  statement {
    sid    = "veleroPolicyEC2"
    effect = "Allow"

    actions = [
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot"
    ]

    resources = ["*"]
  }
  statement {
    sid    = "veleroPolicyS3Objects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]

    resources = ["${aws_s3_bucket.backup_bucket[0].arn}/*"]
  }
  statement {
    sid    = "veleroPolicyS3Bucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [aws_s3_bucket.backup_bucket[0].arn]
  }
}

resource "aws_iam_user_policy" "velero" {
  count  = var.enable_backup && var.create_velero_role ? 1 : 0
  name   = "velero"
  user   = aws_iam_user.velero[0].name
  policy = data.aws_iam_policy_document.velero[0].json
  depends_on = [
    aws_iam_user.velero
  ]
}

// ----------------------------------------------------------------------------
// Setup Kubernetes Velero namespace and service account
// ----------------------------------------------------------------------------

resource "kubernetes_secret" "credentials-velero" {
  count = var.enable_backup ? 1 : 0
  metadata {
    name      = "velero-secret"
    namespace = var.velero_namespace
  }

  data = {
    "cloud" = <<EOF
[default]
aws_access_key_id=${aws_iam_access_key.velero[0].id}
aws_secret_access_key=${aws_iam_access_key.velero[0].secret}
EOF
  }
}
