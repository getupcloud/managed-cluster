module "kind" {
  source = "github.com/getupcloud/terraform-cluster-kind?ref=v1.5"

  cluster_name            = var.name
  cluster_sla             = var.sla
  cronitor_api_key        = var.cronitor_api_key
  cronitor_pagerduty_key  = var.cronitor_pagerduty_key
  customer_name           = var.customer
  flux_git_repo           = var.flux_git_repo
  flux_wait               = var.flux_wait
  flux_version            = var.flux_version
  manifests_template_vars = local.manifests_template_vars
  pre_create              = var.pre_create
  post_create             = var.post_create
  use_kubeconfig          = var.use_kubeconfig
}
