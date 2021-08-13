module "eks-jx" {
  source     = "jenkins-x/eks-jx/aws"

  enable_external_dns = true
  apex_domain         = "office.com"
  subdomain           = "subdomain"
  enable_tls          = true
  tls_email           = "customer@office.com"

  // Signed Certificate must match the domain: *.subdomain.office.com
  tls_cert            = var.tls_cert
  tls_key             = var.tls_key
}
