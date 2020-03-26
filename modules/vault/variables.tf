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

// ----------------------------------------------------------------------------
// Whether to create the Vault resources
// ----------------------------------------------------------------------------
variable "create_vault_resources" {
  type        = bool
  default     = false
}
