variable "subscription_id" {
  description = "AKS Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "The resource group name to be imported"
  type        = string
}

variable "cluster_name" {
  description = "(Optional) The name for the AKS resources created in the specified Azure Resource Group. This variable overwrites the 'prefix' var (The 'prefix' var will still be applied to the dns_prefix if it is set)"
  type        = string
}

variable "cluster_log_analytics_workspace_name" {
  description = "(Optional) The name of the Analytics workspace"
  type        = string
  default     = null
}

variable "prefix" {
  description = "(Required) The prefix for the resources created in the specified Azure Resource Group"
  type        = string
}

variable "client_id" {
  description = "(Optional) The Client ID (appId) for the Service Principal used for the AKS deployment"
  type        = string
  default     = ""
}

variable "client_secret" {
  description = "(Optional) The Client Secret (password) for the Service Principal used for the AKS deployment"
  type        = string
  default     = ""
}

variable "admin_username" {
  default     = "azureuser"
  description = "The username of the local administrator to be created on the Kubernetes cluster"
  type        = string
}

variable "log_analytics_workspace_sku" {
  description = "The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "The retention period for the logs in days"
  type        = number
  default     = 30
}

variable "public_ssh_key" {
  description = "A custom ssh key to control access to the AKS cluster"
  type        = string
  default     = "/cluster/identity.pub"
}

variable "tags" {
  type        = map(string)
  description = "Any tags that should be present on the Virtual Network resources"
  default     = {}
}

variable "enable_log_analytics_workspace" {
  type        = bool
  description = "Enable the creation of azurerm_log_analytics_workspace and azurerm_log_analytics_solution or not"
  default     = true
}

variable "private_cluster_enabled" {
  description = "If true cluster API server will be exposed only on internal IP address and available only in cluster vnet."
  type        = bool
  default     = true
}

variable "enable_kube_dashboard" {
  description = "Enable Kubernetes Dashboard."
  type        = bool
  default     = false
}

variable "enable_http_application_routing" {
  description = "Enable HTTP Application Routing Addon (forces recreation)."
  type        = bool
  default     = false
}

variable "enable_azure_policy" {
  description = "Enable Azure Policy Addon."
  type        = bool
  default     = false
}

variable "sku_tier" {
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid"
  type        = string
  default     = "Free"
}

variable "enable_role_based_access_control" {
  description = "Enable Role Based Access Control."
  type        = bool
  default     = false
}

variable "rbac_aad_managed" {
  description = "Is the Azure Active Directory integration Managed, meaning that Azure will create/manage the Service Principal used for integration."
  type        = bool
  default     = false
}

variable "rbac_aad_admin_group_names" {
  description = "Group name of groups with admin access."
  type        = list(string)
  default     = ["AKS-cluster-admins"]
}

variable "rbac_aad_admin_group_object_ids" {
  description = "Object ID of groups with admin access."
  type        = list(string)
  default     = []
}

variable "rbac_aad_client_app_id" {
  description = "The Client ID of an Azure Active Directory Application."
  type        = string
  default     = null
}

variable "rbac_aad_server_app_id" {
  description = "The Server ID of an Azure Active Directory Application."
  type        = string
  default     = null
}

variable "rbac_aad_server_app_secret" {
  description = "The Server Secret of an Azure Active Directory Application."
  type        = string
  default     = null
}

variable "network_plugin" {
  description = "Network plugin to use for networking."
  type        = string
  default     = "azure"
}

variable "network_mode" {
  description = "Network plugin to use for networking."
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = " (Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico and azure. Changing this forces a new resource to be created."
  type        = string
  default     = "calico"
}

variable "net_profile_dns_service_ip" {
  description = "(Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). Changing this forces a new resource to be created."
  type        = string
  default     = "10.0.0.10"
}

variable "net_profile_docker_bridge_cidr" {
  description = "(Optional) IP address (in CIDR notation) used as the Docker bridge IP address on nodes. Changing this forces a new resource to be created."
  type        = string
  default     = "172.17.0.0/16"
}

variable "net_profile_outbound_type" {
  description = "(Optional) The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer."
  type        = string
  default     = "loadBalancer"
}

variable "net_profile_pod_cidr" {
  description = " (Optional) The CIDR to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet. Changing this forces a new resource to be created."
  type        = string
  default     = "192.168.0.0/16"
}

variable "net_profile_service_cidr" {
  description = "(Optional) The Network Range used by the Kubernetes service. Changing this forces a new resource to be created."
  type        = string
  default     = "10.0.0.0/16"
}

variable "kubernetes_version" {
  description = "Specify which Kubernetes release to use (nodes). The default used is the latest Kubernetes version available in the region"
  type        = string
  default     = null
}

variable "orchestrator_version" {
  description = "Specify which Kubernetes release to use for the orchestration layer (control plane). The default used is the latest Kubernetes version available in the region"
  type        = string
  default     = null
}


variable "enable_ingress_application_gateway" {
  description = "Whether to deploy the Application Gateway ingress controller to this Kubernetes Cluster?"
  type        = bool
  default     = false
}

variable "ingress_application_gateway_id" {
  description = "The ID of the Application Gateway to integrate with the ingress controller of this Kubernetes Cluster."
  type        = string
  default     = null
}

variable "ingress_application_gateway_name" {
  description = "The name of the Application Gateway to be used or created in the Nodepool Resource Group, which in turn will be integrated with the ingress controller of this Kubernetes Cluster."
  type        = string
  default     = null
}

variable "ingress_application_gateway_subnet_cidr" {
  description = "The subnet CIDR to be used to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster."
  type        = string
  default     = null
}

variable "ingress_application_gateway_subnet_id" {
  description = "The ID of the subnet on which to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster."
  type        = string
  default     = null
}
variable "identity_type" {
  description = "(Optional) The type of identity used for the managed cluster. Conflict with `client_id` and `client_secret`. Possible values are `SystemAssigned` and `UserAssigned`. If `UserAssigned` is set, a `user_assigned_identity_id` must be set as well."
  type        = string
  default     = "SystemAssigned"
}

variable "user_assigned_identity_id" {
  description = "(Optional) The ID of a user assigned identity."
  type        = string
  default     = null
}

variable "enable_host_encryption" {
  description = "Enable Host Encryption for default node pool. Encryption at host feature must be enabled on the subscription: https://docs.microsoft.com/azure/virtual-machines/linux/disks-enable-host-based-encryption-cli"
  type        = bool
  default     = false
}

variable "node_resource_group" {
  description = "The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster."
  type        = string
  default     = null
}


###################################################################

variable "default_node_pool" {
  description = "AKS default node pool. Reserved for AKs stuff."
  default = {
    agents_pool_name          = "system"
    agents_type               = "VirtualMachineScaleSets"
    enable_auto_scaling       = true
    agents_min_count          = 1
    agents_max_count          = 2
    agents_size               = "Standard_D2s_v3"
    agents_max_pods           = 110
    agents_labels             = {}
    agents_tags               = {}
    agents_availability_zones = []
    os_disk_size_gb           = 50
    enable_node_public_ip     = false
    enable_host_encryption    = true
    vnet_subnet_id            = null
  }
}

variable "node_pools" {
  description = "AKS node pools. Will merge with var.default_node_pool"
  default = {
    infra = {
      agents_min_count = 2
      agents_max_count = 2
      agents_taints    = ["dedicated=infra:NoSchedule"]
    }
    app = {
      agents_min_count = 2
      agents_max_count = 4
    }
  }
}

variable "azure_modules" {
  description = "Configure Azure modules to install"
  type        = any
  default = {
    velero : {
      enabled : true
    }
  }
}

## Private DNS Zone ##################################################

variable "private_dns_zone_enabled" {
  description = "Enabled user-defined Private DNS Zone"
  type        = bool
  default     = false
}

variable "private_dns_zone_name" {
  description = "Either the DNS-name of Private DNS Zone which should be delegated to this Cluster, 'System' to have AKS manage this or 'None'."
  type        = string
  default     = "System"
}

variable "private_dns_zone_subscription_id" {
  description = "Private DNS Zone Subscription ID"
  type        = string
  default     = ""
}

variable "private_dns_zone_resource_group_name" {
  description = "Private DNS Zone Resource Group name"
  type        = string
  default     = ""
}

variable "private_dns_zone_role_definition_name" {
  description = "Private DNS Zone Role Definition name"
  type        = string
  default     = "Private DNS Zone Contributor"
}

variable "private_dns_zone_skip_service_principal_aad_check" {
  description = "Skips the Azure Active Directory check which may fail due to replication lag."
  type        = bool
  default     = true
}

## ACR ###############################################################

variable "acr_name" {
  description = "ACR name for this cluster"
  type        = string
  default     = ""
}

variable "acr_subscription_id" {
  description = "ACR Subscription ID"
  type        = string
  default     = ""
}

variable "acr_resource_group_name" {
  description = "ACR Resource Group name"
  type        = string
  default     = ""
}

variable "acr_role_definition_name" {
  description = "ACR Role Definition name"
  type        = string
  default     = "AcrPull"
}

variable "acr_skip_service_principal_aad_check" {
  description = "Skips the Azure Active Directory check which may fail due to replication lag."
  type        = bool
  default     = true
}

## Key Vault Secrets Provider ########################################

variable "key_vault_secrets_provider_enabled" {
  description = "Enables Key Vault Secret Provider"
  type        = bool
  default     = false
}

variable "key_vault_secrets_provider" {
  description = "Config for Key Vault Secret Provider"
  type = object({
    secret_rotation_enabled  = bool
    secret_rotation_interval = string
  })
  default = {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }
}

## Maintenance Windows ###############################################

variable "allowed_maintenance_windows" {
  description = "List of allowed Maintenance Windows for AKS"
  type = list(object({
    day   = string
    hours = list(number)
  }))
  default = []

  # Example: [
  #   {
  #     day   = "Saturday"
  #     hours = [23]
  #   },
  #   {
  #     day   = "Sunday"
  #     hours = [0, 1, 2, 3, 4]
  #   }
  # ]
}

variable "not_allowed_maintenance_windows" {
  description = "List of not allowed Maintenance Windows for AKS"
  type = list(object({
    start = string
    end   = string
  }))
  default = []

  # Example: [
  #   {
  #     start = "2022-01-01T00:00:00Z"
  #     end = "2023-01-01T00:00:00Z"
  #   }
  # ]
}

variable "private_dns_zone_id" {
  description = "Either the ID of Private DNS Zone which should be delegated to this Cluster, System to have AKS manage this or None."
  type        = string
  default     = null
}
