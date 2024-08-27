module "kind" {
  source = "github.com/getupcloud/terraform-cluster-kind?ref=v3.0.0"

  # cluster basics
  customer_name  = var.customer_name
  cluster_name   = var.cluster_name
  cluster_sla    = var.cluster_sla
  use_kubeconfig = var.use_kubeconfig
  pre_create     = var.pre_create
  post_create    = var.post_create
  modules        = local.modules_result
  #dump_debug          = var.dump_debug

  # monitoring and operations
  cronitor_id                  = var.cronitor_id
  opsgenie_integration_api_key = var.opsgenie_integration_api_key
  teleport_auth_token        = var.teleport_auth_token

  # flux
  flux_git_repo           = var.flux_git_repo
  flux_wait               = var.flux_wait
  flux_version            = var.flux_version
  manifests_template_vars = local.manifests_template_vars
}
