autoUpdate:
  enabled: false
  schedule: ""
terraform: true
cluster:
  clusterName: ${cluster_name}
  environmentGitOwner: ""
  environmentGitPublic: true
  provider: eks
  region: ${region}
gitops: true
environments:
  - key: dev
  - key: staging
  - key: production
ingress:
  ignoreLoadBalancer: true
  externalDNS: ${enable_external_dns}
  tls:
    email: ${tls_email}
    enabled: ${enable_tls}
    production: ${use_production_letsencrypt}
kaniko: true
secretStorage: vault

versionStream:
  ref: master
  url: https://github.com/jenkins-x/jenkins-x-versions.git
webhook: prow
