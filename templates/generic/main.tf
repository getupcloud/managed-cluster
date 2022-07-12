module "cluster" {
  source = "github.com/getupcloud/terraform-cluster-generic?ref=v1.17"

  # cluster basics
  customer_name   = var.customer
  cluster_name    = var.name
  cluster_sla     = var.sla
  use_kubeconfig  = var.use_kubeconfig
  pre_create      = var.pre_create
  post_create     = var.post_create
  generic_modules = var.generic_modules

  # monitoring and operations
  cronitor_enabled           = var.cronitor_enabled
  cronitor_pagerduty_key     = var.cronitor_pagerduty_key
  cronitor_notification_list = local.cronitor_notification_list
  opsgenie_enabled           = var.opsgenie_enabled
  teleport_auth_token        = var.teleport_auth_token

  # flux
  flux_git_repo           = var.flux_git_repo
  flux_wait               = var.flux_wait
  flux_version            = var.flux_version
  manifests_template_vars = local.manifests_template_vars

  # provider specific
  api_endpoint        = var.api_endpoint
  kubeconfig_filename = var.kubeconfig_filename
}
