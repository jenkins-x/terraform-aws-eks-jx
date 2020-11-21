// ----------------------------------------------------------------------------
// Required Variables
// ----------------------------------------------------------------------------
variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

// ----------------------------------------------------------------------------
// Optional Variables
// ----------------------------------------------------------------------------
variable "enable_backup" {
  description = "Whether or not Velero backups should be enabled"
  type        = bool
  default     = false
}

variable "velero_namespace" {
  description = "Kubernetes namespace for Velero"
  type        = string
  default     = "velero"
}

variable "force_destroy" {
  description = "Flag to determine whether storage buckets get forcefully destroyed"
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

variable "velero_username" {
  description = "The username to be assigned to the Velero IAM user"
  type        = string
  default     = "velero"
}

variable "create_velero_role" {
  description = "Flag to control velero iam role creation"
  type        = bool
  default     = true
}
