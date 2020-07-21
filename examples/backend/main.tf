terraform {
  # https://www.terraform.io/docs/backends/types/s3.html
  backend "s3" {
    region         = "<region>"
    bucket         = "<s3-bucket-name>"
    key            = "terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

module "eks-jx" {
  source = "jenkins-x/eks-jx/aws"
}
