variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type = string
}

variable "account_id" {
  type = string
}

variable "vault_user" {
  type    = string
  default = ""
}

variable "create_vault_resources" {
  type        = bool
  default     = true
}
