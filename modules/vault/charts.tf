resource "helm_release" "vault-operator" {
  count            = var.resource_count
  name             = "vault-operator"
  chart            = "vault-operator"
  namespace        = "jx-vault"
  repository       = "https://kubernetes-charts.banzaicloud.com"
  version          = "1.14.3"
  create_namespace = true
}

resource "helm_release" "vault-instance" {
  count      = var.resource_count
  name       = "vault-instance"
  chart      = "vault-instance"
  namespace  = "jx-vault"
  repository = "https://jenkins-x-charts.github.io/repo"
  version    = "1.0.24"
  depends_on = [helm_release.vault-operator]
  set {
    name  = "ingress.enabled"
    value = "false"
  }
}
