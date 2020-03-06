output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "cluster_name" {
  value = var.cluster_name
}
