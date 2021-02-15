
output "jx_namespace" {
  value = kubernetes_namespace.jx
}

output "cm_namespace" {
  value = kubernetes_namespace.cert_manager
}

output "cluster_oidc_issuer_url" {
  value = local.oidc_provider_url
}

output "cluster_host" {
  value = data.aws_eks_cluster.cluster.endpoint
}

output "cluster_ca_certificate" {
  value = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

output "cluster_token" {
  value = data.aws_eks_cluster_auth.cluster.token
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
  value       = module.iam_assumable_role_cert_manager.this_iam_role_name
  description = "The IAM Role that the Cert Manager pod will assume to authenticate"
}

output "tekton_bot_iam_role" {
  value       = module.iam_assumable_role_tekton_bot.this_iam_role_name
  description = "The IAM Role that the build pods will assume to authenticate"
}

output "external_dns_iam_role" {
  value       = module.iam_assumable_role_external_dns.this_iam_role_name
  description = "The IAM Role that the External DNS pod will assume to authenticate"
}

output "cm_cainjector_iam_role" {
  value       = module.iam_assumable_role_cm_cainjector.this_iam_role_name
  description = "The IAM Role that the CM CA Injector pod will assume to authenticate"
}

output "controllerbuild_iam_role" {
  value       = module.iam_assumable_role_controllerbuild.this_iam_role_name
  description = "The IAM Role that the ControllerBuild pod will assume to authenticate"
}

output "cluster_autoscaler_iam_role" {
  value       = module.iam_assumable_role_cluster_autoscaler.this_iam_role_name
  description = "The IAM Role that the Cluster Autoscaler pod will assume to authenticate"
}

output "pipeline_viz_iam_role" {
  value       = module.iam_assumable_role_pipeline_visualizer.this_iam_role_name
  description = "The IAM Role that the pipeline visualizer pod will assume to authenticate"
}
