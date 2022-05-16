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

variable "create_and_configure_private_subdomain" {
  description = "Flag to determine if a private subdomain is created and configured."
  type        = bool
  default     = false
}

variable "force_destroy_subdomain" {
  description = "Flag to determine whether subdomain zone get forcefully destroyed. If set to false, empty the sub domain first in the aws Route 53 console, else terraform destroy will fail with HostedZoneNotEmpty error"
  type        = bool
  default     = false
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

// ----------------------------------------------------------------------------
// Variables if setting private Route53 configuration
// ----------------------------------------------------------------------------
variable "vpc_id" {
  description = "The VPC to create EKS cluster in if create_vpc is false"
  type        = string
  default     = ""
}

variable "region" {
  description = "The region to create the resources into"
  type        = string
  default     = "us-east-1"
}

variable "private_dns_associated_vpc_ids" {
  description = "A map of other vpc ids and there region to associate with the private zone"
  type        = map(string)
  default     = {}
}

