// ----------------------------------------------------------------------------
// Required Variables
// ----------------------------------------------------------------------------
variable "region" {
  description = "The region to create the resources into"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Variable to provide your desired name for the cluster. The script will create a random name if this is empty"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
  default     = "1.17"
}

// ----------------------------------------------------------------------------
// Vault
// ----------------------------------------------------------------------------
variable "vault_user" {
  description = "The AWS IAM Username whose credentials will be used to authenticate the Vault pods against AWS"
  type        = string
  default     = ""
}

variable "vault_url" {
  description = "URL to an external Vault instance in case Jenkins X does not create its own system Vault"
  type        = string
  default     = ""
}

// ----------------------------------------------------------------------------
// Velero/backup
// ----------------------------------------------------------------------------
variable "enable_backup" {
  description = "Whether or not Velero backups should be enabled"
  type        = bool
  default     = false
}

variable "velero_namespace" {
  description = "Kubernetes namespace for Velero"
  type        = string
  default     = "velero"
}

variable "velero_schedule" {
  description = "The Velero backup schedule in cron notation to be set in the Velero Schedule CRD (see [default-backup.yaml](https://github.com/jenkins-x/jenkins-x-boot-config/blob/master/systems/velero-backups/templates/default-backup.yaml))"
  type        = string
  default     = "0 * * * *"
}

variable "velero_ttl" {
  description = "The the lifetime of a velero backup to be set in the Velero Schedule CRD (see [default-backup.yaml](https://github.com/jenkins-x/jenkins-x-boot-config/blob/master/systems/velero-backups/templates/default-backup))"
  type        = string
  default     = "720h0m0s"
}

variable "velero_username" {
  description = "The username to be assigned to the Velero IAM user"
  type        = string
  default     = "velero"
}

// ----------------------------------------------------------------------------
// Worker Nodes Variables
// ----------------------------------------------------------------------------
variable "desired_node_count" {
  description = "The number of worker nodes to use for the cluster"
  type        = number
  default     = 3
}

variable "min_node_count" {
  description = "The minimum number of worker nodes to use for the cluster"
  type        = number
  default     = 3
}

variable "max_node_count" {
  description = "The maximum number of worker nodes to use for the cluster"
  type        = number
  default     = 5
}

variable "node_machine_type" {
  description = "The instance type to use for the cluster's worker nodes"
  type        = string
  default     = "m5.large"
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
  description = "The ssh key pair name"
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
// VPC Variables
// ----------------------------------------------------------------------------
variable "vpc_name" {
  description = "The name of the VPC to be created for the cluster"
  type        = string
  default     = "tf-vpc-eks"
}

variable "public_subnets" {
  description = "The public subnet CIDR block to use in the created VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "The private subnet CIDR block to use in the created VPC"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "vpc_cidr_block" {
  description = "The vpc CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

// ----------------------------------------------------------------------------
// External DNS Variables
// ----------------------------------------------------------------------------
variable "apex_domain" {
  description = "The main domain to either use directly or to configure a subdomain from"
  type        = string
  default     = ""
}

variable "subdomain" {
  description = "The subdomain to be added to the apex domain. If subdomain is set, it will be appended to the apex domain in  `jx-requirements-eks.yml` file"
  type        = string
  default     = ""
}

variable "tls_email" {
  description = "The email to register the LetsEncrypt certificate with. Added to the `jx-requirements.yml` file"
  type        = string
  default     = ""
}

// ----------------------------------------------------------------------------
// Flag Variables
// ----------------------------------------------------------------------------
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

variable "enable_external_dns" {
  description = "Flag to enable or disable External DNS in the final `jx-requirements.yml` file"
  type        = bool
  default     = false
}

variable "create_and_configure_subdomain" {
  description = "Flag to create an NS record set for the subdomain in the apex domain's Hosted Zone"
  type        = bool
  default     = false
}

variable "enable_tls" {
  description = "Flag to enable TLS in the final `jx-requirements.yml` file"
  type        = bool
  default     = false
}

variable "production_letsencrypt" {
  description = "Flag to use the production environment of letsencrypt in the `jx-requirements.yml` file"
  type        = bool
  default     = false
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

variable "enable_worker_group" {
  description = "Flag to enable worker group. Setting this to false will provision a node group instead"
  type        = bool
  default     = true
}

variable "enable_key_rotation" {
  description = "Flag to enable kms key rotation"
  type        = bool
  default     = true
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

// ----------------------------------------------------------------------------
// Cluster AWS Auth Variables
// ----------------------------------------------------------------------------
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
  default     = true
  type        = bool
  description = "Flag to specify if jx2 related resources need to be created"
}

variable "ignoreLoadBalancer" {
  default     = false
  type        = bool
  description = "Flag to specify if jx boot will ignore loadbalancer DNS to resolve to an IP"
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

variable "registry" {
  description = "Registry used to store images"
  type        = string
  default     = ""
}

variable "jx_git_url" {
  description = "URL for the Jenkins X cluster git repository"
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
  description = "Controls if EKS cluster and associated resources should be created or not. If you have an existing eks cluster for jx, set it to false"
  type        = bool
  default     = true
}

variable "create_vpc" {
  description = "Controls if VPC and related resources should be created. If you have an existing vpc for jx, set it to false"
  type        = bool
  default     = true
}

variable "use_vault" {
  description = "Flag to control vault resource creation"
  type        = bool
  default     = true
}

variable "use_asm" {
  description = "Flag to specify if AWS Secrets manager is being used"
  type        = bool
  default     = false
}

variable "install_kuberhealthy" {
  description = "Flag to specify if kuberhealthy operator should be installed"
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

variable "create_velero_role" {
  description = "Flag to control velero iam role creation"
  type        = bool
  default     = true
}

variable "manage_apex_domain" {
  description = "Flag to control if apex domain should be managed/updated by this module. Set this to false,if your apex domain is managed in a different AWS account or different provider"
  default     = true
  type        = bool
}

variable "manage_subdomain" {
  description = "Flag to control subdomain creation/management"
  default     = true
  type        = bool
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
