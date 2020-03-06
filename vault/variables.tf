variable "region" {
  type = string
  default = "us-east-1"
}

variable "cluster_name" {
  type = string
}

variable "account_id" {
  type = string
}

variable "vault_user" {
  type = string
}

variable "create_vault_resources" {
  description = "Flag to enable or disable the creation of Vault resources by Terraform"
  type        = bool
  default     = false
}
