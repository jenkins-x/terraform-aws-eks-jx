resource "helm_release" "vault-operator" {
  count            = local.create_vault_resources ? 1 : 0
  name             = "vault-operator"
  chart            = "vault-operator"
  namespace        = "jx-vault"
  repository       = "https://kubernetes-charts.banzaicloud.com"
  version          = "1.10.0"
  create_namespace = true
}

resource "helm_release" "vault-instance" {
  count      = local.create_vault_resources ? 1 : 0
  name       = "vault-instance"
  chart      = "vault-instance"
  namespace  = "jx-vault"
  repository = "https://storage.googleapis.com/jenkinsxio/charts"
  version    = "1.0.15"
  depends_on = [helm_release.vault-operator]
}
