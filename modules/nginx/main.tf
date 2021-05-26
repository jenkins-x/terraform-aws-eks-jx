resource "helm_release" "nginx-ingress" {
  count            = var.create_nginx && !var.is_jx2 ? 1 : 0
  name             = var.nginx_release_name
  chart            = "ingress-nginx"
  namespace        = var.nginx_namespace
  repository       = "https://kubernetes.github.io/ingress-nginx"
  version          = var.nginx_chart_version
  create_namespace = var.create_nginx_namespace
  values = [
    fileexists("${path.cwd}/${var.nginx_values_file}") ? "${file("${path.cwd}/${var.nginx_values_file}")}" : "${file("${path.module}/${var.nginx_values_file}")}"
  ]
}
