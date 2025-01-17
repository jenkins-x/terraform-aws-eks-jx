// ----------------------------------------------------------------------------
// Jenkins X Requirements
// ----------------------------------------------------------------------------
output "jx_requirements" {
  description = "The jx-requirements rendered output"
  value       = local.content
}

// ----------------------------------------------------------------------------
// Storage (logs, reports, repo)
// ----------------------------------------------------------------------------
output "lts_logs_bucket" {
  value       = length(module.cluster.logs_jenkins_x) > 0 ? module.cluster.logs_jenkins_x[0] : ""
  description = "The bucket where logs from builds will be stored"
}

output "lts_reports_bucket" {
  value       = length(module.cluster.reports_jenkins_x) > 0 ? module.cluster.reports_jenkins_x[0] : ""
  description = "The bucket where test reports will be stored"
}

output "lts_repository_bucket" {
  value       = length(module.cluster.repository_jenkins_x) > 0 ? module.cluster.repository_jenkins_x[0] : ""
  description = "The bucket that will serve as artifacts repository"
}

// ----------------------------------------------------------------------------
// Cluster
// ----------------------------------------------------------------------------

output "cluster_name" {
  value       = var.cluster_name
  description = "The name of the created cluster"
}

// ----------------------------------------------------------------------------
// Generated IAM Roles
// ----------------------------------------------------------------------------
output "cert_manager_iam_role" {
  value       = module.cluster.cert_manager_iam_role
  description = "The IAM Role that the Cert Manager pod will assume to authenticate"
}

output "tekton_bot_iam_role" {
  value       = module.cluster.tekton_bot_iam_role
  description = "The IAM Role that the build pods will assume to authenticate"
}

output "external_dns_iam_role" {
  value       = module.cluster.external_dns_iam_role
  description = "The IAM Role that the External DNS pod will assume to authenticate"
}

output "cm_cainjector_iam_role" {
  value       = module.cluster.cm_cainjector_iam_role
  description = "The IAM Role that the CM CA Injector pod will assume to authenticate"
}

output "controllerbuild_iam_role" {
  value       = module.cluster.controllerbuild_iam_role
  description = "The IAM Role that the ControllerBuild pod will assume to authenticate"
}

output "cluster_autoscaler_iam_role" {
  value       = module.cluster.cluster_autoscaler_iam_role
  description = "The IAM Role that the Jenkins X UI pod will assume to authenticate"
}

output "pipeline_viz_iam_role" {
  value       = module.cluster.pipeline_viz_iam_role
  description = "The IAM Role that the pipeline visualizer pod will assume to authenticate"
}

output "cluster_asm_iam_role" {
  value       = module.cluster.cluster_asm_iam_role
  description = "The IAM Role that the External Secrets pod will assume to authenticate (Secrets Manager)"
}

output "cluster_ssm_iam_role" {
  value       = module.cluster.cluster_ssm_iam_role
  description = "The IAM Role that the External Secrets pod will assume to authenticate (Parameter Store)"

}

// ----------------------------------------------------------------------------
// DNS
// ----------------------------------------------------------------------------
output "subdomain_nameservers" {
  value = module.dns.subdomain_nameservers
}

// ----------------------------------------------------------------------------
// Connection string
// ----------------------------------------------------------------------------
output "connect" {
  description = <<EOT
The cluster connection string to use once Terraform apply finishes. You may have to provide the region and
profile (as options or environment variables)
EOT
  value       = "aws eks update-kubeconfig --name ${var.cluster_name}"
}
