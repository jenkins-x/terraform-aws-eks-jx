// ----------------------------------------------------------------------------
// Create the AWS S3 buckets for Long Term Storage based on flags
// See https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
// ----------------------------------------------------------------------------
resource "aws_s3_bucket" "logs_jenkins_x" {
  count         = var.enable_logs_storage ? 1 : 0
  bucket_prefix = "logs-${var.cluster_name}-"
  acl           = "private"
  tags = {
    Owner = "Jenkins-x"
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
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket" "repository_jenkins_x" {
  count         = var.enable_repository_storage ? 1 : 0
  bucket_prefix = "repository-${var.cluster_name}-"
  acl           = "private"
  tags = {
    Owner = "Jenkins-x"
  }
  force_destroy = var.force_destroy
}
