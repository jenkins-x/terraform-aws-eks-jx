# Jenkins X EKS Module

This repository contains a Terraform module for creating an EKS cluster and all the necessary infrastructure to install Jenkins X as described in https://jenkins-x.io/v3/admin/platforms/eks/.

The module makes use of the [Terraform EKS cluster Module](https://github.com/terraform-aws-modules/terraform-aws-eks).

<!-- TOC -->

- [Jenkins X EKS Module](#jenkins-x-eks-module)
  - [What is a Terraform module](#what-is-a-terraform-module)
  - [How do you use this module](#how-do-you-use-this-module)
    - [Prerequisites](#prerequisites)
    - [Cluster provisioning](#cluster-provisioning)
      - [AWS_REGION](#aws_region)
    - [Cluster Autoscaling](#cluster-autoscaling)
    - [Long Term Storage](#long-term-storage)
    - [Secrets Management](#secrets-management)
    - [NGINX](#nginx)
    - [ExternalDNS](#externaldns)
    - [cert-manager](#cert-manager)
    - [Customer's CA certificates](#customers-ca-certificates)
    - [Velero Backups](#velero-backups)
      - [Enabling backups on pre-existing clusters](#enabling-backups-on-pre-existing-clusters)
    - [Production cluster considerations](#production-cluster-considerations)
    - [Configuring a Terraform backend](#configuring-a-terraform-backend)
    - [Examples](#examples)
    - [Module configuration](#module-configuration)
      - [Providers](#providers)
      - [Modules](#modules)
      - [Requirements](#requirements)
      - [Inputs](#inputs)
      - [Outputs](#outputs)
  - [FAQ: Frequently Asked Questions](#faq-frequently-asked-questions)
    - [IAM Roles for Service Accounts](#iam-roles-for-service-accounts)
  - [Development](#development)
    - [Releasing](#releasing)
  - [How can I contribute](#how-can-i-contribute)

<!-- /TOC -->

## What is a Terraform module

A Terraform module refers to a self-contained package of Terraform configurations that are managed as a group.
For more information about modules refer to the Terraform [documentation](https://www.terraform.io/docs/modules/index.html).

## How do you use this module

### Prerequisites

This Terraform module allows you to create an [EKS](https://aws.amazon.com/eks/) cluster ready for the installation of Jenkins X.
You need the following binaries locally installed and configured on your _PATH_:

- `terraform` (>= 1.0.0, < 2.0.0)
- `kubectl` (>= 1.10)
- `aws-cli`
- `helm` (>= 3.0)

### Cluster provisioning

A Jenkins X ready cluster can be provisioned using the configuration in
[jx3-terraform-eks](https://github.com/jx3-gitops-repositories/jx3-terraform-eks) as described in
https://jenkins-x.io/v3/admin/platforms/eks/.

All s3 buckets created by the module use Server-Side Encryption with Amazon S3-Managed Encryption Keys
(SSE-S3) by default.
You can set the value of `use_kms_s3` to true to use server-side encryption with AWS KMS (SSE-KMS).
If you don't specify the value of `s3_kms_arn`, then the default aws managed cmk is used (aws/s3)

:warning: **Note**: Using AWS KMS with customer managed keys has cost
[considerations](https://aws.amazon.com/blogs/storage/changing-your-amazon-s3-encryption-from-s3-managed-encryption-sse-s3-to-aws-key-management-service-sse-kms/).

You should have your [AWS CLI configured correctly](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html).



#### AWS_REGION

In addition, you should make sure to specify the region via the AWS_REGION environment variable. e.g.
`export AWS_REGION=us-east-1` and the region variable (make sure the region variable matches the environment variable)

The IAM user does not need any permissions attached to it.

Once you have your initial configuration, you can apply it by running:

```sh
terraform init
terraform apply
```

This creates an EKS cluster with all possible configuration options defaulted.

:warning: **Note**: This example is for getting up and running quickly.
It is not intended for a production cluster.
Refer to [Production cluster considerations](#production-cluster-considerations) for things to consider when creating a production cluster.


### Migrating to current version of module from a version pre 3.0.0

From version 3.0.0 this module creates neither the EKS cluster nor the VPC.  

### Cluster Autoscaling

This does not automatically install cluster-autoscaler, it installs all of the prerequisite policies and roles required to install autoscaler.
The actual autoscaler installation varies depending on what version of kubernetes you are using.

To install cluster autoscaler, first you will need the ARN of the cluster-autoscaler role.

You can create the following output along side your module definition to find this:

```terraform
output "cluster_autoscaler_iam_role_arn" {
  value = module.eks-jx.cluster_autoscaler_iam_role.this_iam_role_arn
}
```

With the ARN, you may now install the cluster autoscaler using Helm.

Create the file `cluster-autoscaler-values.yaml` with the following content:

```yaml
awsRegion: us-east-1

rbac:
  serviceAccount:
    name: cluster-autoscaler
    annotations:
      eks.amazonaws.com/role-arn: "arn:aws:iam::12345678910:role/tf-your-cluster-name-cluster-autoscaler"

autoDiscovery:
  clusterName: your-cluster-name

image:
  repository: us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler
  tag: v1.19.1
```

Notice the image tag is `v1.19.1` - this tag goes with clusters running Kubernetes 1.19.
If you are running 1.20, 1.21, etc, you will need to find the image tag that matches your cluster version.
To see available tags, visit [this GCR registry](https://console.cloud.google.com/gcr/images/k8s-artifacts-prod/US/autoscaling/cluster-autoscaler?gcrImageListsize=30)

Next, you'll need to fetch the chart, apply your values using `helm template` and then apply the resulting Kubernetes object to your cluster.

```
helm fetch stable/cluster-autoscaler --untar
```

And then

```
helm template --name cluster-autoscaler --namespace kube-system ./cluster-autoscaler -f ./cluster-autoscaler-values.yaml | kubectl apply -n kube-system -f -
```

### Long Term Storage

You can choose to create S3 buckets for [long term storage](https://jenkins-x.io/v3/admin/setup/config/storage/) of Jenkins X build artefacts with `enable_logs_storage`, `enable_reports_storage` and `enable_repository_storage`.

During `terraform apply` the enabled S3 buckets are created, and the _jx_requirements_ output will contain the following section:

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

If you just want to experiment with Jenkins X, you can set the variable _force_destroy_ to true.
This allows you to remove all generated buckets when running terraform destroy.

:warning: **Note**: If you set `force_destroy` to false, and run a `terraform destroy`, it will fail. In that case empty the s3 buckets from the aws s3 console, and re run `terraform destroy`.

:warning: **Note**: A notice from Amazon: [Amazon S3 will automatically enable S3 Block Public Access and disable access control lists for all new buckets starting in April 2023](https://aws.amazon.com/about-aws/whats-new/2022/12/amazon-s3-automatically-enable-block-public-access-disable-access-control-lists-buckets-april-2023/). To accomodate this acl setting was removed for buckets and the `enable_acl` variable was introduced and set to false (default). If the requirement is to provide ACL with bucket ownership conrols for the bucket, then set the `enable_acl` variable to true.   


### Secrets Management

[Vault](https://www.vaultproject.io/) is the default tool used by Jenkins X for managing secrets.
Part of this module's responsibilities is the installation of [Vault Operator](https://github.com/banzaicloud/bank-vaults) which in turn install vault.

You can also configure an existing Vault instance for use with Jenkins X.
In this case

- provide the Vault URL via the _vault_url_ input variable
- set the `boot_secrets` in `main.tf` to this value:
```bash
boot_secrets = [
    {
      name  = "jxBootJobEnvVarSecrets.EXTERNAL_VAULT"
      value = "true"
      type  = "string"
    },
    {
      name  = "jxBootJobEnvVarSecrets.VAULT_ADDR"
      value = "https://enter-your-vault-url:8200"
      type  = "string"
    }
  ]
```
- follow the Jenkins X documentation around the installation of an [external Vault](https://jenkins-x.io/v3/admin/setup/secrets/vault/#external-vault) instance.

To use AWS Secrets Manager instead of vault, set `use_vault` variable to false, and `use_asm` variable to true.
You will also need a role that grants access to AWS Secrets Manager, this will be created for you by setting `create_asm_role` variable to true.
Setting the above variables will add the asm role arn to the boot job service account, which is required for the boot job to interact with AWS secrets manager to populate secrets.

### NGINX

The module can install the nginx chart by setting `create_nginx` flag to `true`.
Example can be found [here](./example/jx3).
You can specify a nginx_values.yaml file or the module will use the default one stored [here](./modules/nginx/nginx_values.yaml).
If you are using terraform to create nginx resources, do not use the chart specified in the versionstream.
Remove the entry in the [`helmfile.yaml`](https://github.com/DexaiRobotics/jx3-eks-vault/blob/master/helmfile.yaml) referencing the nginx chart

```
path: helmfiles/nginx/helmfile.yaml
```

### ExternalDNS

You can enable [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) with the `enable_external_dns` variable. This modifies the generated _jx-requirements.yml_ file to enable External DNS when running `jx boot`.

If `enable_external_dns` is _true_, additional configuration is required.

If you want to use a domain with an already existing Route 53 Hosted Zone, you can provide it through the `apex_domain` variable:

This domain will be configured in the _jx_requirements_ output in the following section:

```yaml
ingress:
  domain: ${domain}
  ignoreLoadBalancer: true
  externalDNS: ${enable_external_dns}
```

If you want to use a subdomain and have this module create and configure a new Hosted Zone with DNS delegation, you can provide the following variables:

`subdomain`: This subdomain is added to the apex domain and configured in the resulting _jx-requirements.yml_ file.

`create_and_configure_subdomain`: This flag instructs the script to create a new `Route53 Hosted Zone` for your subdomain and configure DNS delegation with the apex domain.

By providing these variables, the script creates a new `Route 53` HostedZone that looks like `<subdomain>.<apex_domain>`, then it delegates the resolving of DNS to the apex domain.
This is done by creating a `NS` RecordSet in the apex domain's Hosted Zone with the subdomain's HostedZone nameservers.

This ensures that the newly created HostedZone for the subdomain is instantly resolvable instead of having to wait for DNS propagation.

### cert-manager

You can enable [cert-manager](https://github.com/jetstack/cert-manager) to use TLS for your cluster through LetsEncrypt with the `enable_tls` variable.

[LetsEncrypt](https://letsencrypt.org/) has two environments, `staging` and `production`.

If you use staging, you will receive self-signed certificates, but you are not rate-limited, if you use the `production` environment, you receive certificates signed by LetsEncrypt, but you can be rate limited.

You can choose to use the `production` environment with the `production_letsencrypt` variable:

You need to provide a valid email to register your domain in LetsEncrypt with `tls_email`.

### Customer's CA certificates

Customer has got signed certificates from CA and want to use it instead of LetsEncrypt certificates. Terraform creates k8s `tls-ingress-certificates-ca` secret with `tls_key` and `tls_cert` in `default` namespace.
User should define:

```
enable_external_dns = true
apex_domain         = "office.com"
subdomain           = "subdomain"
enable_tls          = true
tls_email           = "custome@office.com"

// Signed Certificate must match the domain: *.subdomain.office.com
tls_cert            = "/opt/CA/cert.crt"
tls_key             = "LS0tLS1C....BLRVktLS0tLQo="
```

### Velero Backups

This module can set up the resources required for running backups with Velero on your cluster by setting the flag `enable_backup` to `true`.

#### Enabling backups on pre-existing clusters

If your cluster is pre-existing and already contains a namespace named `velero`, then enabling backups will initially fail with an error that you are trying to create a namespace which already exists.

```
Error: namespaces "velero" already exists
```

If you get this error, consider it a warning - you may then adjust accordingly by importing that namespace to be managed by Terraform, deleting the previously existing ns if it wasn't actually in use, or setting `enable_backup` back to `false` to continue managing Velero in the previous manner.

The recommended way is to import the namespace and then run another Terraform plan and apply:

```
terraform import module.eks-jx.module.backup.kubernetes_namespace.velero_namespace velero
```
### Production cluster considerations

The configuration, as seen in [Cluster provisioning](#cluster-provisioning), is not suited for creating and maintaining a production Jenkins X cluster.
The following is a list of considerations for a production use case.

- Specify the version attribute of the module, for example:

  ```terraform
  module "eks-jx" {
    source  = "github.com/jenkins-x/terraform-aws-eks-jx"
    version = "1.0.0"
    # insert your configuration
  }

  output "jx_requirements" {
    value = module.eks-jx.jx_requirements
  }
  ```

  Specifying the version ensures that you are using a fixed version and that version upgrades cannot occur unintended.

- Keep the Terraform configuration under version control by creating a dedicated repository for your cluster configuration or by adding it to an already existing infrastructure repository.

- Setup a Terraform backend to securely store and share the state of your cluster. For more information refer to [Configuring a Terraform backend](#configuring-a-terraform-backend).

- Disable public API for the EKS cluster.
  If that is not not possible, restrict access to it by specifying the cidr blocks which can access it.

### Configuring a Terraform backend

A "[backend](https://www.terraform.io/docs/backends/index.html)" in Terraform determines how state is loaded and how an operation such as _apply_ is executed.
By default, Terraform uses the _local_ backend, which keeps the state of the created resources on the local file system.
This is problematic since sensitive information will be stored on disk and it is not possible to share state across a team.
When working with AWS a good choice for your Terraform backend is the [_s3_ backend](https://www.terraform.io/docs/backends/types/s3.html) which stores the Terraform state in an AWS S3 bucket.
The [examples](./examples) directory of this repository contains configuration examples for using the _s3_ backed.

To use the _s3_ backend, you will need to create the bucket upfront.
You need the S3 bucket as well as a Dynamo table for state locks.
You can use [terraform-aws-tfstate-backend](https://github.com/cloudposse/terraform-aws-tfstate-backend) to create these required resources.


### Examples

You can find examples for different configurations in the [examples folder](./examples).

Each example generates a valid _jx-requirements.yml_ file that can be used to boot a Jenkins X cluster.

### Module configuration

<!-- BEGIN_TF_DOCS # Autogenerated do not edit! -->
#### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | > 4.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |
#### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backup"></a> [backup](#module\_backup) | ./modules/backup | n/a |
| <a name="module_cluster"></a> [cluster](#module\_cluster) | ./modules/cluster | n/a |
| <a name="module_dns"></a> [dns](#module\_dns) | ./modules/dns | n/a |
| <a name="module_health"></a> [health](#module\_health) | ./modules/health | n/a |
| <a name="module_nginx"></a> [nginx](#module\_nginx) | ./modules/nginx | n/a |
| <a name="module_vault"></a> [vault](#module\_vault) | ./modules/vault | n/a |
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.17, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | > 4.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |
#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tekton_role_policy_arns"></a> [additional\_tekton\_role\_policy\_arns](#input\_additional\_tekton\_role\_policy\_arns) | Additional Policy ARNs to attach to Tekton IRSA Role | `list(string)` | `[]` | no |
| <a name="input_apex_domain"></a> [apex\_domain](#input\_apex\_domain) | The main domain to either use directly or to configure a subdomain from | `string` | `""` | no |
| <a name="input_asm_role"></a> [asm\_role](#input\_asm\_role) | DEPRECATED: Use the new bot\_iam\_role input with he same semantics instead. | `string` | `""` | no |
| <a name="input_boot_iam_role"></a> [boot\_iam\_role](#input\_boot\_iam\_role) | Specify arn of the role to apply to the boot job service account | `string` | `""` | no |
| <a name="input_boot_secrets"></a> [boot\_secrets](#input\_boot\_secrets) | n/a | <pre>list(object({<br>    name  = string<br>    value = string<br>    type  = string<br>  }))</pre> | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Variable to provide your desired name for the cluster. The script will create a random name if this is empty | `string` | `""` | no |
| <a name="input_create_and_configure_subdomain"></a> [create\_and\_configure\_subdomain](#input\_create\_and\_configure\_subdomain) | Flag to create an NS record set for the subdomain in the apex domain's Hosted Zone | `bool` | `false` | no |
| <a name="input_create_asm_role"></a> [create\_asm\_role](#input\_create\_asm\_role) | Flag to control AWS Secrets Manager iam roles creation | `bool` | `false` | no |
| <a name="input_create_autoscaler_role"></a> [create\_autoscaler\_role](#input\_create\_autoscaler\_role) | Flag to control cluster autoscaler iam role creation | `bool` | `true` | no |
| <a name="input_create_bucketrepo_role"></a> [create\_bucketrepo\_role](#input\_create\_bucketrepo\_role) | Flag to control bucketrepo role | `bool` | `true` | no |
| <a name="input_create_cm_role"></a> [create\_cm\_role](#input\_create\_cm\_role) | Flag to control cert manager iam role creation | `bool` | `true` | no |
| <a name="input_create_cmcainjector_role"></a> [create\_cmcainjector\_role](#input\_create\_cmcainjector\_role) | Flag to control cert manager ca-injector iam role creation | `bool` | `true` | no |
| <a name="input_create_ctrlb_role"></a> [create\_ctrlb\_role](#input\_create\_ctrlb\_role) | Flag to control controller build iam role creation | `bool` | `true` | no |
| <a name="input_create_exdns_role"></a> [create\_exdns\_role](#input\_create\_exdns\_role) | Flag to control external dns iam role creation | `bool` | `true` | no |
| <a name="input_create_nginx"></a> [create\_nginx](#input\_create\_nginx) | Decides whether we want to create nginx resources using terraform or not | `bool` | `false` | no |
| <a name="input_create_nginx_namespace"></a> [create\_nginx\_namespace](#input\_create\_nginx\_namespace) | Boolean to control nginx namespace creation | `bool` | `true` | no |
| <a name="input_create_pipeline_vis_role"></a> [create\_pipeline\_vis\_role](#input\_create\_pipeline\_vis\_role) | Flag to control pipeline visualizer role | `bool` | `true` | no |
| <a name="input_create_ssm_role"></a> [create\_ssm\_role](#input\_create\_ssm\_role) | Flag to control AWS Parameter Store iam roles creation | `bool` | `false` | no |
| <a name="input_create_tekton_role"></a> [create\_tekton\_role](#input\_create\_tekton\_role) | Flag to control tekton iam role creation | `bool` | `true` | no |
| <a name="input_create_velero_role"></a> [create\_velero\_role](#input\_create\_velero\_role) | Flag to control velero iam role creation | `bool` | `true` | no |
| <a name="input_eks_cluster_tags"></a> [eks\_cluster\_tags](#input\_eks\_cluster\_tags) | Add tags for the EKS Cluster | `map` | `{}` | no |
| <a name="input_enable_acl"></a> [enable\_acl](#input\_enable\_acl) | Flag to enable ACL instead of bucket ownership for S3 storage | `bool` | `false` | no |
| <a name="input_enable_backup"></a> [enable\_backup](#input\_enable\_backup) | Whether or not Velero backups should be enabled | `bool` | `false` | no |
| <a name="input_enable_external_dns"></a> [enable\_external\_dns](#input\_enable\_external\_dns) | Flag to enable or disable External DNS in the final `jx-requirements.yml` file | `bool` | `false` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | Flag to enable kms key rotation | `bool` | `true` | no |
| <a name="input_enable_logs_storage"></a> [enable\_logs\_storage](#input\_enable\_logs\_storage) | Flag to enable or disable long term storage for logs | `bool` | `true` | no |
| <a name="input_enable_reports_storage"></a> [enable\_reports\_storage](#input\_enable\_reports\_storage) | Flag to enable or disable long term storage for reports | `bool` | `true` | no |
| <a name="input_enable_repository_storage"></a> [enable\_repository\_storage](#input\_enable\_repository\_storage) | Flag to enable or disable the repository bucket storage | `bool` | `true` | no |
| <a name="input_enable_tls"></a> [enable\_tls](#input\_enable\_tls) | Flag to enable TLS in the final `jx-requirements.yml` file | `bool` | `false` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Flag to determine whether storage buckets get forcefully destroyed. If set to false, empty the bucket first in the aws s3 console, else terraform destroy will fail with BucketNotEmpty error | `bool` | `false` | no |
| <a name="input_force_destroy_subdomain"></a> [force\_destroy\_subdomain](#input\_force\_destroy\_subdomain) | Flag to determine whether subdomain zone get forcefully destroyed. If set to false, empty the sub domain first in the aws Route 53 console, else terraform destroy will fail with HostedZoneNotEmpty error | `bool` | `false` | no |
| <a name="input_ignoreLoadBalancer"></a> [ignoreLoadBalancer](#input\_ignoreLoadBalancer) | Flag to specify if jx boot will ignore loadbalancer DNS to resolve to an IP | `bool` | `false` | no |
| <a name="input_install_kuberhealthy"></a> [install\_kuberhealthy](#input\_install\_kuberhealthy) | Flag to specify if kuberhealthy operator should be installed | `bool` | `false` | no |
| <a name="input_install_vault"></a> [install\_vault](#input\_install\_vault) | Whether or not this modules creates and manages the Vault instance. If set to false and use\_vault is true either an external Vault URL needs to be provided or you need to install vault operator and instance using helmfile. | `bool` | `true` | no |
| <a name="input_jx_bot_token"></a> [jx\_bot\_token](#input\_jx\_bot\_token) | Bot token used to interact with the Jenkins X cluster git repository | `string` | `""` | no |
| <a name="input_jx_bot_username"></a> [jx\_bot\_username](#input\_jx\_bot\_username) | Bot username used to interact with the Jenkins X cluster git repository | `string` | `""` | no |
| <a name="input_jx_git_operator_values"></a> [jx\_git\_operator\_values](#input\_jx\_git\_operator\_values) | Extra values for jx-git-operator chart as a list of yaml formated strings | `list(string)` | `[]` | no |
| <a name="input_jx_git_url"></a> [jx\_git\_url](#input\_jx\_git\_url) | URL for the Jenkins X cluster git repository | `string` | `""` | no |
| <a name="input_local-exec-interpreter"></a> [local-exec-interpreter](#input\_local-exec-interpreter) | If provided, this is a list of interpreter arguments used to execute the command | `list(string)` | <pre>[<br>  "/bin/bash",<br>  "-c"<br>]</pre> | no |
| <a name="input_manage_apex_domain"></a> [manage\_apex\_domain](#input\_manage\_apex\_domain) | Flag to control if apex domain should be managed/updated by this module. Set this to false,if your apex domain is managed in a different AWS account or different provider | `bool` | `true` | no |
| <a name="input_manage_subdomain"></a> [manage\_subdomain](#input\_manage\_subdomain) | Flag to control subdomain creation/management | `bool` | `true` | no |
| <a name="input_nginx_chart_version"></a> [nginx\_chart\_version](#input\_nginx\_chart\_version) | nginx chart version | `string` | n/a | yes |
| <a name="input_nginx_namespace"></a> [nginx\_namespace](#input\_nginx\_namespace) | Name of the nginx namespace | `string` | `"nginx"` | no |
| <a name="input_nginx_release_name"></a> [nginx\_release\_name](#input\_nginx\_release\_name) | Name of the nginx release name | `string` | `"nginx-ingress"` | no |
| <a name="input_nginx_values_file"></a> [nginx\_values\_file](#input\_nginx\_values\_file) | Name of the values file which holds the helm chart values | `string` | `"nginx_values.yaml"` | no |
| <a name="input_production_letsencrypt"></a> [production\_letsencrypt](#input\_production\_letsencrypt) | Flag to use the production environment of letsencrypt in the `jx-requirements.yml` file | `bool` | `false` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | The AWS Profile used to provision the EKS Cluster | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to create the resources into | `string` | `"us-east-1"` | no |
| <a name="input_registry"></a> [registry](#input\_registry) | Registry used to store images | `string` | `""` | no |
| <a name="input_s3_extra_tags"></a> [s3\_extra\_tags](#input\_s3\_extra\_tags) | Add new tags for s3 buckets | `map` | `{}` | no |
| <a name="input_s3_kms_arn"></a> [s3\_kms\_arn](#input\_s3\_kms\_arn) | ARN of the kms key used for encrypting s3 buckets | `string` | `""` | no |
| <a name="input_subdomain"></a> [subdomain](#input\_subdomain) | The subdomain to be added to the apex domain. If subdomain is set, it will be appended to the apex domain in  `jx-requirements-eks.yml` file | `string` | `""` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | The subnet ids to create EKS cluster in if create\_vpc is false | `list(string)` | `[]` | no |
| <a name="input_tls_cert"></a> [tls\_cert](#input\_tls\_cert) | TLS certificate encrypted with Base64 | `string` | `""` | no |
| <a name="input_tls_email"></a> [tls\_email](#input\_tls\_email) | The email to register the LetsEncrypt certificate with. Added to the `jx-requirements.yml` file | `string` | `""` | no |
| <a name="input_tls_key"></a> [tls\_key](#input\_tls\_key) | TLS key encrypted with Base64 | `string` | `""` | no |
| <a name="input_use_asm"></a> [use\_asm](#input\_use\_asm) | Flag to specify if AWS Secrets manager is being used | `bool` | `false` | no |
| <a name="input_use_kms_s3"></a> [use\_kms\_s3](#input\_use\_kms\_s3) | Flag to determine whether kms should be used for encrypting s3 buckets | `bool` | `false` | no |
| <a name="input_use_vault"></a> [use\_vault](#input\_use\_vault) | Flag to control vault resource creation | `bool` | `true` | no |
| <a name="input_vault_url"></a> [vault\_url](#input\_vault\_url) | URL to an external Vault instance in case Jenkins X does not create its own system Vault | `string` | `""` | no |
| <a name="input_velero_namespace"></a> [velero\_namespace](#input\_velero\_namespace) | Kubernetes namespace for Velero | `string` | `"velero"` | no |
| <a name="input_velero_schedule"></a> [velero\_schedule](#input\_velero\_schedule) | The Velero backup schedule in cron notation to be set in the Velero Schedule CRD (see [default-backup.yaml](https://github.com/jenkins-x/jenkins-x-boot-config/blob/master/systems/velero-backups/templates/default-backup.yaml)) | `string` | `"0 * * * *"` | no |
| <a name="input_velero_ttl"></a> [velero\_ttl](#input\_velero\_ttl) | The the lifetime of a velero backup to be set in the Velero Schedule CRD (see [default-backup.yaml](https://github.com/jenkins-x/jenkins-x-boot-config/blob/master/systems/velero-backups/templates/default-backup)) | `string` | `"720h0m0s"` | no |
| <a name="input_velero_username"></a> [velero\_username](#input\_velero\_username) | The username to be assigned to the Velero IAM user | `string` | `"velero"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC to create EKS cluster in if create\_vpc is false | `string` | `""` | no |
#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_bucket_url"></a> [backup\_bucket\_url](#output\_backup\_bucket\_url) | The bucket where backups from velero will be stored |
| <a name="output_cert_manager_iam_role"></a> [cert\_manager\_iam\_role](#output\_cert\_manager\_iam\_role) | The IAM Role that the Cert Manager pod will assume to authenticate |
| <a name="output_cluster_asm_iam_role"></a> [cluster\_asm\_iam\_role](#output\_cluster\_asm\_iam\_role) | The IAM Role that the External Secrets pod will assume to authenticate (Secrets Manager) |
| <a name="output_cluster_autoscaler_iam_role"></a> [cluster\_autoscaler\_iam\_role](#output\_cluster\_autoscaler\_iam\_role) | The IAM Role that the Jenkins X UI pod will assume to authenticate |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the created cluster |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | The Cluster OIDC Issuer URL |
| <a name="output_cluster_ssm_iam_role"></a> [cluster\_ssm\_iam\_role](#output\_cluster\_ssm\_iam\_role) | The IAM Role that the External Secrets pod will assume to authenticate (Parameter Store) |
| <a name="output_cm_cainjector_iam_role"></a> [cm\_cainjector\_iam\_role](#output\_cm\_cainjector\_iam\_role) | The IAM Role that the CM CA Injector pod will assume to authenticate |
| <a name="output_connect"></a> [connect](#output\_connect) | "The cluster connection string to use once Terraform apply finishes,<br>this command is already executed as part of the apply, you may have to provide the region and<br>profile as environment variables " |
| <a name="output_controllerbuild_iam_role"></a> [controllerbuild\_iam\_role](#output\_controllerbuild\_iam\_role) | The IAM Role that the ControllerBuild pod will assume to authenticate |
| <a name="output_external_dns_iam_role"></a> [external\_dns\_iam\_role](#output\_external\_dns\_iam\_role) | The IAM Role that the External DNS pod will assume to authenticate |
| <a name="output_jx_requirements"></a> [jx\_requirements](#output\_jx\_requirements) | The jx-requirements rendered output |
| <a name="output_lts_logs_bucket"></a> [lts\_logs\_bucket](#output\_lts\_logs\_bucket) | The bucket where logs from builds will be stored |
| <a name="output_lts_reports_bucket"></a> [lts\_reports\_bucket](#output\_lts\_reports\_bucket) | The bucket where test reports will be stored |
| <a name="output_lts_repository_bucket"></a> [lts\_repository\_bucket](#output\_lts\_repository\_bucket) | The bucket that will serve as artifacts repository |
| <a name="output_pipeline_viz_iam_role"></a> [pipeline\_viz\_iam\_role](#output\_pipeline\_viz\_iam\_role) | The IAM Role that the pipeline visualizer pod will assume to authenticate |
| <a name="output_subdomain_nameservers"></a> [subdomain\_nameservers](#output\_subdomain\_nameservers) | ---------------------------------------------------------------------------- DNS ---------------------------------------------------------------------------- |
| <a name="output_tekton_bot_iam_role"></a> [tekton\_bot\_iam\_role](#output\_tekton\_bot\_iam\_role) | The IAM Role that the build pods will assume to authenticate |
<!-- BEGIN_TF_DOCS -->

## FAQ: Frequently Asked Questions

### IAM Roles for Service Accounts

This module sets up a series of IAM Policies and Roles. These roles will be annotated into a few Kubernetes Service accounts.
This allows us to make use of [IAM Roles for Sercive Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) to set fine-grained permissions on a pod per pod basis.
There is no way to provide your own roles or define other Service Accounts by variables, but you can always modify the `modules/cluster/irsa.tf` Terraform file.

## Development

## How can I contribute

Contributions are very welcome! Check out the [Contribution Guidelines](./CONTRIBUTING.md) for instructions.
