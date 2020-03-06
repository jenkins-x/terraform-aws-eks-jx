variable "region" {
  type = string
  default = "us-east-1"
}

variable "cluster_name" {
  type = string
}

variable "account_id" {
  type = string
}

variable "vault_user" {
  type    = string
  default = ""
}

variable "manage_aws_auth" {
  description = "Whether to apply the aws-auth configmap file."
  default     = true
}

variable "wait_for_cluster_cmd" {
  description = "Custom local-exec command to execute for determining if the eks cluster is healthy. Cluster endpoint will be available as an environment variable called ENDPOINT"
  type        = string
  default     = "until curl -k -s $ENDPOINT/healthz >/dev/null; do sleep 4; done"
}

# Worker Nodes
variable "desired_number_of_nodes" {
  description = "The number of worker nodes to use for the cluster. Defaults to 3"
  type        = number
  default     = 3
}

variable "min_number_of_nodes" {
  description = "The minimum number of worker nodes to use for the cluster. Defaults to 3"
  type        = number
  default     = 3
}

variable "max_number_of_nodes" {
  description = "The maximum number of worker nodes to use for the cluster. Defaults to 5"
  type        = number
  default     = 5
}

variable "worker_nodes_instance_types" {
  description  = "The instance type to use for the cluster's worker nodes. Defaults to m5.large"
  type         = string
  default      = "m5.large"
}

# VPC
variable "vpc_name" {
  description  = "The name of the VPC to be created for the cluster"
  type         = string
  default      = "tf-vpc-eks"
}

variable "vpc_subnets" {
  description = "The subnet CIDR block to use in the created VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "vpc_cidr_block" {
  description = "The vpc CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

# External DNS
variable "apex_domain" {
  description = "Flag to enable or disable long term storage for logs"
  type        = string
  default     = ""
}

variable "subdomain" {
  description = "The subdomain to be used added to the apex domain. If subdomain is set, it will be appended to the apex domain in  `jx-requirements-eks.yml` file"
  type        = string
  default     = ""
}

variable "tls_email" {
  description = "The email to register the LetsEncrypt certificate with. Added to the `jx-requirements.yml` file"
  type        = string
  default     = ""
}

# Flags

variable "enable_logs_storage" {
  description = "Flag to enable or disable long term storage for logs"
  type        = bool
  default     = true
}

variable "enable_reports_storage" {
  description = "Flag to enable or disable long term storage for reports"
  type        = bool
  default     = true
}

variable "enable_repository_storage" {
  description = "Flag to enable or disable the repository bucket storage"
  type        = bool
  default     = true
}

variable "create_vault_resources" {
  description = "Flag to enable or disable the creation of Vault resources by Terraform"
  type        = bool
  default     = false
}

variable "enable_external_dns" {
  description = "Flag to enable or disable External DNS in the final `jx-requirements.yml` file"
  type        = bool
  default     = false
}

variable "create_and_configure_subdomain" {
  description = "Flag to create an NS record ser for the subdomain in the apex domain's Hosted Zone"
  type        = bool
  default     = false
}

variable "enable_tls" {
  description = "Flag to enable TLS int he final `jx-requirements.yml` file"
  type        = bool
  default     = false
}

variable "production_letsencrypt" {
  description = "Flag to use the production environment of letsencrypt in the `jx-requirements.yml` file"
  type        = bool
  default     = false
}
