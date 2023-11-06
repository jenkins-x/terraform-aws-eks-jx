resource "helm_release" "jx-git-operator" {
  count            = var.is_jx2 ? 0 : 1
  name             = "jx-git-operator"
  chart            = "jx-git-operator"
  namespace        = "jx-git-operator"
  repository       = "https://jenkins-x-charts.github.io/repo"
  version          = "0.1.7"
  create_namespace = true

  values = var.jx_git_operator_values

  set {
    name  = "bootServiceAccount.enabled"
    value = true
  }
  set {
    name  = "env.NO_RESOURCE_APPLY"
    value = true
  }
  set {
    name  = "url"
    value = var.jx_git_url
  }
  set {
    name  = "username"
    value = var.jx_bot_username
  }

  set {
    name  = "bootServiceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = local.boot_iam_role
  }

  set_sensitive {
    name  = "password"
    value = var.jx_bot_token
  }

  dynamic "set" {
    for_each = toset(var.boot_secrets)
    content {
      name  = set.value["name"]
      value = set.value["value"]
      type  = set.value["type"]
    }
  }

  depends_on = [
    null_resource.kubeconfig
  ]
}
