module "cluster" {
  source = "github.com/getupcloud/terraform-cluster-generic?ref=v2.0.0-alpha10"

  # cluster basics
  customer_name    = var.customer_name
  cluster_name     = var.cluster_name
  cluster_sla      = var.cluster_sla
  cluster_type     = local.cluster_type
  cluster_provider = var.cluster_provider
  use_kubeconfig   = var.use_kubeconfig
  pre_create       = var.pre_create
  post_create      = var.post_create
  modules          = var.modules
  dump_debug       = var.dump_debug

  # monitoring and operations
  cronitor_enabled            = var.cronitor_enabled
  cronitor_pagerduty_key      = var.cronitor_pagerduty_key
  cronitor_notification_lists = var.cronitor_notification_lists
  opsgenie_enabled            = var.opsgenie_enabled
  teleport_auth_token         = var.teleport_auth_token

  # flux
  flux_git_repo           = var.flux_git_repo
  flux_wait               = var.flux_wait
  flux_version            = var.flux_version
  manifests_template_vars = local.manifests_template_vars

  # provider specific
  api_endpoint        = var.api_endpoint
  generic_post_create = var.generic_post_create
  install_on_okd      = true
  kubeconfig_filename = var.kubeconfig_filename
}
