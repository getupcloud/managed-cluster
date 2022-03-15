module "doks" {
  source = "github.com/getupcloud/terraform-cluster-doks?ref=v1.2"

  cronitor_api_key        = var.cronitor_api_key
  cronitor_pagerduty_key  = var.cronitor_pagerduty_key
  cluster_name            = var.name
  cluster_sla             = var.sla
  customer_name           = var.customer
  do_token                = var.do_token
  flux_git_repo           = var.flux_git_repo
  flux_wait               = var.flux_wait
  flux_version            = var.flux_version
  manifests_template_vars = local.manifests_template_vars
  node_pool               = var.node_pool
  node_pools              = var.node_pools
  region                  = var.region
  spaces_access_id        = var.spaces_access_id
  spaces_buckets          = var.spaces_buckets
  spaces_secret_key       = var.spaces_secret_key
  use_kubeconfig          = var.use_kubeconfig
  vpc_uuid                = var.vpc_uuid
}
