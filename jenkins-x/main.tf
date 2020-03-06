// Jenkins X Resources

resource "kubernetes_namespace" "jx" {
  metadata {
    name = local.jenkins-x-namespace
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = local.cert-manager-namespace
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }
}

resource "aws_s3_bucket" "logs-jenkins-x" {
  count = var.enable_logs_storage ? 1 : 0
  bucket_prefix = "logs-${var.cluster_name}-"
  acl    = "private"

  tags = {
    Owner = "Jenkins-x"
  }
}

resource "aws_s3_bucket" "reports-jenkins-x" {
  count = var.enable_reports_storage ? 1 : 0
  bucket_prefix = "reports-${var.cluster_name}-"
  acl    = "private"

  tags = {
    Owner = "Jenkins-x"
  }
}

resource "aws_s3_bucket" "repository-jenkins-x" {
  count = var.enable_repository_storage ? 1 : 0
  bucket_prefix = "repository-${var.cluster_name}-"
  acl    = "private"

  tags = {
    Owner = "Jenkins-x"
  }
}

# Route53

data "aws_route53_zone" "apex_domain_zone" {
  name = "${var.apex_domain}."
}

resource "aws_route53_zone" "subdomain_zone" {
  count = var.create_and_configure_subdomain ? 1 : 0
  name = join(".", [var.subdomain, var.apex_domain])
}

resource "aws_route53_record" "subdomain_ns_delegation" {
  count = var.create_and_configure_subdomain ? 1 : 0
  zone_id = data.aws_route53_zone.apex_domain_zone.zone_id
  name    = join(".", [var.subdomain, var.apex_domain])
  type    = "NS"
  ttl     = 30
  records = [
    "${aws_route53_zone.subdomain_zone[0].name_servers.0}",
    "${aws_route53_zone.subdomain_zone[0].name_servers.1}",
    "${aws_route53_zone.subdomain_zone[0].name_servers.2}",
    "${aws_route53_zone.subdomain_zone[0].name_servers.3}",
  ]
}
