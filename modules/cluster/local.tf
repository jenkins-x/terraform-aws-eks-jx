resource "random_string" "suffix" {
  length  = 8
  special = false
}

// ----------------------------------------------------------------------------
// Module local variables
// ----------------------------------------------------------------------------
locals {
  generated_seed         = random_string.suffix.result
  oidc_provider_url      = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  jenkins-x-namespace    = "jx"
  cluster_trunc          = substr(var.cluster_name, 0, 40)
  cert-manager-namespace = "cert-manager"
}
