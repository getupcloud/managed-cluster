module "doks" {
  source            = "github.com/getupcloud/terraform-cluster-doks?ref=main"
  name              = var.name
  do_token          = var.do_token
  spaces_access_id  = var.spaces_access_id
  spaces_secret_key = var.spaces_secret_key
  spaces_buckets    = var.spaces_buckets
  region            = var.region
  vpc_uuid          = var.vpc_uuid
  node_pool         = var.node_pool
  node_pools        = var.node_pools
  flux_git_repo     = var.flux_git_repo
}
