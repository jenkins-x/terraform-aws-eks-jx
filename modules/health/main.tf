module "jx-health" {
  count  = var.install_kuberhealthy ? 1 : 0
  source = "github.com/jenkins-x/terraform-jx-health?ref=main"
}
