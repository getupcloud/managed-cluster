module "doks" {
  source                = "github.com/getupcloud/terraform-cluster-doks?ref=main"
  name                  = var.name
  do_token              = var.
  region                = var.region
  aws_secret_access_key = var.aws_secret_access_key
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids
  node_groups           = var.node_groups
  node_groups_defaults  = var.node_groups_defaults
  flux_git_repo         = var.flux_git_repo
}
