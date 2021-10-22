module "cluster" {
  source = "github.com/getupcloud/terraform-cluster-generic?ref=main"

  name                   = var.name
  flux_git_repo          = var.flux_git_repo
  api_endpoint           = var.api_endpoint
  get_kubeconfig_command = var.get_kubeconfig_command
  kubeconfig_filename    = var.kubeconfig_filename
}
