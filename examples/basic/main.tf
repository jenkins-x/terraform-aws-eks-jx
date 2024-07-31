data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

// This will create a vpc using the official vpc module
module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "5.9.0"
  name                 = var.vpc_name
  cidr                 = var.vpc_cidr_block
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_dns_hostnames = true
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

// This will create the eks cluster using the official eks module
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "12.20.0"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnets         = (var.cluster_in_private_subnet ? module.vpc.private_subnets : module.vpc.public_subnets)
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = true

  eks_managed_node_groups = {
    eks-jx-node-group = {
      ami_type     = var.node_group_ami
      desired_size = var.desired_node_count
      max_size     = var.max_node_count
      min_size     = var.min_node_count

      instance_types = [var.node_machine_type]
      k8s_labels = {
        "jenkins-x.io/name"       = var.cluster_name
        "jenkins-x.io/part-of"    = "jx-platform"
        "jenkins-x.io/managed-by" = "terraform"
      }
      additional_tags = {
        aws_managed = "true"
      }
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
}


module "eks-auth" {
  depends_on = [module.eks]
  source     = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version    = "~> 20.0"

  manage_aws_auth_configmap = true

  aws_auth_users    = var.map_users
  aws_auth_roles    = var.map_roles
  aws_auth_accounts = var.map_accounts
}

// The VPC and EKS resources have been created, just install the cloud resources required by jx
module "eks-jx" {
  source    = "../../"
  region    = var.region
  use_vault = var.use_vault
  use_asm   = var.use_asm

  jx_git_url      = var.jx_git_url
  jx_bot_username = var.jx_bot_username
  jx_bot_token    = var.jx_bot_token

  enable_repository_storage = var.enable_repository_storage
  enable_reports_storage    = var.enable_reports_storage
  enable_logs_storage       = var.enable_logs_storage

  force_destroy = var.force_destroy

  cluster_name = module.eks.cluster_name // Cluster Name of the EKS cluster that we want to create jx cloud resources for
}
