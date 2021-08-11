module "doks" {
  source                = "github.com/getupcloud/terraform-cluster-doks?ref=main"
  name                  = var.name
  do_token              = var.do_token
  region                = var.region
  vpc_uuid              = var.vpc_uuid
  node_pool             = var.node_pool
  node_pools            = var.node_pools
  flux_git_repo         = var.flux_git_repo
}
