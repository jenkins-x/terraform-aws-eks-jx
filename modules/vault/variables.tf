// ----------------------------------------------------------------------------
// Required Variables
// ----------------------------------------------------------------------------
variable "region" {
  type = string
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
