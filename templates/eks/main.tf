module "eks" {
  source = "github.com/getupcloud/terraform-cluster-eks?ref=main"

  auth_iam_roles               = var.auth_iam_roles
  auth_iam_users               = var.auth_iam_users
  aws_access_key_id            = var.aws_access_key_id
  aws_modules                  = var.aws_modules
  aws_secret_access_key        = var.aws_secret_access_key
  cronitor_api_key             = var.cronitor_api_key
  cronitor_pagerduty_key       = var.cronitor_pagerduty_key
  customer                     = var.customer
  eks_addons                   = var.eks_addons
  endpoint_public_access_cidrs = var.endpoint_public_access_cidrs
  flux_git_repo                = var.flux_git_repo
  flux_wait                    = var.flux_wait
  name                         = var.name
  node_groups_defaults         = var.node_groups_defaults
  node_groups                  = var.node_groups
  region                       = var.region
  subnet_ids                   = var.subnet_ids
  tags                         = var.tags
  vpc_id                       = var.vpc_id
}
