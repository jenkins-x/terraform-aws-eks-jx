// ----------------------------------------------------------------------------
// Module local variables
// ----------------------------------------------------------------------------
locals {
  jenkins-x-namespace    = "jx"
  cluster_trunc          = substr(var.cluster_name, 0, 35)
  cert-manager-namespace = "cert-manager"
  secret-infra-namespace = "secret-infra"
  git-operator-namespace = "jx-git-operator"
  project                = data.aws_caller_identity.current.account_id
  boot_iam_role          = var.create_asm_role ? module.iam_assumable_role_secrets-secrets-manager.this_iam_role_arn : var.boot_iam_role
}
