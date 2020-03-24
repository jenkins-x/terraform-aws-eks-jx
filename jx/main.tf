// ----------------------------------------------------------------------------
// Query necessary data for the module
// ----------------------------------------------------------------------------
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
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
  load_config_file       = false
  version                = "1.11.1"
}

// ----------------------------------------------------------------------------
// Create the AWS VPC
// See https://github.com/terraform-aws-modules/terraform-aws-vpc
// ----------------------------------------------------------------------------
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

// ----------------------------------------------------------------------------
// Create the EKS cluster with extra EC2ContainerRegistryPowerUser policy
// See https://github.com/terraform-aws-modules/terraform-aws-eks
// ----------------------------------------------------------------------------
module "eks" {
  source        = "terraform-aws-modules/eks/aws"
  version       = "10.0.0"
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

// ----------------------------------------------------------------------------
// Update the kube configuration after the cluster has been created so we can
// connect to it and create the K8s resources
// ----------------------------------------------------------------------------
resource "null_resource" "kubeconfig" {
  depends_on = [
    module.eks
  ]
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.cluster_name}"
    interpreter = ["/bin/bash", "-c"]
  }
}

// ----------------------------------------------------------------------------
// Create the necessary K8s namespaces that we will need to add the
// Service Accounts later
// ----------------------------------------------------------------------------
resource "kubernetes_namespace" "jx" {
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

resource "kubernetes_namespace" "cert-manager" {
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
// Create the AWS S3 buckets for Long Term Storage based on flags
// See https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
// ----------------------------------------------------------------------------
resource "aws_s3_bucket" "logs-jenkins-x" {
  count = var.enable_logs_storage ? 1 : 0
  bucket_prefix = "logs-${var.cluster_name}-"
  acl    = "private"

  tags = {
    Owner = "Jenkins-x"
  }
}

resource "aws_s3_bucket" "reports-jenkins-x" {
  count = var.enable_reports_storage ? 1 : 0
  bucket_prefix = "reports-${var.cluster_name}-"
  acl    = "private"

  tags = {
    Owner = "Jenkins-x"
  }
}

resource "aws_s3_bucket" "repository-jenkins-x" {
  count = var.enable_repository_storage ? 1 : 0
  bucket_prefix = "repository-${var.cluster_name}-"
  acl    = "private"

  tags = {
    Owner = "Jenkins-x"
  }
}

// ----------------------------------------------------------------------------
// Configure Route 53 based on flags and given parameters. This will create a
// subdomain for the given apex domain zone and delegate DNS resolve to the parent
// zone
// ----------------------------------------------------------------------------
data "aws_route53_zone" "apex_domain_zone" {
  count = var.create_and_configure_subdomain ? 1 : 0
  name = "${var.apex_domain}."
}

resource "aws_route53_zone" "subdomain_zone" {
  count = var.create_and_configure_subdomain ? 1 : 0
  name = join(".", [var.subdomain, var.apex_domain])
}

resource "aws_route53_record" "subdomain_ns_delegation" {
  count = var.create_and_configure_subdomain ? 1 : 0
  zone_id = data.aws_route53_zone.apex_domain_zone[0].zone_id
  name    = join(".", [var.subdomain, var.apex_domain])
  type    = "NS"
  ttl     = 30
  records = [
    "${aws_route53_zone.subdomain_zone[0].name_servers.0}",
    "${aws_route53_zone.subdomain_zone[0].name_servers.1}",
    "${aws_route53_zone.subdomain_zone[0].name_servers.2}",
    "${aws_route53_zone.subdomain_zone[0].name_servers.3}",
  ]
}
