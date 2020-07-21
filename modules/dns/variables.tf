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
