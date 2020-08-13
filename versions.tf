terraform {
  required_version = ">= 0.12.17, < 0.14"

  required_providers {
    aws      = ">= 2.53.0, < 4.0"
    local    = "~> 1.2"
    null     = "~> 2.1"
    template = "~> 2.1"
    random   = "~> 2.1"
  }
}
