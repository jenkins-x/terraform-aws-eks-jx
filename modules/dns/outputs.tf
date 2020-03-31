output "domain" {
    value = trimprefix(join(".", [var.subdomain, var.apex_domain]), ".")
}