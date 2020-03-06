A terraform module to create an EKS cluster and all the necessary infrastructure that serves as an alternative to `jx create cluster eks`.

This module is based on the Terraform EKS cluster that can be found here: https://github.com/terraform-aws-modules/terraform-aws-eks.

This module will also create the necessary resources that Jenkins X will need in order to be installed in this cluster using `jx boot` using the generated `jx-requirements.yml` which should be preconfigured with all the resources that were created by this module.

## Assumptions
You want to create an EKS cluster that will be used to install Jenkins X into.

It's required that both kubectl (>=1.10) and aws-iam-authenticator are installed and on your shell's PATH.

## Usage example
This module works with a series of variables with default values, this will let you easily run it with a default configuration for easy prototyping by just providing the following required variables:

    terraform init
    terraaform apply -var 'cluster_name=<cluster_name>' -var 'region=<your_aws_region>' -var 'account_id=<your_aws_account_id>' 

Full customization of the EKS and Kubernetes modules through the use of this module is still not supported as this is still work in progress.

There are a number of variables that will let you configure some resources for your EKS cluster.

### VPC configuration

With these variables you can define a few variables for the VPC that will be created:

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

### EKS Worker Nodes configration

With these variables you can configure the worker nodes pool for the EKS cluster:

    variable "desired_number_of_nodes" {
      description = "The desired number of worker nodes to use for the cluster. Defaults to 3"
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

### Long Term Storage

You can choose whether to create S3 buckets for long term storage and enable them in the generated `jx-requirements.yml` file.

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

If these variables are `true`, after creating the necessary S3 buckets, it will configure the `jx-requirements.yml` file in the following section:

    storage:
      logs:
        enabled: ${enable_logs_storage}
        url: s3://${logs_storage_bucket}
      reports:
        enabled: ${enable_reports_storage}
        url: s3://${reports_storage_bucket}
      repository:
        enabled: ${enable_repository_storage}
        url: s3://${repository_storage_bucket}

### Vault configuration

With this module, we can choose to create the Vault resources that will be used by Jenkins X.

You can enable the creation of the Vault resources with the following variable:

    variable "create_vault_resources" {
      description = "Flag to enable or disable the creation of Vault resources by Terraform"
      type        = bool
      default     = false
    }

If `create_vault_resources` is `true`, the `vault_user` variable will be required:

    variable "vault_user" {
      type    = string
      default = ""
    }

### External DNS and Cert Manager

#### External DNS

You can enable External DNS with the following variable:

    variable "enable_external_dns" {
      description = "Flag to enable or disable External DNS in the final `jx-requirements.yml` file"
      type        = bool
      default     = false
    }

If `enable_external_dns` is true, additional configuration will be required:

If you want to use a domain with an already existing Route 53 Hosted Zone, you can provide it through the following variable:

    variable "apex_domain" {
      description = "Flag to enable or disable long term storage for logs"
      type        = string
      default     = ""
    }

This domain will be configured in the resulting `jx-requirements.yml` file in the following section:

    ingress:
      domain: ${domain}
      ignoreLoadBalancer: true
      externalDNS: ${enable_external_dns}

If you want use a subdomain and have this script create and configure a new Hosted Zone with DNS delegation, you can provide the following variables:

    variable "subdomain" {
      description = "The subdomain to be used added to the apex domain. If subdomain is set, it will be appended to the apex domain in  `jx-requirements-eks.yml` file"
      type        = string
      default     = ""
    }
    
    variable "create_and_configure_subdomain" {
      description = "Flag to create an NS record ser for the subdomain in the apex domain's Hosted Zone"
      type        = bool
      default     = false
    }

By providing these variables, the script will create a new `Route 53` HostedZone that looks like `<subdomain>.<apex_domain>` and it will delegate the resolving of DNS to the apex domain.
This is done by creating a `NS` RecordSet in the apex domain's Hosted Zone with the subdomain's HostedZone nameservers.

This will make sure that the newly created HostedZone for the subdomain is instantly resolveable instead of having to wait for DNS propagation.

#### Cert Manager

You can enable Cert Manager in order to use TLS for your cluster through LetsEncrypt with the following variables:

    variable "enable_tls" {
      description = "Flag to enable TLS int he final `jx-requirements.yml` file"
      type        = bool
      default     = false
    }

LetsEncrypt has two environments, `staging` and `production`, the difference is that if you use staging, you will be provided self signed certificates but will not be rate limited while if you use the `production` environment, you will be provided certificates signed by LetsEncrypt but you can be rate limited.

You can choose to use the `production` environment with the following variable: 

    variable "production_letsencrypt" {
      description = "Flag to use the production environment of letsencrypt in the `jx-requirements.yml` file"
      type        = bool
      default     = false
    }

You will also need to provide a valid email to register your domain in LetsEncrypt:

    variable "tls_email" {
      description = "The email to register the LetsEncrypt certificate with. Added to the `jx-requirements.yml` file"
      type        = string
      default     = ""
    }


## Generation of jx-requirements.yml

The final output of running this module will not only be the creation of cloud resources but also, it will generate a valid `jx-requirements.yml` file that will be used by Jenkins X through `jx boot -r jx-requirements.yml`.
The template can be found in: 

https://github.com/jenkins-x/jx-cloud-provisioners/blob/master/eks/terraform/jenkins-x/jx-requirements.yml.tpl

## Conditional creation
Sometimes you need to have a way to create resources conditionally but Terraform does not allow to use count inside module block, there still isn't a solution for this in this repository but we will be working to allow users to provide their own VPC, subnets etc.

## FAQ: Frequently Asked Questions

### IAM Roles for Service Accounts
This module will setup a series of IAM Policies and Roles. These roles will be annotated into a few Kubernetes Service accounts.

This allows us to make use of IAM Roles for Sercive Accounts in order to set fine grained permissions on a pod per pod basis.

There still isn't a way to provide your own roles or define other Service Accounts by variables but you can always modify the `eks/terraform/jenkins-x/irsa.tf` Terraform file.

## Generated Documentation

This documentation is being generated with `terraform-docs`:

### Providers

| Name | Version |
|------|---------|
| aws | >= 2.28.1 |
| local | ~> 1.2 |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| account\_id | n/a | `string` | n/a | yes |
| apex\_domain | Flag to enable or disable long term storage for logs | `string` | `""` | no |
| cluster\_name | n/a | `string` | n/a | yes |
| create\_and\_configure\_subdomain | Flag to create an NS record ser for the subdomain in the apex domain's Hosted Zone | `bool` | `false` | no |
| create\_vault\_resources | Flag to enable or disable the creation of Vault resources by Terraform | `bool` | `false` | no |
| desired\_number\_of\_nodes | The number of worker nodes to use for the cluster. Defaults to 3 | `number` | `3` | no |
| enable\_external\_dns | Flag to enable or disable External DNS in the final `jx-requirements.yml` file | `bool` | `false` | no |
| enable\_logs\_storage | Flag to enable or disable long term storage for logs | `bool` | `true` | no |
| enable\_reports\_storage | Flag to enable or disable long term storage for reports | `bool` | `true` | no |
| enable\_repository\_storage | Flag to enable or disable the repository bucket storage | `bool` | `true` | no |
| enable\_tls | Flag to enable TLS int he final `jx-requirements.yml` file | `bool` | `false` | no |
| manage\_aws\_auth | Whether to apply the aws-auth configmap file. | `bool` | `true` | no |
| max\_number\_of\_nodes | The maximum number of worker nodes to use for the cluster. Defaults to 5 | `number` | `5` | no |
| min\_number\_of\_nodes | The minimum number of worker nodes to use for the cluster. Defaults to 3 | `number` | `3` | no |
| production\_letsencrypt | Flag to use the production environment of letsencrypt in the `jx-requirements.yml` file | `bool` | `false` | no |
| region | n/a | `string` | `"us-east-1"` | no |
| subdomain | The subdomain to be used added to the apex domain. If subdomain is set, it will be appended to the apex domain in  `jx-requirements-eks.yml` file | `string` | `""` | no |
| tls\_email | The email to register the LetsEncrypt certificate with. Added to the `jx-requirements.yml` file | `string` | `""` | no |
| vault\_user | n/a | `string` | `""` | no |
| vpc\_cidr\_block | The vpc CIDR block | `string` | `"10.0.0.0/16"` | no |
| vpc\_name | The name of the VPC to be created for the cluster | `string` | `"tf-vpc-eks"` | no |
| vpc\_subnets | The subnet CIDR block to use in the created VPC | `list(string)` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24",<br>  "10.0.3.0/24"<br>]</pre> | no |
| wait\_for\_cluster\_cmd | Custom local-exec command to execute for determining if the eks cluster is healthy. Cluster endpoint will be available as an environment variable called ENDPOINT | `string` | `"until curl -k -s $ENDPOINT/healthz \u003e/dev/null; do sleep 4; done"` | no |
| worker\_nodes\_instance\_types | The instance type to use for the cluster's worker nodes. Defaults to m5.large | `string` | `"m5.large"` | no |

### Outputs

| Name | Description |
|------|-------------|
| aws\_account\_id | n/a |
| cluster\_name | n/a |
