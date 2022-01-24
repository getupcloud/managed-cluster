module "gke" {
  source = "github.com/getupcloud/terraform-cluster-gke?ref=main"

  cluster_name               = var.name
  cluster_sla                = var.sla
  cronitor_api_key           = var.cronitor_api_key
  cronitor_pagerduty_key     = var.cronitor_pagerduty_key
  customer_name              = var.customer
  configure_ip_masq          = var.configure_ip_masq
  default_max_pods_per_node  = var.default_max_pods_per_node
  horizontal_pod_autoscaling = var.horizontal_pod_autoscaling
  http_load_balancing        = var.http_load_balancing
  ip_range_pods              = var.ip_range_pods
  ip_range_services          = var.ip_range_services
  manifests_template_vars    = local.manifests_template_vars
  network                    = var.network
  network_policy             = var.network_policy
  node_pools                 = var.node_pools
  node_pools_oauth_scopes    = var.node_pools_oauth_scopes
  node_pools_labels          = var.node_pools_labels
  node_pools_metadata        = var.node_pools_metadata
  node_pools_taints          = var.node_pools_taints
  node_pools_tags            = var.node_pools_tags
  project_id                 = var.project_id
  region                     = var.region
  subnetwork                 = var.subnetwork
  zones                      = var.zones
}
