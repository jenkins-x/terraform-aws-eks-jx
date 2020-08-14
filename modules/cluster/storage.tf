// ----------------------------------------------------------------------------
// Create the AWS S3 buckets for Long Term Storage based on flags
// See https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
// ----------------------------------------------------------------------------
locals {
  encryption_algo = var.use_kms_s3 ? "aws:kms" : "AES256"
}

resource "aws_s3_bucket" "logs_jenkins_x" {
  count         = var.enable_logs_storage ? 1 : 0
  bucket_prefix = "logs-${var.cluster_name}-"
  acl           = "private"
  tags = {
    Owner = "Jenkins-x"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = local.encryption_algo
        kms_master_key_id = var.s3_kms_arn
      }
    }
  }
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket" "reports_jenkins_x" {
  count         = var.enable_reports_storage ? 1 : 0
  bucket_prefix = "reports-${var.cluster_name}-"
  acl           = "private"
  tags = {
    Owner = "Jenkins-x"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = local.encryption_algo
        kms_master_key_id = var.s3_kms_arn
      }
    }
  }
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket" "repository_jenkins_x" {
  count         = var.enable_repository_storage ? 1 : 0
  bucket_prefix = "repository-${var.cluster_name}-"
  acl           = "private"
  tags = {
    Owner = "Jenkins-x"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = local.encryption_algo
        kms_master_key_id = var.s3_kms_arn
      }
    }
  }
  force_destroy = var.force_destroy
}
