module "cluster" {
  source = "github.com/getupcloud/terraform-cluster-kubespray?ref=main"

  name                   = var.name
  costumer_name          = var.costumer_name
  flux_git_repo          = var.flux_git_repo
  kubeconfig_filename    = var.kubeconfig_filename
  kubespray_git_ref      = var.kubespray_git_ref
  cronitor_api_key       = var.cronitor_api_key
  cronitor_pagerduty_key = var.cronitor_pagerduty_key

  masters         = var.masters
  workers         = var.workers
  ssh_user        = var.ssh_user
  ssh_private_key = var.ssh_private_key
}
