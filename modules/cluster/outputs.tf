
output "jx_namespace" {
    value = kubernetes_namespace.jx
}

output "cm_namespace" {
    value = kubernetes_namespace.cert_manager
}

output "cluster_oidc_issuer_url" {
    value = local.oidc_provider_url
}

// ----------------------------------------------------------------------------
// Long Term Storage S3 Buckets (Logs, Reports, Repository)
// ----------------------------------------------------------------------------
output "logs_jenkins_x" {
    value = aws_s3_bucket.logs_jenkins_x.*.id
}

output "reports_jenkins_x" {
    value = aws_s3_bucket.reports_jenkins_x.*.id
}

output "repository_jenkins_x" {
    value = aws_s3_bucket.repository_jenkins_x.*.id
}

// ----------------------------------------------------------------------------
// Generated IAM Roles
// ----------------------------------------------------------------------------
output "cert_manager_iam_role" {
  value       = module.iam_assumable_role_cert_manager
  description = "The IAM Role that the Cert Manager pod will assume to authenticate"
}

output "tekton_bot_iam_role" {
  value       = module.iam_assumable_role_tekton_bot
  description = "The IAM Role that the build pods will assume to authenticate"
}

output "external_dns_iam_role" {
  value       = module.iam_assumable_role_external_dns
  description = "The IAM Role that the External DNS pod will assume to authenticate"
}

output "cm_cainjector_iam_role" {
  value       = module.iam_assumable_role_cm_cainjector
  description = "The IAM Role that the CM CA Injector pod will assume to authenticate"
}

output "controllerbuild_iam_role" {
  value       = module.iam_assumable_role_controllerbuild
  description = "The IAM Role that the ControllerBuild pod will assume to authenticate"
}

output "jxui_iam_role" {
  value       = module.iam_assumable_role_jxui
  description = "The IAM Role that the Jenkins X UI pod will assume to authenticate"
}
