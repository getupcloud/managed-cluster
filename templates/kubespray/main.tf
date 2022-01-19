module "cluster" {
  source = "github.com/getupcloud/terraform-cluster-kubespray?ref=main"

  name                   = var.name
  customer               = var.customer
  flux_git_repo          = var.flux_git_repo
  kubeconfig_filename    = var.kubeconfig_filename
  kubespray_git_ref      = var.kubespray_git_ref
  cronitor_api_key       = var.cronitor_api_key
  cronitor_pagerduty_key = var.cronitor_pagerduty_key

  master_nodes      = var.master_nodes
  infra_nodes       = var.infra_nodes
  app_nodes         = var.app_nodes
  ssh_user          = var.ssh_user
  ssh_private_key   = var.ssh_private_key
  etc_hosts         = var.etc_hosts
  deploy_components = var.deploy_components
}
