terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "1.10.0"
}

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "2.6.0"
  name                 = var.vpc_name
  cidr                 = var.vpc_cidr_block
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = var.vpc_subnets
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
}

module "eks" {
  source        = "terraform-aws-modules/eks/aws"
  version       = "8.2.0"
  cluster_name  = var.cluster_name
  subnets       = module.vpc.public_subnets
  vpc_id        = module.vpc.vpc_id
  enable_irsa   = true
  worker_groups = [
    {
      name                 = "worker-group-${var.cluster_name}"
      instance_type        = var.worker_nodes_instance_types
      asg_desired_capacity = var.desired_number_of_nodes
      asg_min_size         = var.min_number_of_nodes
      asg_max_size         = var.max_number_of_nodes
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    }
  ]
  workers_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  ]
}

module "jenkinsx" {
  source                         = "./jenkins-x"
  region                         = var.region
  cluster_name                   = var.cluster_name
  apex_domain                    = var.apex_domain
  subdomain                      = var.subdomain
  tls_email                      = var.tls_email
  enable_logs_storage            = var.enable_logs_storage
  enable_reports_storage         = var.enable_reports_storage
  enable_repository_storage      = var.enable_repository_storage
  enable_external_dns            = var.enable_external_dns
  create_and_configure_subdomain = var.create_and_configure_subdomain
  enable_tls                     = var.enable_tls
  production_letsencrypt         = var.production_letsencrypt
  oidc_provider_url              = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  cluster_id                     = module.eks.cluster_id
}

module "vault" {
  source                 = "./vault"
  create_vault_resources = var.create_vault_resources
  cluster_name           = var.cluster_name
  account_id             = var.account_id
  vault_user             = var.vault_user
}

# jx-requirements.yml file generation

resource "local_file" "jx-requirements" {
  depends_on = [
    module.jenkinsx,
    module.vault
  ]
  content = templatefile("${path.module}/jenkins-x/jx-requirements.yml.tpl", {
    cluster_name                = var.cluster_name
    region                      = var.region
    enable_logs_storage         = var.enable_logs_storage
    logs_storage_bucket         = module.jenkinsx.logs-jenkins-x
    enable_reports_storage      = var.enable_reports_storage
    reports_storage_bucket      = module.jenkinsx.reports-jenkins-x
    enable_repository_storage   = var.enable_repository_storage
    repository_storage_bucket   = module.jenkinsx.repository-jenkins-x
    create_vault_resources      = var.create_vault_resources
    vault_kms_key               = module.vault.kms_vault_unseal 
    vault_bucket                = module.vault.vault_unseal_bucket
    vault_dynamodb_table        = module.vault.vault_dynamodb_table
    vault_user                  = var.vault_user
    enable_external_dns         = var.enable_external_dns
    domain                      = trimprefix(join(".", [var.subdomain, var.apex_domain]), ".")
    enable_tls                  = var.enable_tls
    tls_email                   = var.tls_email
    use_production_letsencrypt  = var.production_letsencrypt
  })
  filename = "../${path.module}/jx-requirements.yml"
}
