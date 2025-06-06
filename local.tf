locals {
  external_vault  = var.vault_url != "" ? true : false
  registry        = var.registry != "" ? var.registry : "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
  project         = data.aws_caller_identity.current.account_id
  tls_secret_name = var.tls_key == "" || var.tls_cert == "" ? "" : "tls-ingress-certificates-ca"

  // ----------------------------------------------------------------------------
  // Let's generate jx-requirements.yml
  // ----------------------------------------------------------------------------

  interpolated_content = templatefile("${path.module}/templates/jx-requirements.yml.tpl", {
    cluster_name = var.cluster_name
    region       = var.region
    // Storage Buckets
    enable_logs_storage       = var.enable_logs_storage
    logs_storage_bucket       = length(module.cluster.logs_jenkins_x) > 0 ? module.cluster.logs_jenkins_x[0] : ""
    enable_reports_storage    = var.enable_reports_storage
    reports_storage_bucket    = length(module.cluster.reports_jenkins_x) > 0 ? module.cluster.reports_jenkins_x[0] : ""
    enable_repository_storage = var.enable_repository_storage
    repository_storage_bucket = length(module.cluster.repository_jenkins_x) > 0 ? module.cluster.repository_jenkins_x[0] : ""
    // Vault
    vault_url      = var.vault_url
    external_vault = local.external_vault
    use_vault      = var.use_vault
    install_vault  = var.install_vault
    // AWS Secrets Manager
    use_asm = var.use_asm
    // DNS
    tls_secret_name            = local.tls_secret_name
    enable_external_dns        = var.enable_external_dns
    domain                     = module.dns.domain
    enable_tls                 = var.enable_tls
    tls_email                  = var.tls_email
    use_production_letsencrypt = var.production_letsencrypt
    ignoreLoadBalancer         = var.ignoreLoadBalancer
    registry                   = local.registry
    project                    = local.project
  })

  split_content   = split("\n", local.interpolated_content)
  compact_content = compact(local.split_content)
  content         = join("\n", local.compact_content)
}
