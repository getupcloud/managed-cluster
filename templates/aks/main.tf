module "aks" {
  source = "github.com/getupcloud/terraform-cluster-aks?ref=v2.2.0"

  # cluster basics
  customer_name  = var.customer_name
  cluster_name   = var.cluster_name
  cluster_sla    = var.cluster_sla
  use_kubeconfig = var.use_kubeconfig
  pre_create     = var.pre_create
  post_create    = var.post_create
  modules        = var.modules

  # monitoring and operations
  cronitor_enabled            = var.cronitor_enabled
  cronitor_pagerduty_key      = var.cronitor_pagerduty_key
  cronitor_notification_lists = var.cronitor_notification_lists
  opsgenie_enabled            = var.opsgenie_enabled
  teleport_auth_token         = var.teleport_auth_token

  # flux
  flux_git_repo           = var.flux_git_repo
  flux_wait               = var.flux_wait
  flux_version            = var.flux_version
  manifests_template_vars = local.manifests_template_vars

  # provider specific
  admin_username       = var.admin_username
  azure_policy_enabled = var.azure_policy_enabled
  client_id            = var.client_id
  client_secret        = var.client_secret
  docker_bridge_cidr   = var.docker_bridge_cidr
  dns_service_ip       = local.dns_service_ip
  identity_type        = var.identity_type
  identity_ids         = var.identity_ids
  identity_name        = var.identity_name
  kubernetes_version   = var.kubernetes_version
  network_plugin       = var.network_policy == "azure" ? "azure" : var.network_plugin
  network_policy       = var.network_policy
  prefix               = var.prefix
  public_ssh_key       = var.public_ssh_key
  resource_group_name  = var.resource_group_name
  service_cidr         = var.service_cidr
  subscription_id      = var.subscription_id
  sku_tier             = var.sku_tier
  tags                 = var.tags
  tenant_id            = var.tenant_id
  outbound_type        = var.outbound_type

  # oidc & workload identity
  oidc_issuer_enabled       = var.oidc_issuer_enabled
  workload_identity_enabled = var.workload_identity_enabled

  private_cluster_enabled                           = var.private_cluster_enabled
  api_server_authorized_ip_ranges                   = var.api_server_authorized_ip_ranges
  private_dns_zone_enabled                          = var.private_dns_zone_enabled
  private_dns_zone_id                               = var.private_dns_zone_id
  private_dns_zone_name                             = var.private_dns_zone_name
  private_dns_zone_resource_group_name              = var.private_dns_zone_resource_group_name
  private_dns_zone_role_definition_name             = var.private_dns_zone_role_definition_name
  private_dns_zone_skip_service_principal_aad_check = var.private_dns_zone_skip_service_principal_aad_check
  private_dns_zone_subscription_id                  = var.private_dns_zone_subscription_id

  default_node_pool        = var.default_node_pool
  node_pools               = var.node_pools
  node_resource_group      = var.node_resource_group
  node_vnet_resource_group = var.node_vnet_resource_group
  node_subnet_name         = var.node_subnet_name
  node_vnet_name           = var.node_vnet_name

  enable_role_based_access_control = var.enable_role_based_access_control
  rbac_aad_managed                 = var.rbac_aad_managed
  rbac_aad_tenant_id               = var.rbac_aad_tenant_id
  # managed
  rbac_aad_admin_group_names      = var.rbac_aad_admin_group_names
  rbac_aad_admin_group_object_ids = var.rbac_aad_admin_group_object_ids
  # unmanaged
  rbac_aad_client_app_id     = var.rbac_aad_client_app_id
  rbac_aad_server_app_id     = var.rbac_aad_server_app_id
  rbac_aad_server_app_secret = var.rbac_aad_server_app_secret

  acr_name                             = var.acr_name
  acr_resource_group_name              = var.acr_resource_group_name
  acr_role_definition_name             = var.acr_role_definition_name
  acr_skip_service_principal_aad_check = var.acr_skip_service_principal_aad_check
  acr_subscription_id                  = var.acr_subscription_id

  key_vault_secrets_provider_enabled = var.key_vault_secrets_provider_enabled
  key_vault_secrets_provider         = var.key_vault_secrets_provider

  ingress_application_gateway_enabled     = var.ingress_application_gateway_enabled
  ingress_application_gateway_name        = var.ingress_application_gateway_name
  ingress_application_gateway_id          = var.ingress_application_gateway_id
  ingress_application_gateway_subnet_cidr = var.ingress_application_gateway_subnet_cidr
  ingress_application_gateway_subnet_id   = var.ingress_application_gateway_subnet_id

  log_analytics_workspace_enabled = var.log_analytics_workspace_enabled
  log_analytics_workspace_name    = var.log_analytics_workspace_name
  log_analytics_workspace_sku     = var.log_analytics_workspace_sku
  log_retention_in_days           = var.log_retention_in_days

  allowed_maintenance_windows     = var.allowed_maintenance_windows
  not_allowed_maintenance_windows = var.not_allowed_maintenance_windows
}
