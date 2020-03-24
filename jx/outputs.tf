
// ----------------------------------------------------------------------------
// Long Term Storage S3 Buckets (Logs, Reports, Repository)
// ----------------------------------------------------------------------------
output "logs-jenkins-x" {
    value = aws_s3_bucket.logs-jenkins-x[0].id
}

output "reports-jenkins-x" {
    value = aws_s3_bucket.reports-jenkins-x[0].id
}

output "repository-jenkins-x" {
    value = aws_s3_bucket.repository-jenkins-x[0].id
}

// ----------------------------------------------------------------------------
// Generated IAM Roles
// ----------------------------------------------------------------------------
output "cert_manager_iam_role" {
  value = module.iam_assumable_role_cert_manager
}

output "tekton_bot_iam_role" {
    value = module.iam_assumable_role_tekton_bot
}

output "external_dns_iam_role" {
    value = module.iam_assumable_role_external_dns
}

output "cm_cainjector_iam_role" {
    value = module.iam_assumable_role_cm_cainjector
}

output "controllerbuild_iam_role" {
    value = module.iam_assumable_role_controllerbuild
}

output "jxui_iam_role" {
    value = module.iam_assumable_role_jxui
}