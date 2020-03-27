variable "cluster_name" {
  type = string
}

# Worker Nodes
variable "desired_number_of_nodes" {
  type        = number
  default     = 3
}

variable "min_number_of_nodes" {
  type        = number
  default     = 3
}

variable "max_number_of_nodes" {
  type        = number
  default     = 5
}

variable "worker_nodes_instance_types" {
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
