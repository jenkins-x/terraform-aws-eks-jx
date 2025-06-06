// ----------------------------------------------------------------------------
// IAM Roles for Service Accounts configuration:
//  - We will create IAM Policies, Roles and Service Accounts
//  - Annotate these service accounts with `eks.amazonaws.com/role-arn`
// See https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// Tekton Bot IAM Policy, IAM Role and Service Account
// ----------------------------------------------------------------------------

data "aws_partition" "current" {}
data "aws_iam_policy_document" "tekton-bot-policy" {
  count = var.create_tekton_role ? 1 : 0
  statement {
    sid    = "tektonBotPolicy"
    effect = "Allow"
    actions = [
      "cloudformation:ListStacks",
      "cloudformation:DescribeStacks",
      "cloudformation:CreateStack",
      "cloudformation:DeleteStack",
      "eks:*",
      "s3:*",
      "ecr:*",
      "iam:DetachRolePolicy",
      "iam:GetPolicy",
      "iam:CreatePolicy",
      "iam:DeleteRole",
      "iam:GetOpenIDConnectProvider",
    ]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "tekton-bot" {
  count       = var.create_tekton_role ? 1 : 0
  name_prefix = "jenkins-x-tekton-bot"
  description = "EKS tekton-bot policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.tekton-bot-policy[count.index].json
}
module "iam_assumable_role_tekton_bot" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.8.0"
  create_role                   = var.create_tekton_role
  role_name                     = "${local.cluster_trunc}-tekton-bot"
  provider_url                  = var.cluster_oidc_issuer_url
  role_policy_arns              = var.create_tekton_role ? concat([aws_iam_policy.tekton-bot[0].arn], var.additional_tekton_role_policy_arns) : [""]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.jenkins-x-namespace}:tekton-bot"]
}
// ----------------------------------------------------------------------------
// External DNS IAM Policy, IAM Role and Service Account
// ----------------------------------------------------------------------------
data "aws_iam_policy_document" "external-dns-policy" {
  count = var.create_exdns_role ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
    ]
    resources = ["arn:${data.aws_partition.current.partition}:route53:::hostedzone/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "external-dns" {
  count       = var.create_exdns_role ? 1 : 0
  name_prefix = "jenkins-x-external-dns"
  description = "EKS external-dns policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.external-dns-policy[count.index].json
}
module "iam_assumable_role_external_dns" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.8.0"
  create_role                   = var.create_exdns_role
  role_name                     = "${local.cluster_trunc}-external-dns"
  provider_url                  = var.cluster_oidc_issuer_url
  role_policy_arns              = [var.create_exdns_role ? aws_iam_policy.external-dns[0].arn : ""]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.jenkins-x-namespace}:external-dns"]
}
// ----------------------------------------------------------------------------
// Cert Manager IAM Policy, IAM Role and Service Account
// ----------------------------------------------------------------------------
data "aws_iam_policy_document" "cert-manager-policy" {
  count = var.create_cm_role ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "route53:GetChange",
    ]
    resources = ["arn:${data.aws_partition.current.partition}:route53:::change/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
    ]
    resources = ["arn:${data.aws_partition.current.partition}:route53:::hostedzone/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZonesByName",
    ]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "cert-manager" {
  count       = var.create_cm_role ? 1 : 0
  name_prefix = "jenkins-x-cert-manager"
  description = "EKS cert-manager policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.cert-manager-policy[count.index].json
}
module "iam_assumable_role_cert_manager" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.8.0"
  create_role                   = var.create_cm_role
  role_name                     = "${local.cluster_trunc}-cert-manager-cert-manager"
  provider_url                  = var.cluster_oidc_issuer_url
  role_policy_arns              = [var.create_cm_role ? aws_iam_policy.cert-manager[0].arn : ""]
  oidc_fully_qualified_subjects = ["system:serviceaccount:cert-manager:cert-manager"]
}
// ----------------------------------------------------------------------------
// CM CAInjector IAM Role and Service Account (Reuses the Cert Manager IAM Policy)
// ----------------------------------------------------------------------------
module "iam_assumable_role_cm_cainjector" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.8.0"
  create_role                   = var.create_cmcainjector_role
  role_name                     = "${local.cluster_trunc}-cert-manager-cert-manager-cainjector"
  provider_url                  = var.cluster_oidc_issuer_url
  role_policy_arns              = [var.create_cmcainjector_role ? aws_iam_policy.cert-manager[0].arn : ""]
  oidc_fully_qualified_subjects = ["system:serviceaccount:cert-manager:cert-manager-cainjector"]
}
// ----------------------------------------------------------------------------
// ControllerBuild IAM Policy, IAM Role and Service Account
// ----------------------------------------------------------------------------

data "aws_iam_policy_document" "controllerbuild-policy" {
  count = var.create_ctrlb_role && length(aws_s3_bucket.logs_jenkins_x) > 0 ? 1 : 0
  statement {
    sid    = "BuildControllerPolicy"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
    ]
    resources = [aws_s3_bucket.logs_jenkins_x.*.arn[0], "${aws_s3_bucket.logs_jenkins_x.*.arn[0]}/*"]
  }
}

resource "aws_iam_policy" "controllerbuild" {
  count       = var.create_ctrlb_role && length(aws_s3_bucket.logs_jenkins_x) > 0 ? 1 : 0
  name_prefix = "jx-bucketrepo"
  description = "bucketrepo policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.controllerbuild-policy[count.index].json
}


module "iam_assumable_role_controllerbuild" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.8.0"
  create_role                   = var.create_ctrlb_role && length(aws_s3_bucket.logs_jenkins_x) > 0
  role_name                     = "${local.cluster_trunc}-build-ctrl"
  provider_url                  = var.cluster_oidc_issuer_url
  role_policy_arns              = aws_iam_policy.controllerbuild[*].arn
  oidc_fully_qualified_subjects = ["system:serviceaccount:jx:jenkins-x-controllerbuild"]
}

// ----------------------------------------------------------------------------
// Cluster Autoscaler
// ----------------------------------------------------------------------------

module "iam_assumable_role_cluster_autoscaler" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.8.0"
  create_role                   = var.create_autoscaler_role
  role_name                     = "${local.cluster_trunc}-cluster-autoscaler-cluster-autoscaler"
  provider_url                  = var.cluster_oidc_issuer_url
  role_policy_arns              = [var.create_autoscaler_role ? aws_iam_policy.cluster_autoscaler[0].arn : ""]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:cluster-autoscaler"]
}

resource "aws_iam_policy" "cluster_autoscaler" {
  count       = var.create_autoscaler_role ? 1 : 0
  name_prefix = "cluster-autoscaler"
  description = "EKS cluster-autoscaler policy for cluster ${local.cluster_trunc}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler[count.index].json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  count = var.create_autoscaler_role ? 1 : 0
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeImages",
      "ec2:GetInstanceTypesFromInstanceRequirements",
      "eks:DescribeNodegroup"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "clusterAutoscalerOwn"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeScalingActivities",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${local.cluster_trunc}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

// Pipeline visualizer
data "aws_iam_policy_document" "pipelines-visualizer-policy" {
  count = var.create_pipeline_vis_role && length(aws_s3_bucket.logs_jenkins_x) > 0 ? 1 : 0
  statement {
    sid    = "JxPipelineVisualizerPolicy"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
    ]
    resources = [aws_s3_bucket.logs_jenkins_x.*.arn[0], "${aws_s3_bucket.logs_jenkins_x.*.arn[0]}/*"]
  }
}

resource "aws_iam_policy" "pipeline-visualizer" {
  count       = var.create_pipeline_vis_role && length(aws_s3_bucket.logs_jenkins_x) > 0 ? 1 : 0
  name_prefix = "jx-pipelines-visualizer"
  description = "JenkinsX pipline visualizer policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.pipelines-visualizer-policy[count.index].json
}

module "iam_assumable_role_pipeline_visualizer" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.8.0"
  create_role                   = var.create_pipeline_vis_role && length(aws_s3_bucket.logs_jenkins_x) > 0
  role_name                     = "${local.cluster_trunc}-jx-pipelines-visualizer"
  provider_url                  = var.cluster_oidc_issuer_url
  role_policy_arns              = [var.create_pipeline_vis_role && length(aws_s3_bucket.logs_jenkins_x) > 0 ? aws_iam_policy.pipeline-visualizer[0].arn : ""]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.jenkins-x-namespace}:jx-pipelines-visualizer"]
}

// Bucketrepo
data "aws_iam_policy_document" "bucketrepo-policy" {
  count = var.create_bucketrepo_role && length(aws_s3_bucket.repository_jenkins_x) > 0 ? 1 : 0
  statement {
    sid    = "BucketRepoPolicy"
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [aws_s3_bucket.repository_jenkins_x.*.arn[0], "${aws_s3_bucket.repository_jenkins_x.*.arn[0]}/*"]
  }
}

resource "aws_iam_policy" "bucketrepo" {
  count       = var.create_bucketrepo_role && length(aws_s3_bucket.repository_jenkins_x) > 0 ? 1 : 0
  name_prefix = "jx-bucketrepo"
  description = "bucketrepo policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.bucketrepo-policy[count.index].json
}

module "iam_assumable_role_bucketrepo" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.8.0"
  create_role                   = var.create_bucketrepo_role && length(aws_s3_bucket.repository_jenkins_x) > 0
  role_name                     = "${local.cluster_trunc}-jx-bucketrepo"
  provider_url                  = var.cluster_oidc_issuer_url
  role_policy_arns              = [var.create_bucketrepo_role && length(aws_s3_bucket.repository_jenkins_x) > 0 ? aws_iam_policy.bucketrepo[0].arn : ""]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.jenkins-x-namespace}:bucketrepo-bucketrepo"]
}

// ----------------------------------------------------------------------------
// External Secrets - SecretsManager
// ----------------------------------------------------------------------------
data "aws_iam_policy_document" "secrets-manager-policy" {
  count = var.create_asm_role ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:CreateSecret",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecret",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:secretsmanager:${var.region}:${local.project}:secret:*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:ListSecrets",
    ]
    resources = [
      "*",
    ]
  }
}
resource "aws_iam_policy" "secrets-manager" {
  count       = var.create_asm_role ? 1 : 0
  name_prefix = "jx-external-secrets-secrets-manager"
  description = "external-secrets policy for cluster ${var.cluster_name} for Secrets Manager ServiceAccount"
  policy      = data.aws_iam_policy_document.secrets-manager-policy[count.index].json
}
module "iam_assumable_role_secrets-secrets-manager" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.8.0"
  create_role                   = var.create_asm_role
  role_name                     = "${local.cluster_trunc}-external-secrets-secrets-manager"
  provider_url                  = var.cluster_oidc_issuer_url
  role_policy_arns              = [var.create_asm_role ? aws_iam_policy.secrets-manager[0].arn : ""]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.secret-infra-namespace}:kubernetes-external-secrets", "system:serviceaccount:${local.git-operator-namespace}:jx-boot-job"]
}
// ----------------------------------------------------------------------------
// External Secrets - Parameter Store
// ----------------------------------------------------------------------------
data "aws_iam_policy_document" "system-manager-policy" {
  count = var.create_ssm_role ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "ssm:DeleteParameter",
      "ssm:DeleteParameters",
      "ssm:DescribeParameters",
      "ssm:GetParameter",
      "ssm:GetParameterHistory",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "ssm:PutParameter",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ssm:${var.region}:${local.project}:parameter:secret/data/lighthouse/*",
      "arn:${data.aws_partition.current.partition}:ssm:${var.region}:${local.project}:parameter:secret/data/jx/*",
      "arn:${data.aws_partition.current.partition}:ssm:${var.region}:${local.project}:parameter:secret/data/nexus/*"
    ]
  }
}

resource "aws_iam_policy" "system-manager" {
  count       = var.create_ssm_role ? 1 : 0
  name_prefix = "jx-external-secrets-system-manager"
  description = "external-secrets policy for cluster ${var.cluster_name} for Parameter Store ServiceAccount"
  policy      = data.aws_iam_policy_document.system-manager-policy[count.index].json
}

module "iam_assumable_role_secrets-system-manager" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.8.0"
  create_role                   = var.create_ssm_role
  role_name                     = "${local.cluster_trunc}-external-secrets-system-manager"
  provider_url                  = var.cluster_oidc_issuer_url
  role_policy_arns              = [var.create_ssm_role ? aws_iam_policy.system-manager[0].arn : ""]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.secret-infra-namespace}:kubernetes-external-secrets"]
}
