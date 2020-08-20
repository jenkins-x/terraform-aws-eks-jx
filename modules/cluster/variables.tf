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
  default     = 10
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

variable "enable_node_group" {
  description = "Flag to enable node group"
  type        = bool
  default     = false
}

variable "enable_worker_group" {
  description = "Flag to enable worker group"
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
