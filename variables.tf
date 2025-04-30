// ----------------------------------------------------------------------------
// Required Variables
// ----------------------------------------------------------------------------
variable "region" {
  description = "The region to create the resources into"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Variable to provide your desired name for the cluster"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "The oidc provider url for the clustrer"
  type        = string
}

// ----------------------------------------------------------------------------
// Vault
// ----------------------------------------------------------------------------

variable "vault_url" {
  description = "URL to an external Vault instance in case Jenkins X does not create its own system Vault"
  type        = string
  default     = ""
}

variable "install_vault" {
  description = "Whether or not this modules creates and manages the Vault instance. If set to false and use_vault is true either an external Vault URL needs to be provided or you need to install vault operator and instance using helmfile."
  type        = bool
  default     = true
}

variable "vault_operator_values" {
  description = "Extra values for vault-operator chart as a list of yaml formated strings"
  type        = list(string)
  default     = []
}

variable "vault_instance_values" {
  description = "Extra values for vault-instance chart as a list of yaml formated strings"
  type        = list(string)
  default     = []
}

// ----------------------------------------------------------------------------
// External DNS Variables
// ----------------------------------------------------------------------------
variable "apex_domain" {
  description = "The main domain to either use directly or to configure a subdomain from"
  type        = string
  default     = ""
}

variable "subdomain" {
  description = "The subdomain to be added to the apex domain. If subdomain is set, it will be appended to the apex domain in  `jx-requirements-eks.yml` file"
  type        = string
  default     = ""
}

variable "tls_email" {
  description = "The email to register the LetsEncrypt certificate with. Added to the `jx-requirements.yml` file"
  type        = string
  default     = ""
}

// ----------------------------------------------------------------------------
// Flag Variables
// ----------------------------------------------------------------------------
variable "enable_logs_storage" {
  description = "Flag to enable or disable long term storage for logs"
  type        = bool
  default     = true
}

variable "expire_logs_after_days" {
  description = "Number of days objects in the logs bucket are stored"
  type        = number
  default     = 90
}

variable "enable_reports_storage" {
  description = "Flag to enable or disable long term storage for reports"
  type        = bool
  default     = true
}

variable "enable_repository_storage" {
  description = "Flag to enable or disable the repository bucket storage"
  type        = bool
  default     = true
}

variable "enable_external_dns" {
  description = "Flag to enable or disable External DNS in the final `jx-requirements.yml` file"
  type        = bool
  default     = false
}

variable "create_and_configure_subdomain" {
  description = "Flag to create an NS record set for the subdomain in the apex domain's Hosted Zone"
  type        = bool
  default     = false
}

variable "force_destroy_subdomain" {
  description = "Flag to determine whether subdomain zone get forcefully destroyed. If set to false, empty the sub domain first in the aws Route 53 console, else terraform destroy will fail with HostedZoneNotEmpty error"
  type        = bool
  default     = false
}

variable "enable_tls" {
  description = "Flag to enable TLS in the final `jx-requirements.yml` file"
  type        = bool
  default     = false
}

variable "production_letsencrypt" {
  description = "Flag to use the production environment of letsencrypt in the `jx-requirements.yml` file"
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Flag to determine whether storage buckets get forcefully destroyed. If set to false, empty the bucket first in the aws s3 console, else terraform destroy will fail with BucketNotEmpty error"
  type        = bool
  default     = false
}

variable "use_kms_s3" {
  description = "Flag to determine whether kms should be used for encrypting s3 buckets"
  type        = bool
  default     = false
}

// ----------------------------------------------------------------------------
// Cluster AWS Auth Variables
// ----------------------------------------------------------------------------

variable "s3_kms_arn" {
  description = "ARN of the kms key used for encrypting s3 buckets"
  type        = string
  default     = ""
}

variable "s3_extra_tags" {
  description = "Add new tags for s3 buckets"
  type        = map(any)
  default     = {}
}

variable "ignoreLoadBalancer" {
  default     = false
  type        = bool
  description = "Flag to specify if jx boot will ignore loadbalancer DNS to resolve to an IP"
}

variable "registry" {
  description = "Registry used to store images"
  type        = string
  default     = ""
}

variable "jx_git_operator_values" {
  description = "Extra values for jx-git-operator chart as a list of yaml formated strings"
  type        = list(string)
  default     = []
}

variable "jx_git_url" {
  description = "URL for the Jenkins X cluster git repository"
  type        = string
  default     = ""
}

variable "jx_bot_username" {
  description = "Bot username used to interact with the Jenkins X cluster git repository"
  type        = string
  default     = ""
}

variable "jx_bot_token" {
  description = "Bot token used to interact with the Jenkins X cluster git repository"
  type        = string
  default     = ""
}

variable "use_vault" {
  description = "Flag to control vault resource creation"
  type        = bool
  default     = true
}

variable "use_asm" {
  description = "Flag to specify if AWS Secrets manager is being used"
  type        = bool
  default     = false
}

variable "asm_role" {
  description = "DEPRECATED: Use the new bot_iam_role input with he same semantics instead."
  type        = string
  default     = ""
}

variable "boot_iam_role" {
  description = "Specify arn of the role to apply to the boot job service account"
  type        = string
  default     = ""
}

variable "install_kuberhealthy" {
  description = "Flag to specify if kuberhealthy operator should be installed"
  type        = bool
  default     = false
}

variable "create_tekton_role" {
  description = "Flag to control tekton iam role creation"
  type        = bool
  default     = true
}

variable "create_exdns_role" {
  description = "Flag to control external dns iam role creation"
  type        = bool
  default     = true
}

variable "create_cm_role" {
  description = "Flag to control cert manager iam role creation"
  type        = bool
  default     = true
}

variable "create_cmcainjector_role" {
  description = "Flag to control cert manager ca-injector iam role creation"
  type        = bool
  default     = true
}

variable "create_ctrlb_role" {
  description = "Flag to control controller build iam role creation"
  type        = bool
  default     = true
}

variable "create_autoscaler_role" {
  description = "Flag to control cluster autoscaler iam role creation"
  type        = bool
  default     = true
}

variable "create_ssm_role" {
  description = "Flag to control AWS Parameter Store iam roles creation"
  type        = bool
  default     = false
}

variable "create_asm_role" {
  description = "Flag to control AWS Secrets Manager iam roles creation"
  type        = bool
  default     = false
}

variable "manage_apex_domain" {
  description = "Flag to control if apex domain should be managed/updated by this module. Set this to false,if your apex domain is managed in a different AWS account or different provider"
  default     = true
  type        = bool
}

variable "manage_subdomain" {
  description = "Flag to control subdomain creation/management"
  default     = true
  type        = bool
}

variable "create_pipeline_vis_role" {
  description = "Flag to control pipeline visualizer role"
  type        = bool
  default     = true
}

variable "create_bucketrepo_role" {
  description = "Flag to control bucketrepo role"
  type        = bool
  default     = true
}

variable "additional_tekton_role_policy_arns" {
  description = "Additional Policy ARNs to attach to Tekton IRSA Role"
  type        = list(string)
  default     = []
}

// ----------------------------------------------------------------------------
//  Customer's Certificates
// ----------------------------------------------------------------------------
variable "tls_key" {
  description = "TLS key encrypted with Base64"
  type        = string
  default     = ""
}

variable "tls_cert" {
  description = "TLS certificate encrypted with Base64"
  type        = string
  default     = ""
}

variable "create_nginx" {
  default     = false
  type        = bool
  description = "Decides whether we want to create nginx resources using terraform or not"
}

variable "nginx_release_name" {
  default     = "nginx-ingress"
  type        = string
  description = "Name of the nginx release name"
}

variable "nginx_namespace" {
  default     = "nginx"
  type        = string
  description = "Name of the nginx namespace"
}

variable "nginx_chart_version" {
  type        = string
  description = "nginx chart version"
  default = null
}

variable "create_nginx_namespace" {
  default     = true
  type        = bool
  description = "Boolean to control nginx namespace creation"
}

variable "nginx_values_file" {
  default     = "nginx_values.yaml"
  type        = string
  description = "Name of the values file which holds the helm chart values"
}

variable "boot_secrets" {
  description = ""
  type = list(object({
    name  = string
    value = string
    type  = string
  }))
  default = []
}
variable "enable_acl" {
  description = "Flag to enable ACL instead of bucket ownership for S3 storage"
  type        = bool
  default     = false
}


