
#TEKTON BOT POLICY, ROLE AND SERVICE ACCOUNTS

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
  description = "EKS tekton-bot policy for cluster ${var.cluster_id}"
  policy      = data.aws_iam_policy_document.tekton-bot-policy.json
}


module "iam_assumable_role_tekton_bot" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "tf-${var.cluster_id}-iamserviceaccount-Role1-tekton-bot-${local.generated_seed}"
  provider_url                  = var.oidc_provider_url
  role_policy_arns              = [aws_iam_policy.tekton-bot.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.jenkins-x-namespace}:tekton-bot"]
}

resource "kubernetes_service_account" "tekton-bot" {
  automount_service_account_token = true
  depends_on = [
    kubernetes_namespace.jx
  ]
  metadata {
    name = "tekton-bot"
    namespace = local.jenkins-x-namespace
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

#EXTERNAL DNS POLICY, ROLE AND SERVICE ACCOUNTS

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
  description = "EKS external-dns policy for cluster ${var.cluster_id}"
  policy      = data.aws_iam_policy_document.external-dns-policy.json
}

module "iam_assumable_role_external_dns" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "tf-${var.cluster_id}-iamserviceaccount-Role-external_dns-${local.generated_seed}"
  provider_url                  = var.oidc_provider_url
  role_policy_arns              = [aws_iam_policy.external-dns.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.jenkins-x-namespace}:exdns-external-dns"]
}

resource "kubernetes_service_account" "exdns-external-dns" {
  automount_service_account_token = true
  depends_on = [
    kubernetes_namespace.jx
  ]
  metadata {
    name = "exdns-external-dns"
    namespace = local.jenkins-x-namespace
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


# CERT MANAGER POLICY, ROLE AND SERVICE ACCOUNT

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
  description = "EKS cert-manager policy for cluster ${var.cluster_id}"
  policy      = data.aws_iam_policy_document.cert-manager-policy.json
}

module "iam_assumable_role_cert_manager" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "tf-${var.cluster_id}-iamserviceaccount-Role-cert_manager-${local.generated_seed}"
  provider_url                  = var.oidc_provider_url
  role_policy_arns              = [aws_iam_policy.cert-manager.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.cert-manager-namespace}:cm-cert-manager"]
}

resource "kubernetes_service_account" "cm-cert-manager" {
  automount_service_account_token = true
  depends_on = [
    kubernetes_namespace.cert-manager
  ]
  metadata {
    name = "cm-cert-manager"
    namespace = local.cert-manager-namespace
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

module "iam_assumable_role_cm_cainjector" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "tf-${var.cluster_id}-iamserviceaccount-Role-cm_cainjector-${local.generated_seed}"
  provider_url                  = var.oidc_provider_url
  role_policy_arns              = [aws_iam_policy.cert-manager.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.cert-manager-namespace}:cm-cainjector"]
}

resource "kubernetes_service_account" "cm-cainjector" {
  automount_service_account_token = true
  depends_on = [
    kubernetes_namespace.cert-manager
  ]
  metadata {
    name = "cm-cainjector"
    namespace = local.cert-manager-namespace
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

# JENKINS X CONTROLLERBUILD SERVICE ACCOUNT

module "iam_assumable_role_controllerbuild" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "tf-${var.cluster_id}-iamserviceaccount-Role-ctrlb-${local.generated_seed}"
  provider_url                  = var.oidc_provider_url
  role_policy_arns              = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.jenkins-x-namespace}:jenkins-x-controllerbuild"]
}

resource "kubernetes_service_account" "jenkins-x-controllerbuild" {
  automount_service_account_token = true
  depends_on = [
    kubernetes_namespace.jx
  ]
  metadata {
    name = "jenkins-x-controllerbuild"
    namespace = local.jenkins-x-namespace
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

#JENKINS X JXUI

module "iam_assumable_role_jxui" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "tf-${var.cluster_id}-iamserviceaccount-Role-jxui-${local.generated_seed}"
  provider_url                  = var.oidc_provider_url
  role_policy_arns              = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.jenkins-x-namespace}:jxui"]
}

resource "kubernetes_service_account" "jxui" {
  automount_service_account_token = true
  depends_on = [
    kubernetes_namespace.jx
  ]
  metadata {
    name = "jxui"
    namespace = local.jenkins-x-namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_jxui.this_iam_role_arn
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
