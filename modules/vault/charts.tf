resource "helm_release" "vault-operator" {
  count            = var.resource_count
  name             = "vault-operator"
  chart            = "vault-operator"
  namespace        = "jx-vault"
  repository       = "oci://ghcr.io/bank-vaults/helm-charts"
  version          = "1.22.3"
  create_namespace = true
  values           = var.vault_operator_values
}

resource "helm_release" "vault-instance" {
  count      = var.resource_count
  name       = "vault-instance"
  chart      = "vault-instance"
  namespace  = "jx-vault"
  repository = "https://jenkins-x-charts.github.io/repo"
  version    = "1.1.0"
  depends_on = [helm_release.vault-operator]
  set {
    name  = "ingress.enabled"
    value = "false"
  }

  set {
    name  = "bankVaultsImage"
    value = "ghcr.io/bank-vaults/bank-vaults:v1.31.2"
  }
  values = var.vault_instance_values
}
