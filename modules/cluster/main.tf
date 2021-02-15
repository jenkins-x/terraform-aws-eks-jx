// ----------------------------------------------------------------------------
// Query necessary data for the module
// ----------------------------------------------------------------------------
data "aws_eks_cluster" "cluster" {
  name = var.create_eks ? module.eks.cluster_id : var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.create_eks ? module.eks.cluster_id : var.cluster_name
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

// ----------------------------------------------------------------------------
// Define K8s cluster configuration
// ----------------------------------------------------------------------------
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

// ----------------------------------------------------------------------------
// Create the AWS VPC
// See https://github.com/terraform-aws-modules/terraform-aws-vpc
// ----------------------------------------------------------------------------
module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "~> 2.70"
  create_vpc           = var.create_vpc
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

// ----------------------------------------------------------------------------
// Create the EKS cluster with extra EC2ContainerRegistryPowerUser policy
// See https://github.com/terraform-aws-modules/terraform-aws-eks
// ----------------------------------------------------------------------------
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 14.0"
  create_eks      = var.create_eks
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
      root_encrypted          = var.encrypt_volume_self
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
  cluster_encryption_config       = var.cluster_encryption_config
}

// ----------------------------------------------------------------------------
// Update the kube configuration after the cluster has been created so we can
// connect to it and create the K8s resources
// ----------------------------------------------------------------------------
resource "null_resource" "kubeconfig" {
  depends_on = [
    module.eks
  ]
  provisioner "local-exec" {
    command     = "aws eks update-kubeconfig --name ${var.cluster_name} --region=${var.region}"
    interpreter = ["/bin/bash", "-c"]
  }
}

// ----------------------------------------------------------------------------
// Create the necessary K8s namespaces that we will need to add the
// Service Accounts later
// ----------------------------------------------------------------------------
resource "kubernetes_namespace" "jx" {
  count = var.is_jx2 ? 1 : 0
  depends_on = [
    null_resource.kubeconfig
  ]
  metadata {
    name = "jx"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }
}

resource "kubernetes_namespace" "cert_manager" {
  count = var.is_jx2 ? 1 : 0
  depends_on = [
    null_resource.kubeconfig
  ]
  metadata {
    name = "cert-manager"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }
}

// ----------------------------------------------------------------------------
// Add the Terraform generated jx-requirements.yml to a configmap so it can be
// sync'd with the Git repository
//
// https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
// ----------------------------------------------------------------------------
resource "kubernetes_config_map" "jenkins_x_requirements" {
  count = var.is_jx2 ? 0 : 1
  metadata {
    name      = "terraform-jx-requirements"
    namespace = "default"
  }
  data = {
    "jx-requirements.yml" = var.content
  }

  lifecycle {
    ignore_changes = [
      metadata,
      data
    ]
  }
  depends_on = [
    module.eks
  ]
}
