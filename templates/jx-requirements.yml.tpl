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
gitops: true
environments:
  - key: dev
  - key: staging
  - key: production
ingress:
  domain: "${domain}"
  ignoreLoadBalancer: ${ignoreLoadBalancer}
  externalDNS: ${enable_external_dns}
  tls:
    email: "${tls_email}"
    enabled: ${enable_tls}
    production: ${use_production_letsencrypt}
kaniko: true
%{ if use_vault }
secretStorage: vault
vault:
%{ if external_vault }
  url: ${vault_url}
%{ else }
  aws:
    iamUserName: "${vault_user}"
    dynamoDBTable: "${vault_dynamodb_table}"
    dynamoDBRegion: "${region}"
    kmsKeyId: "${vault_kms_key}"
    kmsRegion: "${region}"
    s3Bucket: "${vault_bucket}"
    s3Region: "${region}"
%{ endif }
%{ endif }
%{ if use_asm }
secretStorage: asm
%{ endif }
%{ if enable_backup }
velero:
  namespace: ${velero_namespace}
  schedule: "${velero_schedule}"
  ttl: "${velero_ttl}"  
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
versionStream:
  ref: master
  url: https://github.com/jenkins-x/jenkins-x-versions.git
webhook: lighthouse
