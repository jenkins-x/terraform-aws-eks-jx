// ----------------------------------------------------------------------------
// Create the AWS S3 buckets for Long Term Storage based on flags
// See https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
// ----------------------------------------------------------------------------
locals {
  encryption_algo = var.use_kms_s3 ? "aws:kms" : "AES256"
}

// ------------------------------
//Configuration for log bucket
// ------------------------------

resource "aws_s3_bucket" "logs_jenkins_x" {
  count         = var.enable_logs_storage ? 1 : 0
  bucket_prefix = "logs-${lower(var.cluster_name)}-"
  tags          = merge(var.s3_default_tags, var.s3_extra_tags)
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_acl" "logs_jenkins_x" {
  count  = var.enable_logs_storage && var.enable_acl ? 1 : 0
  bucket = aws_s3_bucket.logs_jenkins_x[0].bucket
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "logs_jenkins_x" {
  count  = var.enable_logs_storage && var.enable_acl ? 1 : 0
  bucket = aws_s3_bucket.logs_jenkins_x[0].bucket

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs_jenkins_x" {
  count  = var.enable_logs_storage ? 1 : 0
  bucket = aws_s3_bucket.logs_jenkins_x[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.encryption_algo
      kms_master_key_id = var.s3_kms_arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs_jenkins_x" {
  count  = var.enable_logs_storage ? 1 : 0
  bucket = aws_s3_bucket.logs_jenkins_x[0].id
  rule {
    status = "Enabled"
    id     = "abort_incomplete_uploads"
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    filter {}
  }
  rule {
    status = "Enabled"
    id     = "delete_old"
    expiration {
      expired_object_delete_marker = false
    }
    filter {}
  }
  rule {
    status = "Enabled"
    id     = "delete_marker"
    expiration {
      days = var.expire_logs_after_days
    }
    filter {}
  }
}

// ---------------------------------
// Configuration for reports bucket
// ---------------------------------
resource "aws_s3_bucket" "reports_jenkins_x" {
  count         = var.enable_reports_storage ? 1 : 0
  bucket_prefix = "reports-${lower(var.cluster_name)}-"
  tags          = merge(var.s3_default_tags, var.s3_extra_tags)
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_acl" "reports_jenkins_x" {
  count  = var.enable_reports_storage && var.enable_acl ? 1 : 0
  bucket = aws_s3_bucket.reports_jenkins_x[0].bucket
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "reports_jenkins_x" {
  count  = var.enable_reports_storage && var.enable_acl ? 1 : 0
  bucket = aws_s3_bucket.reports_jenkins_x[0].bucket

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "reports_jenkins_x" {
  count  = var.enable_reports_storage ? 1 : 0
  bucket = aws_s3_bucket.reports_jenkins_x[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.encryption_algo
      kms_master_key_id = var.s3_kms_arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "reports_jenkins_x" {
  count  = var.enable_reports_storage ? 1 : 0
  bucket = aws_s3_bucket.reports_jenkins_x[0].id
  rule {
    status = "Enabled"
    id     = "abort_incomplete_uploads"
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    filter {}
  }
}

// ------------------------------------
// Configuration for repository bucket
// ------------------------------------

resource "aws_s3_bucket" "repository_jenkins_x" {
  count         = var.enable_repository_storage ? 1 : 0
  bucket_prefix = "repository-${lower(var.cluster_name)}-"
  tags          = merge(var.s3_default_tags, var.s3_extra_tags)
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_acl" "repository_jenkins_x" {
  count  = var.enable_repository_storage && var.enable_acl ? 1 : 0
  bucket = aws_s3_bucket.repository_jenkins_x[0].bucket
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "repository_jenkins_x" {
  count  = var.enable_repository_storage && var.enable_acl ? 1 : 0
  bucket = aws_s3_bucket.repository_jenkins_x[0].bucket

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "repository_jenkins_x" {
  count  = var.enable_repository_storage ? 1 : 0
  bucket = aws_s3_bucket.repository_jenkins_x[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.encryption_algo
      kms_master_key_id = var.s3_kms_arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "repository_jenkins_x" {
  count  = var.enable_repository_storage ? 1 : 0
  bucket = aws_s3_bucket.repository_jenkins_x[0].id
  rule {
    status = "Enabled"
    id     = "abort_incomplete_uploads"
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    filter {}
  }
}
