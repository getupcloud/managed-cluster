module "gke" {
  source = "github.com/getupcloud/terraform-cluster-gke?ref=v1.22"

  # cluster basics
  customer_name  = var.customer
  cluster_name   = var.name
  cluster_sla    = var.sla
  use_kubeconfig = var.use_kubeconfig
  pre_create     = var.pre_create
  post_create    = var.post_create
  gke_modules    = var.gke_modules

  # monitoring and operations
  cronitor_enabled           = var.cronitor_enabled
  cronitor_pagerduty_key     = var.cronitor_pagerduty_key
  cronitor_notification_list = local.cronitor_notification_list
  opsgenie_enabled           = var.opsgenie_enabled
  teleport_auth_token        = var.teleport_auth_token

  # flux
  flux_git_repo           = var.flux_git_repo
  flux_version            = var.flux_version
  flux_wait               = var.flux_wait
  manifests_template_vars = local.manifests_template_vars

  # provider specific
  api_endpoint                = var.api_endpoint
  cluster_autoscaling         = var.cluster_autoscaling
  configure_ip_masq           = var.configure_ip_masq
  default_max_pods_per_node   = var.default_max_pods_per_node
  enable_private_endpoint     = var.enable_private_endpoint
  enable_private_nodes        = var.enable_private_nodes
  get_kubeconfig_command      = var.get_kubeconfig_command
  grant_registry_access       = var.grant_registry_access
  horizontal_pod_autoscaling  = var.horizontal_pod_autoscaling
  http_load_balancing         = var.http_load_balancing
  impersonate_service_account = var.impersonate_service_account
  initial_node_count          = var.initial_node_count
  ip_range_pods               = var.ip_range_pods
  ip_range_services           = var.ip_range_services
  kubeconfig_filename         = var.kubeconfig_filename
  kubernetes_version          = var.kubernetes_version
  logging_service             = var.logging_service
  maintenance_exclusions      = var.maintenance_exclusions
  maintenance_start_time      = var.maintenance_start_time
  manifests_path              = var.manifests_path
  master_authorized_networks  = var.master_authorized_networks
  master_ipv4_cidr_block      = var.master_ipv4_cidr_block
  network                     = var.network
  network_policy              = var.network_policy
  network_project_id          = var.network_project_id
  node_pools                  = var.node_pools
  node_pools_labels           = var.node_pools_labels
  node_pools_metadata         = var.node_pools_metadata
  node_pools_oauth_scopes     = var.node_pools_oauth_scopes
  node_pools_tags             = var.node_pools_tags
  node_pools_taints           = var.node_pools_taints
  project_id                  = var.project_id
  region                      = var.region
  regional                    = var.regional
  release_channel             = var.release_channel
  remove_default_node_pool    = var.remove_default_node_pool
  subnetwork                  = var.subnetwork
  zones                       = var.zones
}
