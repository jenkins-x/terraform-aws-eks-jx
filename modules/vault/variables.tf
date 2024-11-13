variable "resource_count" {
  description = "Number of resources to create (0 or 1)"
  type        = number
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