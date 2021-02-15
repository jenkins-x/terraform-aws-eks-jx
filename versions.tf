terraform {
  required_version = ">= 0.12.17, < 0.15"

  required_providers {
    aws        = ">= 2.53.0, < 4.0"
    kubernetes = "~> 2.0"
    local      = "~> 2.0"
    null       = "~> 3.0"
    template   = "~> 2.0"
    random     = "~> 3.0"
    helm       = "~> 2.0"
  }
}
