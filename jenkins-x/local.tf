provider "random" {
  version = "~> 2.1"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  generated_seed                = random_string.suffix.result
  # check if this makes sense
  jenkins-x-namespace           = "jx"
  cert-manager-namespace        = "cert-manager"
}
