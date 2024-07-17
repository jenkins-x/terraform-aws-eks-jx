resource "kubernetes_secret" "tls" {
  count = var.tls_key == "" || var.tls_cert == "" ? 0 : 1
  metadata {
    name      = "tls-ingress-certificates-ca"
    namespace = "default"
  }

  data = {
    "tls.crt" = try(file(var.tls_cert), base64decode(var.tls_cert))
    "tls.key" = try(file(var.tls_key), base64decode(var.tls_key))
  }

  type = "kubernetes.io/tls"
}
