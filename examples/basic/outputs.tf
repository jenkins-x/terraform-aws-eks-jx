output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cluster_id" {
  value = module.eks.cluster_id
}

//// Storage (logs, reports, repo)
//
//output "lts_logs_bucket" {
//  value       = module.eks-jx.lts_logs_bucket
//  description = "The bucket where logs from builds will be stored"
//}
//
//output "lts_reports_bucket" {
//  value       = module.eks-jx.lts_reports_bucket
//  description = "The bucket where test reports will be stored"
//}
//
//output "lts_repository_bucket" {
//  value       = module.eks-jx.lts_reports_bucket
//  description = "The bucket that will serve as artifacts repository"
//}
//
//// IAM Roles
//output "cert_manager_iam_role" {
//  value       = module.eks-jx.cert_manager_iam_role
//  description = "The IAM Role that the Cert Manager pod will assume to authenticate"
//}
//
//output "tekton_bot_iam_role" {
//  value       = module.eks-jx.tekton_bot_iam_role
//  description = "The IAM Role that the build pods will assume to authenticate"
//}
//
//output "external_dns_iam_role" {
//  value       = module.eks-jx.external_dns_iam_role
//  description = "The IAM Role that the External DNS pod will assume to authenticate"
//}
//
//output "cm_cainjector_iam_role" {
//  value       = module.eks-jx.cm_cainjector_iam_role
//  description = "The IAM Role that the CM CA Injector pod will assume to authenticate"
//}
//
//output "controllerbuild_iam_role" {
//  value       = module.eks-jx.controllerbuild_iam_role
//  description = "The IAM Role that the ControllerBuild pod will assume to authenticate"
//}
//
//output "cluster_autoscaler_iam_role" {
//  value       = module.eks-jx.cluster_autoscaler_iam_role
//  description = "The IAM Role that the Jenkins X UI pod will assume to authenticate"
//}
//
//// Cluster specific output
//output "cluster_name" {
//  value       = module.eks-jx.cluster_name
//  description = "The name of the created cluster"
//}
//
//output "cluster_oidc_issuer_url" {
//  value       = module.eks-jx.cluster_oidc_issuer_url
//  description = "The Cluster OIDC Issuer URL"
//}
