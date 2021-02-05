variable "region" {
  description = "The region to create the resources into"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
}

# Worker Nodes
variable "desired_node_count" {
  type    = number
  default = 3
}

variable "min_node_count" {
  type    = number
  default = 3
}

variable "max_node_count" {
  type    = number
  default = 5
}

variable "node_machine_type" {
  type    = string
  default = "m5.large"
}

# VPC
variable "vpc_name" {
  type    = string
  default = "tf-vpc-eks"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "single_nat_gateway" {
  type    = bool
  default = false
}

variable "spot_price" {
  description = "The spot price ceiling for spot instances"
  type        = string
  default     = "0.1"
}

variable "node_group_ami" {
  description = "ami type for the node group worker intances"
  type        = string
  default     = "AL2_x86_64"
}

variable "node_group_disk_size" {
  description = "node group worker disk size"
  type        = string
  default     = "50"
}

variable "key_name" {
  description = "The ssh key pair name to use"
  type        = string
  default     = ""
}

variable "volume_type" {
  description = "The volume type to use. Can be standard, gp2 or io1"
  type        = string
  default     = "gp2"
}

variable "volume_size" {
  description = "The volume size in GB"
  type        = number
  default     = 50
}

variable "iops" {
  description = "The IOPS value"
  type        = number
  default     = 0
}
// ----------------------------------------------------------------------------
// Flag Variables
// ----------------------------------------------------------------------------
variable "enable_logs_storage" {
  type    = bool
  default = true
}

variable "enable_worker_group" {
  description = "Flag to enable worker group. Setting this to false will provision a node group instead"
  type        = bool
  default     = true
}

variable "enable_reports_storage" {
  type    = bool
  default = true
}

variable "enable_repository_storage" {
  type    = bool
  default = true
}

variable "force_destroy" {
  description = "Flag to determine whether storage buckets get forcefully destroyed. If set to false, empty the bucket first in the aws s3 console, else terraform destroy will fail with BucketNotEmpty error"
  type        = bool
  default     = false
}

variable "enable_spot_instances" {
  description = "Flag to enable spot instances"
  type        = bool
  default     = false
}

variable "cluster_in_private_subnet" {
  description = "Flag to enable installation of cluster on private subnets"
  type        = bool
  default     = false
}

variable "use_kms_s3" {
  description = "Flag to determine whether kms should be used for encrypting s3 buckets"
  type        = bool
  default     = false
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "enable_key_name" {
  description = "Flag to enable ssh key pair name"
  type        = bool
  default     = false
}

variable "s3_kms_arn" {
  description = "ARN of the kms key used for encrypting s3 buckets"
  type        = string
  default     = ""
}

variable "is_jx2" {
  default = true
  type    = bool
}

variable "content" {
  description = "Interpolated jx-requirements.yml"
  type        = string
  default     = ""
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false
}

variable "cluster_endpoint_private_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS private API server endpoint, when public access is disabled."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_spot_instance_types" {
  description = "Allowed machine types for spot instances (must be same size)"
  type        = any
  default     = []
}

variable "enable_worker_groups_launch_template" {
  description = "Flag to enable Worker Group Launch Templates"
  type        = bool
  default     = false
}

variable "lt_desired_nodes_per_subnet" {
  description = "The number of worker nodes in each Subnet (AZ) if using Launch Templates"
  type        = number
  default     = 1
}

variable "lt_min_nodes_per_subnet" {
  description = "The minimum number of worker nodes in each Subnet (AZ) if using Launch Templates"
  type        = number
  default     = 1
}

variable "lt_max_nodes_per_subnet" {
  description = "The maximum number of worker nodes in each Subnet (AZ) if using Launch Templates"
  type        = number
  default     = 2
}

variable "jx_git_url" {
  description = "URL for the Jenins X cluster git repository"
  type        = string
  default     = ""
}

variable "jx_bot_username" {
  description = "Bot username used to interact with the Jenkins X cluster git repository"
  type        = string
  default     = ""
}

variable "jx_bot_token" {
  description = "Bot token used to interact with the Jenkins X cluster git repository"
  type        = string
  default     = ""
}

variable "create_eks" {
  description = "Controls if EKS cluster and associated resources should be created or not. If you have an existing eks cluster, set it to false"
  type        = bool
  default     = true
}

variable "create_vpc" {
  description = "Controls if VPC and related resources should be created"
  type        = bool
  default     = true
}

variable "encrypt_volume_self" {
  description = "Encrypt the ebs and root volume for the self managed worker nodes. This is only valid for the worker group launch template"
  type        = bool
  default     = false
}

variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster."
  type = list(object({
    provider_key_arn = string
    resources        = list(string)
  }))
  default = []
}

variable "create_tekton_role" {
  description = "Flag to control tekton iam role creation"
  type        = bool
  default     = true
}

variable "create_exdns_role" {
  description = "Flag to control external dns iam role creation"
  type        = bool
  default     = true
}

variable "create_cm_role" {
  description = "Flag to control cert manager iam role creation"
  type        = bool
  default     = true
}

variable "create_cmcainjector_role" {
  description = "Flag to control cert manager ca-injector iam role creation"
  type        = bool
  default     = true
}

variable "create_ctrlb_role" {
  description = "Flag to control controller build iam role creation"
  type        = bool
  default     = true
}

variable "create_autoscaler_role" {
  description = "Flag to control cluster autoscaler iam role creation"
  type        = bool
  default     = true
}

variable "create_pipeline_vis_role" {
  description = "Flag to control pipeline visualizer role"
  type        = bool
  default     = true
}

variable "create_bucketrepo_role" {
  description = "Flag to control bucketrepo role"
  type        = bool
  default     = true
}

variable "additional_tekton_role_policy_arns" {
  description = "Additional Policy ARNs to attach to Tekton IRSA Role"
  type        = list(string)
  default     = []
}
