module "cluster" {
  source = "github.com/getupcloud/terraform-cluster-generic?ref=main"

  name                = var.name
  flux_git_repo       = var.flux_git_repo
  kubeconfig_filename = var.kubeconfig_filename
}
