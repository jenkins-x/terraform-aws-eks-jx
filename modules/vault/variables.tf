// ----------------------------------------------------------------------------
// Optional Variables	// Optional Variables
// ----------------------------------------------------------------------------

variable "external_vault" {
  description = "Whether or not Jenkins X creates and manages the Vault instance. If set to true a external Vault URL needs to be provided"
  type        = bool
  default     = false
}

variable "use_vault" {
  description = "Flag to control vault resource creation"
  type        = bool
  default     = true
}
