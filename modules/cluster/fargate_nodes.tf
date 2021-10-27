resource "aws_security_group_rule" "fargate_workers" {
  count             = var.fargate_nodes_for_jx_pipelines ? 1 : 0
  description       = "Allow fargate nodes all ingress from the NAT."
  protocol          = "-1"
  security_group_id = module.eks.worker_security_group_id
  cidr_blocks       = var.private_subnets
  from_port         = 0
  to_port           = 0
  type              = "ingress"
}

############################################################################
#                       Fargate logging
#   Set that to avoid Warnings on Fargate Kubernetes PODs
#   For more details look at:
#   https://docs.aws.amazon.com/eks/latest/userguide/fargate-logging.html
############################################################################

resource "kubernetes_namespace" "aws-observability" {
  count = var.fargate_nodes_for_jx_pipelines ? 1 : 0

  metadata {
    name = "aws-observability"

    labels = {
      aws-observability = false
    }
  }

  depends_on = [
    module.eks
  ]
}

resource "kubernetes_config_map" "aws-logging" {
  count = var.fargate_nodes_for_jx_pipelines ? 1 : 0

  metadata {
    name      = "aws-logging"
    namespace = "aws-observability"
  }

  data = {
    "output.conf"  = <<EOT
[OUTPUT]
    Name cloudwatch_logs
    Match   *
    region ${var.region}
    log_group_name fluent-bit-cloudwatch
    log_stream_prefix from-fluent-bit-
    auto_create_group true
EOT
    "parsers.conf" = <<EOT
[PARSER]
    Name crio
    Format Regex
    Regex ^(?<time>[^ ]+) (?<stream>stdout|stderr) (?<logtag>P|F) (?<log>.*)$
    Time_Key    time
    Time_Format %Y-%m-%dT%H:%M:%S.%L%z
EOT
    "filters.conf" = <<EOT
[FILTER]
    Name parser
    Match *
    Key_name log
    Parser crio
    Reserve_Data On
    Preserve_Key On
EOT
  }

  depends_on = [
    kubernetes_namespace.aws-observability
  ]
}