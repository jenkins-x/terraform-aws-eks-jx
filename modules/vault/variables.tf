// ----------------------------------------------------------------------------
// Required Variables
// ----------------------------------------------------------------------------
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type = string
}

variable "vault_user" {
  type = string
}

variable "force_destroy" {
  description = "Flag to determine whether storage buckets get forcefully destroyed. If set to false, empty the bucket first in the aws s3 console, else terraform destroy will fail with BucketNotEmpty error"
  type        = bool
  default     = false
}

// ----------------------------------------------------------------------------
// Optional Variables	// Optional Variables
// ----------------------------------------------------------------------------
variable "enable_key_rotation" {
  description = "Flag to enable kms key rotation"
  type        = bool
  default     = true
}

variable "external_vault" {
  description = "Whether or not Jenkins X creates and manages the Vault instance. If set to true a external Vault URL needs to be provided"
  type        = bool
  default     = false
}

// ----------------------------------------------------------------------------
// DynamoDB Variables
// ----------------------------------------------------------------------------

variable "billing_rcu" {
  description = "The Read Capacity Units of DynamoDB when using PROVISIONED"
  type        = number
  default     = 2
}

variable "billing_wcu" {
  description = "The Write Capacity Units of DynamoDB when using PROVISIONED"
  type        = number
  default     = 2
}

variable "enable_provisioned_dynamodb" {
  description = "Flag to enable provisioned billing for DynamoDB"
  type        = bool
  default     = false
}

variable "use_kms_s3" {
  description = "Flag to determine whether kms should be used for encrypting s3 buckets"
  type        = bool
  default     = false
}

variable "s3_kms_arn" {
  description = "ARN of the kms key used for encrypting s3 buckets"
  type        = string
  default     = ""
}

variable "is_jx2" {
  default = true
  type    = bool
}

variable "use_vault" {
  description = "Flag to control vault resource creation"
  type        = bool
  default     = true
}
