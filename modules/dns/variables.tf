// ----------------------------------------------------------------------------
// External DNS Variables
// ----------------------------------------------------------------------------
variable "apex_domain" {
  description = "Flag to enable or disable long term storage for logs"
  type        = string
  default     = ""
}

variable "subdomain" {
  description = "The subdomain to be used added to the apex domain. If subdomain is set, it will be appended to the apex domain in  `jx-requirements-eks.yml` file"
  type        = string
  default     = ""
}

variable "tls_email" {
  description = "The email to register the LetsEncrypt certificate with. Added to the `jx-requirements.yml` file"
  type        = string
  default     = ""
}

// ----------------------------------------------------------------------------
// Flag Variables
// ----------------------------------------------------------------------------
variable "enable_external_dns" {
  description = "Flag to enable or disable External DNS in the final `jx-requirements.yml` file"
  type        = bool
  default     = false
}

variable "create_and_configure_subdomain" {
  description = "Flag to create an NS record ser for the subdomain in the apex domain's Hosted Zone"
  type        = bool
  default     = false
}

variable "enable_tls" {
  description = "Flag to enable TLS int he final `jx-requirements.yml` file"
  type        = bool
  default     = false
}

variable "production_letsencrypt" {
  description = "Flag to use the production environment of letsencrypt in the `jx-requirements.yml` file"
  type        = bool
  default     = false
}
