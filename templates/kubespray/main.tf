module "cluster" {
  source = "github.com/getupcloud/terraform-cluster-kubespray?ref=v4.0.0-beta5"

  # cluster basics
  customer_name      = var.customer_name
  cluster_name       = var.cluster_name
  cluster_sla        = var.cluster_sla
  cluster_provider   = var.cluster_provider
  kubernetes_version = var.kubernetes_version
  use_kubeconfig     = var.use_kubeconfig
  pre_create         = var.pre_create
  post_create        = var.post_create
  modules            = local.modules_result
  dump_debug         = var.dump_debug

  # monitoring and operations
  cronitor_id                  = var.cronitor_id
  opsgenie_integration_api_key = var.opsgenie_integration_api_key
  teleport_auth_token          = var.teleport_auth_token

  # flux
  flux_git_repo           = var.flux_git_repo
  flux_wait               = var.flux_wait
  flux_version            = var.flux_version
  manifests_template_vars = local.manifests_template_vars

  # provider specific
  api_endpoint               = var.api_endpoint
  app_nodes                  = var.app_nodes
  default_app_node_labels    = var.default_app_node_labels
  default_app_node_taints    = var.default_app_node_taints
  default_infra_node_labels  = var.default_infra_node_labels
  default_infra_node_taints  = var.default_infra_node_taints
  default_master_node_labels = var.default_master_node_labels
  default_master_node_taints = var.default_master_node_taints
  deploy_components          = var.deploy_components
  etc_hosts                  = var.etc_hosts
  infra_nodes                = var.infra_nodes
  install_packages           = var.install_packages
  kubeconfig_filename        = var.kubeconfig_filename
  kubespray_git_ref          = var.kubespray_git_ref
  master_nodes               = var.master_nodes
  region                     = var.region
  ssh_private_key            = var.ssh_private_key
  ssh_user                   = var.ssh_user
  ssh_password               = var.ssh_password
  systemctl_enable           = var.systemctl_enable
  systemctl_disable          = var.systemctl_disable
  uninstall_packages         = var.uninstall_packages
}
