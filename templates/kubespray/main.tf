module "cluster" {
  source = "github.com/getupcloud/terraform-cluster-kubespray?ref=main"

  name                = var.name
  kubespray_git_ref   = var.kubespray_git_ref
  flux_git_repo       = var.flux_git_repo
  kubeconfig_filename = var.kubeconfig_filename
}
