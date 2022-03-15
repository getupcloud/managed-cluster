module "kind" {
  source = "github.com/getupcloud/terraform-cluster-kind?ref=v1.2"

  cluster_name            = var.name
  cluster_sla             = var.sla
  cronitor_api_key        = var.cronitor_api_key
  cronitor_pagerduty_key  = var.cronitor_pagerduty_key
  customer_name           = var.customer
  flux_git_repo           = var.flux_git_repo
  flux_wait               = var.flux_wait
  flux_version            = var.flux_version
  manifests_template_vars = local.manifests_template_vars
  use_kubeconfig          = var.use_kubeconfig
}
