provider "random" {
  version = "~> 2.1"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  vault_seed = random_string.suffix.result
}
