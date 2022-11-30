module "eks" {
  source = "github.com/getupcloud/terraform-cluster-eks?ref=v2.0.0-alpha35"

  # cluster basics
  customer_name       = var.customer_name
  cluster_name        = var.cluster_name
  cluster_sla         = var.cluster_sla
  use_kubeconfig      = var.use_kubeconfig
  kubeconfig_filename = local.kubeconfig_filename
  kubernetes_version  = var.kubernetes_version
  pre_create          = var.pre_create
  post_create         = var.post_create
  modules             = local.modules_result
  dump_debug          = var.dump_debug

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
  account_id                    = var.account_id
  auth_iam_roles                = var.auth_iam_roles
  auth_iam_users                = var.auth_iam_users
  auth_map_roles                = var.auth_map_roles
  aws_access_key_id             = var.aws_access_key_id
  aws_secret_access_key         = var.aws_secret_access_key
  eks_addons                    = var.eks_addons
  eks_pre_create                = var.eks_pre_create
  eks_post_create               = var.eks_post_create
  endpoint_public_access_cidrs  = var.endpoint_public_access_cidrs
  endpoint_private_access_cidrs = var.endpoint_private_access_cidrs
  node_groups_defaults          = var.node_groups_defaults
  node_groups                   = var.node_groups
  region                        = var.region
  subnet_ids                    = var.subnet_ids
  tags                          = var.tags
  cluster_tags                  = var.cluster_tags
  vpc_id                        = var.vpc_id
}
