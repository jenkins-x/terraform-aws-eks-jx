variable "is_jx2" {
  default = true
  type    = bool
}

variable "create_nginx" {
  default     = false
  type        = bool
  description = "Decides whether we want to create nginx resources using terraform or not"
}

variable "nginx_release_name" {
  default     = "nginx-ingress"
  type        = string
  description = "Name of the nginx release name"
}

variable "nginx_namespace" {
  default     = "nginx"
  type        = string
  description = "Name of the nginx namespace"
}

variable "nginx_chart_version" {
  type        = string
  description = "nginx chart version"
}

variable "create_nginx_namespace" {
  default     = true
  type        = bool
  description = "Boolean to control nginx namespace creation"
}

variable "nginx_values_file" {
  default     = "nginx_values.yaml"
  type        = string
  description = "Name of the values file which holds the helm chart values"
}
