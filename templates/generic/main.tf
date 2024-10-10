module "cluster" {
  source = "github.com/getupcloud/terraform-cluster-generic?ref=v2.3.5"

  # cluster basics
  customer_name    = var.customer_name
  cluster_name     = var.cluster_name
  cluster_sla      = var.cluster_sla
  cluster_type     = local.cluster_type
  cluster_provider = var.cluster_provider
  use_kubeconfig   = var.use_kubeconfig
  pre_create       = var.pre_create
  post_create      = var.post_create
  modules          = local.modules_result
  dump_debug       = var.dump_debug

  # monitoring and operations
  cronitor_id                  = var.cronitor_id
  opsgenie_integration_api_key = var.opsgenie_integration_api_key
  teleport_auth_token          = var.teleport_auth_token

  # flux
  flux_git_repo           = var.flux_git_repo
  flux_wait               = var.flux_wait
  flux_version            = var.flux_version
  flux_install_file       = var.flux_install_file
  flux_identity_file      = var.flux_identity_file
  flux_identity_pub_file  = var.flux_identity_pub_file
  manifests_template_vars = local.manifests_template_vars

  # provider specific
  api_endpoint        = var.api_endpoint
  kubeconfig_filename = var.kubeconfig_filename
}
