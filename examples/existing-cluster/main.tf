data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

// This will create a vpc using the official vpc module
module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "2.46.0"
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
  depends_on      = [module.vpc]
  source          = "terraform-aws-modules/eks/aws"
  version         = "12.1.0"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnets         = (var.cluster_in_private_subnet ? module.vpc.private_subnets : module.vpc.public_subnets)
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = true

  worker_groups_launch_template = var.enable_worker_group && var.enable_worker_groups_launch_template ? [
    for subnet in module.vpc.public_subnets :
    {
      subnets                 = [subnet]
      asg_desired_capacity    = var.lt_desired_nodes_per_subnet
      asg_min_size            = var.lt_min_nodes_per_subnet
      asg_max_size            = var.lt_max_nodes_per_subnet
      spot_price              = (var.enable_spot_instances ? var.spot_price : null)
      instance_type           = var.node_machine_type
      override_instance_types = var.allowed_spot_instance_types
      autoscaling_enabled     = "true"
      public_ip               = true
      tags = [
        {
          key                 = "k8s.io/cluster-autoscaler/enabled"
          propagate_at_launch = "false"
          value               = "true"
        },
        {
          key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          propagate_at_launch = "false"
          value               = "true"
        }
      ]
    }
  ] : []

  worker_groups = var.enable_worker_group && !var.enable_worker_groups_launch_template ? [
    {
      name                 = "worker-group-${var.cluster_name}"
      instance_type        = var.node_machine_type
      asg_desired_capacity = var.desired_node_count
      asg_min_size         = var.min_node_count
      asg_max_size         = var.max_node_count
      spot_price           = (var.enable_spot_instances ? var.spot_price : null)
      key_name             = (var.enable_key_name ? var.key_name : null)
      root_volume_type     = var.volume_type
      root_volume_size     = var.volume_size
      root_iops            = var.iops
      tags = [
        {
          key                 = "k8s.io/cluster-autoscaler/enabled"
          propagate_at_launch = "false"
          value               = "true"
        },
        {
          key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          propagate_at_launch = "false"
          value               = "true"
        }
      ]
    }
  ] : []

  node_groups = !var.enable_worker_group ? {
    eks-jx-node-group = {
      ami_type         = var.node_group_ami
      disk_size        = var.node_group_disk_size
      desired_capacity = var.desired_node_count
      max_capacity     = var.max_node_count
      min_capacity     = var.min_node_count

      instance_type = var.node_machine_type
      k8s_labels = {
        "jenkins-x.io/name"       = var.cluster_name
        "jenkins-x.io/part-of"    = "jx-platform"
        "jenkins-x.io/managed-by" = "terraform"
      }
      additional_tags = {
        aws_managed = "true"
      }
    }
  } : {}

  workers_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  ]

  map_users                       = var.map_users
  map_roles                       = var.map_roles
  map_accounts                    = var.map_accounts
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
}

// The VPC and EKS resources have been created, just install the cloud resources required by jx
module "eks-jx" {
  source       = "../../"
  region       = var.region
  use_vault    = var.use_vault
  use_asm      = var.use_asm
  cluster_name = module.eks.cluster_id // Cluster ID/Name of the EKS cluster where we want to install the jx cloud resources in
  is_jx2       = false
  create_eks   = false // Skip EKS creation
  create_vpc   = false // skip VPC creation
}
