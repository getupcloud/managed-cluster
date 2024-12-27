module "doks" {
  source = "github.com/getupcloud/terraform-cluster-doks?ref=v1.10.4"

  # cluster basics
  customer_name  = var.customer_name
  cluster_name   = var.cluster_name
  cluster_sla    = var.cluster_sla
  use_kubeconfig = var.use_kubeconfig
  pre_create     = var.pre_create
  post_create    = var.post_create
  doks_modules   = var.doks_modules

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
  do_token          = var.do_token
  node_pool         = var.node_pool
  node_pools        = var.node_pools
  region            = var.region
  spaces_access_id  = var.spaces_access_id
  spaces_buckets    = var.spaces_buckets
  spaces_secret_key = var.spaces_secret_key
  vpc_uuid          = var.vpc_uuid
}
