apiVersion: core.jenkins-x.io/v4beta1
kind: Requirements
spec:
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
%{ if tls_secret_name != ""}
      secretName: ${tls_secret_name}
%{ endif }
%{ if use_vault }
  secretStorage: vault
%{ if external_vault }
  vault:
    url: ${vault_url}
%{ endif }
  terraformVault: ${install_vault}
%{ endif }
%{ if use_asm }
  secretStorage: secretsManager
%{ endif }
  storage:
%{ if enable_logs_storage }
  - name: logs
    url: s3://${logs_storage_bucket}
%{ endif }
%{ if enable_reports_storage }
  - name: reports
    url: s3://${reports_storage_bucket}}
%{ endif }
%{ if enable_repository_storage }
  - name: repository
    url: s3://${repository_storage_bucket}
%{ endif }
  webhook: lighthouse
