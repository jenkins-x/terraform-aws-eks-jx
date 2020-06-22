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
