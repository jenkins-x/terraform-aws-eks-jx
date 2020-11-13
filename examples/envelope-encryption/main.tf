# Example taken from https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/secrets_encryption
// Ideally you should be using a module to create kms keys across your AWS accounts, this is just for this example
provider "aws" {
  region = "us-east-2"
}

resource "aws_kms_key" "eks" {
  description = "EKS Secret Encryption Key"
}

module "eks-jx" {
  source               = "../../"
  vault_user           = var.vault_user
  is_jx2               = false
  install_kuberhealthy = false
  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn // ARN of the KMS key
      resources        = ["secrets"]         // Encrypt secrets K8s resource
    }
  ]
  region = "us-east-2"
}


