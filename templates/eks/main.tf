module "eks" {
  source                = "github.com/getupcloud/terraform-cluster-eks?ref=main"
  name                  = var.name
  aws_access_key_id     = var.aws_access_key_id
  region                = var.region
  aws_secret_access_key = var.aws_secret_access_key
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids
  node_groups           = var.node_groups
  node_groups_defaults  = var.node_groups_defaults
  flux_git_repo         = var.flux_git_repo
  s3_buckets            = var.s3_buckets
  auth_iam_users        = var.auth_iam_users
  auth_iam_roles        = var.auth_iam_roles
  tags                  = var.tags
}
