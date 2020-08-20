
// ----------------------------------------------------------------------------
// IAM Roles for Service Accounts configuration:
//  - We will create IAM Policies, Roles and Service Accounts
//  - Annotate these service accounts with `eks.amazonaws.com/role-arn`
// See https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Tekton Bot IAM Policy, IAM Role and Service Account
// ----------------------------------------------------------------------------
data "aws_iam_policy_document" "tekton-bot-policy" {
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
  name_prefix = "jenkins-x-tekton-bot"
  description = "EKS tekton-bot policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.tekton-bot-policy.json
}


module "iam_assumable_role_tekton_bot" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.13.0"
  create_role                   = var.is_jx2
  role_name                     = substr("tf-${var.cluster_name}-sa-role-tekton-bot-${local.generated_seed}", 0, 60)
  provider_url                  = local.oidc_provider_url
  role_policy_arns              = [aws_iam_policy.tekton-bot.arn]
  oidc_fully_qualified_subjects = var.is_jx2 ? ["system:serviceaccount:${kubernetes_namespace.jx[0].id}:tekton-bot"] : []
}

resource "kubernetes_service_account" "tekton-bot" {
  count                           = var.is_jx2 ? 1 : 0
  automount_service_account_token = true
  depends_on = [
    null_resource.kubeconfig
  ]
  metadata {
    name      = "tekton-bot"
    namespace = kubernetes_namespace.jx[0].id
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_tekton_bot.this_iam_role_arn
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
      secret
    ]
  }
}

// ----------------------------------------------------------------------------
// External DNS IAM Policy, IAM Role and Service Account
// ----------------------------------------------------------------------------
data "aws_iam_policy_document" "external-dns-policy" {
  statement {
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = ["arn:aws:route53:::hostedzone/*"]
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
  name_prefix = "jenkins-x-external-dns"
  description = "EKS external-dns policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.external-dns-policy.json
}

module "iam_assumable_role_external_dns" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.13.0"
  create_role                   = var.is_jx2
  role_name                     = substr("tf-${var.cluster_name}-sa-role-external_dns-${local.generated_seed}", 0, 60)
  provider_url                  = local.oidc_provider_url
  role_policy_arns              = [aws_iam_policy.external-dns.arn]
  oidc_fully_qualified_subjects = var.is_jx2 ? ["system:serviceaccount:${kubernetes_namespace.jx[0].id}:exdns-external-dns"] : []
}

resource "kubernetes_service_account" "exdns-external-dns" {
  count                           = var.is_jx2 ? 1 : 0
  automount_service_account_token = true
  depends_on = [
    null_resource.kubeconfig
  ]
  metadata {
    name      = "exdns-external-dns"
    namespace = kubernetes_namespace.jx[0].id
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_external_dns.this_iam_role_arn
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
      secret
    ]
  }
}


// ----------------------------------------------------------------------------
// Cert Manager IAM Policy, IAM Role and Service Account
// ----------------------------------------------------------------------------
data "aws_iam_policy_document" "cert-manager-policy" {
  statement {
    effect = "Allow"

    actions = [
      "route53:GetChange",
    ]

    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = ["arn:aws:route53:::hostedzone/*"]
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
  name_prefix = "jenkins-x-cert-manager"
  description = "EKS cert-manager policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.cert-manager-policy.json
}

module "iam_assumable_role_cert_manager" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.13.0"
  create_role                   = var.is_jx2
  role_name                     = substr("tf-${var.cluster_name}-sa-role-cert_manager-${local.generated_seed}", 0, 60)
  provider_url                  = local.oidc_provider_url
  role_policy_arns              = [aws_iam_policy.cert-manager.arn]
  oidc_fully_qualified_subjects = var.is_jx2 ? ["system:serviceaccount:${kubernetes_namespace.cert_manager[0].id}:cm-cert-manager"] : []
}

resource "kubernetes_service_account" "cm-cert-manager" {
  count                           = var.is_jx2 ? 1 : 0
  automount_service_account_token = true
  depends_on = [
    null_resource.kubeconfig
  ]
  metadata {
    name      = "cm-cert-manager"
    namespace = kubernetes_namespace.cert_manager[0].id
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_cert_manager.this_iam_role_arn
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
      secret
    ]
  }
}


// ----------------------------------------------------------------------------
// CM CAInjector IAM Role and Service Account (Reuses the Cert Manager IAM Policy)
// ----------------------------------------------------------------------------
module "iam_assumable_role_cm_cainjector" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.13.0"
  create_role                   = var.is_jx2
  role_name                     = substr("tf-${var.cluster_name}-sa-role-cm_cainjector-${local.generated_seed}", 0, 60)
  provider_url                  = local.oidc_provider_url
  role_policy_arns              = [aws_iam_policy.cert-manager.arn]
  oidc_fully_qualified_subjects = var.is_jx2 ? ["system:serviceaccount:${kubernetes_namespace.cert_manager[0].id}:cm-cainjector"] : []
}

resource "kubernetes_service_account" "cm-cainjector" {
  count                           = var.is_jx2 ? 1 : 0
  automount_service_account_token = true
  depends_on = [
    null_resource.kubeconfig
  ]
  metadata {
    name      = "cm-cainjector"
    namespace = kubernetes_namespace.cert_manager[0].id
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_cm_cainjector.this_iam_role_arn
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
      secret
    ]
  }
}

// ----------------------------------------------------------------------------
// ControllerBuild IAM Policy, IAM Role and Service Account
// ----------------------------------------------------------------------------
module "iam_assumable_role_controllerbuild" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.13.0"
  create_role                   = var.is_jx2
  role_name                     = substr("tf-${var.cluster_name}-sa-role-ctrlb-${local.generated_seed}", 0, 60)
  provider_url                  = local.oidc_provider_url
  role_policy_arns              = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]
  oidc_fully_qualified_subjects = var.is_jx2 ? ["system:serviceaccount:${kubernetes_namespace.jx[0].id}:jenkins-x-controllerbuild"] : []
}

resource "kubernetes_service_account" "jenkins-x-controllerbuild" {
  count                           = var.is_jx2 ? 1 : 0
  automount_service_account_token = true
  depends_on = [
    null_resource.kubeconfig
  ]
  metadata {
    name      = "jenkins-x-controllerbuild"
    namespace = kubernetes_namespace.jx[0].id
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_controllerbuild.this_iam_role_arn
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
      secret
    ]
  }
}
