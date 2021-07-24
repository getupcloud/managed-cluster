module "kind" {
  source = "github.com/getupcloud/terraform-cluster-kind?ref=main"

  name           = var.name
  flux_git_repo  = var.flux_git_repo
}
