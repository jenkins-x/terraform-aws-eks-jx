variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
}

# Worker Nodes
variable "desired_node_count" {
  type        = number
  default     = 3
}

variable "min_node_count" {
  type        = number
  default     = 3
}

variable "max_node_count" {
  type        = number
  default     = 5
}

variable "node_machine_type" {
  type         = string
  default      = "m5.large"
}

# VPC
variable "vpc_name" {
  type         = string
  default      = "tf-vpc-eks"
}

variable "vpc_subnets" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
}

variable "spot_price" {
  description = "The spot price ceiling for spot instances"
  type        = string
  default     = "0.1"
}

variable "key_name" {
  description = "The ssh key pair name to use"
  type        = string
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
  type        = bool
  default     = true
}

variable "enable_reports_storage" {
  type        = bool
  default     = true
}

variable "enable_repository_storage" {
  type        = bool
  default     = true
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

variable "enable_key_name" {
  description = "Flag to enable ssh key pair name"
  type        = bool
  default     = false
}
