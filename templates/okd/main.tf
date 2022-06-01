module "cluster" {
  source = "github.com/getupcloud/terraform-cluster-generic?ref=v1.7"

  api_endpoint            = var.api_endpoint
  cluster_name            = var.name
  cluster_sla             = var.sla
  cronitor_api_key        = var.cronitor_api_key
  cronitor_pagerduty_key  = var.cronitor_pagerduty_key
  customer_name           = var.customer
  flux_git_repo           = var.flux_git_repo
  flux_wait               = var.flux_wait
  flux_version            = var.flux_version
  kubeconfig_filename     = var.kubeconfig_filename
  manifests_template_vars = local.manifests_template_vars
  use_kubeconfig          = true
  install_on_okd          = true
}
