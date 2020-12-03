// ----------------------------------------------------------------------------
// External DNS Variables
// ----------------------------------------------------------------------------
variable "apex_domain" {
  type    = string
  default = ""
}

variable "subdomain" {
  type    = string
  default = ""
}

variable "tls_email" {
  type    = string
  default = ""
}

// ----------------------------------------------------------------------------
// Flag Variables
// ----------------------------------------------------------------------------
variable "enable_external_dns" {
  type    = bool
  default = false
}

variable "create_and_configure_subdomain" {
  type    = bool
  default = false
}

variable "enable_tls" {
  type    = bool
  default = false
}

variable "production_letsencrypt" {
  type    = bool
  default = false
}

variable "is_jx2" {
  default = true
  type    = bool
}

variable "manage_apex_domain" {
  description = "Flag to control if apex domain should be managed/updated by this module. Set this to false,if your apex domain is managed in a different AWS account or different provider"
  default     = true
  type        = bool
}

variable "manage_subdomain" {
  description = "Flag to control subdomain creation/management"
  default     = true
  type        = bool
}
