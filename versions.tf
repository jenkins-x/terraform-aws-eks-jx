terraform {
  required_version = ">= 0.12.17, < 0.15"

  required_providers {
    aws        = ">= 2.53.0, < 4.0"
    kubernetes = "1.13.3"
    local      = "~> 1.2"
    null       = "~> 2.1"
    template   = "~> 2.1"
    random     = "~> 2.1"
    helm       = "~> 1.3.2"
  }
}
