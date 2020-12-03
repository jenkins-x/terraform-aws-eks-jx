output "domain" {
  value = trimprefix(join(".", [var.subdomain, var.apex_domain]), ".")
}

output "subdomain_nameservers" {
  value = var.manage_subdomain && length(aws_route53_zone.subdomain_zone) > 0 ? aws_route53_zone.subdomain_zone[0].name_servers : []
}
