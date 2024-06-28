autoUpdate:
  enabled: false
  schedule: ""
terraform: true
cluster:
  clusterName: "${cluster_name}"
  environmentGitOwner: ""
  provider: eks
  region: "${region}"
  registry: "${registry}"
  project: "${project}"
ingress:
  domain: "${domain}"
  ignoreLoadBalancer: ${ignoreLoadBalancer}
  externalDNS: ${enable_external_dns}
  tls:
    email: "${tls_email}"
    enabled: ${enable_tls}
    production: ${use_production_letsencrypt}
    %{ if tls_secret_name != ""}secretName: ${tls_secret_name}%{ endif }
%{ if use_vault }
secretStorage: vault
vault:
%{ if external_vault }
  url: ${vault_url}
%{ endif }
%{ endif }
%{ if use_asm }
secretStorage: secretsManager
%{ endif }
storage:
  backup:
    enabled: ${enable_backup}
%{ if enable_backup }
    url: s3://${backup_bucket_url}
%{ endif }
  logs:
    enabled: ${enable_logs_storage}
    url: s3://${logs_storage_bucket}
  reports:
    enabled: ${enable_reports_storage}
    url: s3://${reports_storage_bucket}
  repository:
    enabled: ${enable_repository_storage}
    url: s3://${repository_storage_bucket}
webhook: lighthouse
