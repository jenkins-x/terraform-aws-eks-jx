variable "region" {
  description = "The region to create the resources into"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  type = string
}

variable "profile" {
  description = "The AWS Profile used to provision the EKS Cluster"
  type        = string
  default     = null
}
// ----------------------------------------------------------------------------
// Flag Variables
// ----------------------------------------------------------------------------
variable "enable_logs_storage" {
  type    = bool
  default = true
}

variable "expire_logs_after_day" {
  description = "Number of days objects in the logs bucket are stored"
  type = number
  default = 90
}

variable "enable_worker_group" {
  description = "Flag to enable worker group. Setting this to false will provision a node group instead"
  type        = bool
  default     = true
}

variable "enable_reports_storage" {
  type    = bool
  default = true
}

variable "enable_repository_storage" {
  type    = bool
  default = true
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

variable "s3_default_tags" {
  description = "Default tags for s3 buckets"
  type        = map(any)
  default     = { Owner = "Jenkins-x" }
}

variable "s3_extra_tags" {
  description = "Add new tags for s3 buckets"
  type        = map(any)
  default     = {}
}

variable "s3_kms_arn" {
  description = "ARN of the kms key used for encrypting s3 buckets"
  type        = string
  default     = ""
}

variable "content" {
  description = "Interpolated jx-requirements.yml"
  type        = string
  default     = ""
}

variable "jx_git_operator_values" {
  description = "Extra values for jx-git-operator chart as a list of yaml formated strings"
  type        = list(string)
  default     = []
}

variable "jx_git_url" {
  description = "URL for the Jenins X cluster git repository"
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

variable "vpc_id" {
  description = "The VPC to create EKS cluster in if create_vpc is false"
  type        = string
  default     = ""
}

variable "subnets" {
  description = "The subnet ids to create EKS cluster in if create_vpc is false"
  type        = list(string)
  default     = []
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

variable "local-exec-interpreter" {
  description = "If provided, this is a list of interpreter arguments used to execute the command"
  type        = list(string)
  default     = ["/bin/bash", "-c"]
}

// ----------------------------------------------------------------------------
//  Customer's Certificates
// ----------------------------------------------------------------------------
variable "tls_key" {
  description = "Path to TLS key or base64-encrypted content"
  type        = string
  default     = ""
}

variable "tls_cert" {
  description = "Path to TLS certificate or base64-encrypted content"
  type        = string
  default     = ""
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

variable "use_asm" {
  description = "Flag to specify if AWS Secrets manager is being used"
  type        = bool
  default     = false
}

variable "boot_iam_role" {
  description = "Specify arn of the role to apply to the boot job service account"
  type        = string
  default     = ""
}

variable "enable_acl" {
  description = "Flag to enable ACL instead of bucket ownership for S3 storage"
  type        = bool
}
