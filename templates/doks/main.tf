module "doks" {
  source = "github.com/getupcloud/terraform-cluster-doks?ref=v1.8"

  # cluster basics
  customer_name  = var.customer_name
  cluster_name   = var.cluster_name
  cluster_sla    = var.cluster_sla
  use_kubeconfig = var.use_kubeconfig
  pre_create     = var.pre_create
  post_create    = var.post_create
  doks_modules   = var.doks_modules

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
  do_token          = var.do_token
  node_pool         = var.node_pool
  node_pools        = var.node_pools
  region            = var.region
  spaces_access_id  = var.spaces_access_id
  spaces_buckets    = var.spaces_buckets
  spaces_secret_key = var.spaces_secret_key
  vpc_uuid          = var.vpc_uuid
}
