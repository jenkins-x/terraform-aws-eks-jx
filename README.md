# Jenkins X EKS Module

This repository contains a Terraform module for creating an EKS cluster and all the necessary infrastructure to install Jenkins X via `jx boot`.
The module generates for this purpose a  templated `jx-requirements.yml` which can be passed to `jx boot`.

The module makes use of the [Terraform EKS cluster Module](https://github.com/terraform-aws-modules/terraform-aws-eks).

<!-- TOC depthfrom:2 -->

- [Jenkins X EKS Module](#jenkins-x-eks-module)
  - [What is a Terraform Module](#what-is-a-terraform-module)
  - [How do you use this Module](#how-do-you-use-this-module)
    - [Assumptions](#assumptions)
    - [Usage](#usage)
      - [Examples](#examples)
      - [VPC configuration](#vpc-configuration)
      - [EKS Worker Nodes configuration](#eks-worker-nodes-configuration)
      - [Long Term Storage](#long-term-storage)
      - [Vault configuration](#vault-configuration)
      - [External DNS and Cert Manager](#external-dns-and-cert-manager)
        - [External DNS](#external-dns)
        - [Cert Manager](#cert-manager)
  - [Generation of jx-requirements.yml](#generation-of-jx-requirementsyml)
  - [Conditional creation](#conditional-creation)
  - [FAQ: Frequently Asked Questions](#faq-frequently-asked-questions)
    - [IAM Roles for Service Accounts](#iam-roles-for-service-accounts)
  - [Generated Documentation](#generated-documentation)
    - [Providers](#providers)
    - [Inputs](#inputs)
    - [Outputs](#outputs)

<!-- /TOC -->

## What is a Terraform Module
<a id="markdown-what-is-a-terraform-module" name="what-is-a-terraform-module"></a>

A Terraform Module refers to a self-contained package of Terraform configurations that are managed as a group.
For more information around Modules refer to the Terraform [documentation](https://www.terraform.io/docs/modules/index.html).

## How do you use this Module
<a id="markdown-how-do-you-use-this-module" name="how-do-you-use-this-module"></a>

### Assumptions
<a id="markdown-assumptions" name="assumptions"></a>

You want to create an EKS cluster for installation of Jenkins X.

Both `kubectl` (>=1.10) and `aws-iam-authenticator` are installed and on your shell's PATH.

### Usage
<a id="markdown-usage" name="usage"></a>

A default Jenkins X ready cluster can be provisioned by creating a main.tf file in an empty directory with the following content:

```
    module "eks-jx" {
      source  = "jenkins-x/eks-jx/aws"
    }
```
The name of the cluster will be randomized but you can provide your own name.

Refer to the documentation for additional variables.

You can then apply this Terraform configuration via:

```sh
terraform init
terraform apply -var='vault_user=<your_vault_IAM_username>' 
```

#### Examples

You can find some examples on different configurations in the [examples folder](examples).

These include a `basic` configuration and a configuration with `vault` resources being created.

Both will generate a valid `jx-requirements.yml` file that can be used to boot a Jenkins X cluster.

#### VPC configuration
<a id="markdown-vpc-configuration" name="vpc-configuration"></a>

The following variables allow you to configure the settings of the generated VPC: `vpc_name`, `vpc_subnets` and `vpc_cidr_blocl`.

#### EKS Worker Nodes configuration
<a id="markdown-eks-worker-nodes-config" name="eks-worker-nodes-config"></a>

You can configure the EKS worker node pool with the following variables: `desired_number_of_nodes`, `min_number_of_nodes`, `max_number_of_nodes` and `worker_nodes_instance_types`.

#### Long Term Storage
<a id="markdown-long-term-storage" name="long-term-storage"></a>

You can choose whether to create S3 buckets for long term storage and enable them in the generated `jx-requirements.yml` file with the `enable_logs_storage`, `enable_reports_storage` and `enable_repository_storage`

If these variables are `true`, after creating the necessary S3 buckets, it will configure the `jx-requirements.yml` file in the following section:

```yaml
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
```

#### Vault configuration
<a id="markdown-vault-configuration" name="vault-configuration"></a>

Vault resources will be created when running this script.

These resources are: An S3 Bucket, a DynamoDB Table and a KMS Key.

The `vault_user` variable is required when running this script. This is the user whose credentials will be used to authenticate the Vault pods against AWS.

#### External DNS and Cert Manager
<a id="markdown-exdns-cm" name="exdns-cm"></a>

##### External DNS
<a id="markdown-exdns" name="exdns"></a>

You can enable External DNS with the `enable_external_dns` variable. This will modify the generated `jx-requirements.yml` file to enable External DNS when running `jx boot`. 

If `enable_external_dns` is true, additional configuration will be required.

If you want to use a domain with an already existing Route 53 Hosted Zone, you can provide it through the `apex_domain` variable:

This domain will be configured in the resulting `jx-requirements.yml` file in the following section:

```yaml
    ingress:
      domain: ${domain}
      ignoreLoadBalancer: true
      externalDNS: ${enable_external_dns}
```

If you want to use a subdomain and have this script create and configure a new Hosted Zone with DNS delegation, you can provide the following variables:

`subdomain`: This subdomain will be added to the apex domain. This will be configured in the resulting `jx-requirements.yml` file.

`create_and_configure_subdomain`: This flag will instruct the script to create a new `Route53 Hosted Zone` for your subdomain and configure DNS delegation with the apex domain.

By providing these variables, the script creates a new `Route 53` HostedZone that looks like `<subdomain>.<apex_domain>`, then it delegates the resolving of DNS to the apex domain.
This is done by creating a `NS` RecordSet in the apex domain's Hosted Zone with the subdomain's HostedZone nameservers.

This will make sure that the newly created HostedZone for the subdomain is instantly resolvable instead of having to wait for DNS propagation.

##### Cert Manager
<a id="markdown-certmanager" name="certmanager"></a>

You can enable Cert Manager to use TLS for your cluster through LetsEncrypt with the `enable_tls` variable.

LetsEncrypt has two environments, `staging` and `production`.

If you use staging, you will receive self-signed certificates, but you are not rate limited, if you use the `production` environment, you receive certificates signed by LetsEncrypt, but you can be rate limited.

You can choose to use the `production` environment with the `production_letsencrypt` variable:

You need to provide a valid email to register your domain in LetsEncrypt with `tls_email`:

## Generation of jx-requirements.yml
<a id="markdown-jxreq-generation" name="jxreq-generation"></a>


The final output of running this module will not only be the creation of cloud resources but also the creation of a valid `jx-requirements.yml` file.
You can use this file to install Jenkins X by running:

```bash
 jx boot -r jx-requirements.yml
```

The template can be found [here](https://github.com/jenkins-x/terraform-aws-eks-jx/blob/master/jx-requirements.yml.tpl)

## Conditional creation
<a id="markdown-conditional-creation" name="conditional-creation"></a>


Sometimes you need to have a way to create resources conditionally; however, Terraform does not allow to use `count` inside a module block.
There still isn't a solution for this in this repository, but we will be working to allow users to provide their own VPC, subnets etc.

## FAQ: Frequently Asked Questions
<a id="markdown-conditional-faq" name="faq"></a>

### IAM Roles for Service Accounts
<a id="markdown-irsa" name="irsa"></a>

This module sets up a series of IAM Policies and Roles. These roles will be annotated into a few Kubernetes Service accounts.

This allows us to make use of IAM Roles for Sercive Accounts to set fine-grained permissions on a pod per pod basis.

There still isn't a way to provide your roles or define other Service Accounts by variables, but you can always modify the `eks/terraform/jx/irsa.tf` Terraform file.

## Generated Documentation
<a id="markdown-generated-documentation" name="generated-documentation"></a>

The following tables are generated with `terraform-docs`:

### Providers
<a id="markdown-providers" name="providers"></a>


| Name | Version |
|------|---------|
| local | ~> 1.2 |
| random | ~> 2.1 |


### Inputs
<a id="markdown-inputs" name="inputs"></a>


| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| apex\_domain | The main domain to either use directly or to configure a subdomain from | `string` | `""` | no |
| cluster\_name | Variable to provide your desired name for the cluster. The script will create a random name if this is empty | `string` | `""` | no |
| create\_and\_configure\_subdomain | Flag to create an NS record ser for the subdomain in the apex domain's Hosted Zone | `bool` | `false` | no |
| desired\_number\_of\_nodes | The number of worker nodes to use for the cluster | `number` | `3` | no |
| enable\_external\_dns | Flag to enable or disable External DNS in the final `jx-requirements.yml` file | `bool` | `false` | no |
| enable\_logs\_storage | Flag to enable or disable long term storage for logs | `bool` | `true` | no |
| enable\_reports\_storage | Flag to enable or disable long term storage for reports | `bool` | `true` | no |
| enable\_repository\_storage | Flag to enable or disable the repository bucket storage | `bool` | `true` | no |
| enable\_tls | Flag to enable TLS int he final `jx-requirements.yml` file | `bool` | `false` | no |
| manage\_aws\_auth | Whether to apply the aws-auth configmap file | `bool` | `true` | no |
| max\_number\_of\_nodes | The maximum number of worker nodes to use for the cluster | `number` | `5` | no |
| min\_number\_of\_nodes | The minimum number of worker nodes to use for the cluster | `number` | `3` | no |
| production\_letsencrypt | Flag to use the production environment of letsencrypt in the `jx-requirements.yml` file | `bool` | `false` | no |
| region | The region to create the resources into | `string` | `"us-east-1"` | no |
| subdomain | The subdomain to be used added to the apex domain. If subdomain is set, it will be appended to the apex domain in  `jx-requirements-eks.yml` file | `string` | `""` | no |
| tls\_email | The email to register the LetsEncrypt certificate with. Added to the `jx-requirements.yml` file | `string` | `""` | no |
| vault\_user | The AWS IAM Username whose credentials will be used to authenticate the Vault pods against AWS | `string` | n/a | yes |
| vpc\_cidr\_block | The vpc CIDR block | `string` | `"10.0.0.0/16"` | no |
| vpc\_name | The name of the VPC to be created for the cluster | `string` | `"tf-vpc-eks"` | no |
| vpc\_subnets | The subnet CIDR block to use in the created VPC | `list(string)` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24",<br>  "10.0.3.0/24"<br>]</pre> | no |
| wait\_for\_cluster\_cmd | Custom local-exec command to execute for determining if the eks cluster is healthy. Cluster endpoint will be available as an environment variable called ENDPOINT | `string` | `"until curl -k -s $ENDPOINT/healthz \u003e/dev/null; do sleep 4; done"` | no |
| worker\_nodes\_instance\_types | The instance type to use for the cluster's worker nodes | `string` | `"m5.large"` | no |

### Outputs
<a id="markdown-outputs" name="outputs"></a>


| Name | Description |
|------|-------------|
| cert\_manager\_iam\_role | The IAM Role that the Cert Manager pod will assume to authenticate |
| cluster\_name | The name of the created cluster |
| cm\_cainjector\_iam\_role | The IAM Role that the CM CA Injector pod will assume to authenticate |
| controllerbuild\_iam\_role | The IAM Role that the ControllerBuild pod will assume to authenticate |
| external\_dns\_iam\_role | The IAM Role that the External DNS pod will assume to authenticate |
| jxui\_iam\_role | The IAM Role that the Jenkins X UI pod will assume to authenticate |
| lts\_logs\_bucket | The bucket where logs from builds will be stored |
| lts\_reports\_bucket | The bucket where test reports will be stored |
| lts\_repository\_bucket | The bucket that will serve as artifacts repository |
| tekton\_bot\_iam\_role | The IAM Role that the build pods will assume to authenticate |
| vault\_dynamodb\_table | The bucket that Vault will use as backend |
| vault\_kms\_unseal | The KMS Key that Vault will use for encryption |
| vault\_unseal\_bucket | The bucket that Vault will use for storage |
