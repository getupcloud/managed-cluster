module "cluster" {
  source = "github.com/getupcloud/terraform-cluster-generic?ref=main"

  name                   = var.name
  flux_git_repo          = var.flux_git_repo
  kubeconfig_filename    = var.kubeconfig_filename
  cronitor_api_key       = var.cronitor_api_key
  cronitor_pagerduty_key = var.cronitor_pagerduty_key
}
