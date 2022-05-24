variable "subscription_id" {
  description = "AKS Subscription ID"
  type        = string
}

variable "enable_kube_dashboard" {
  description = "Enable Kubernetes Dashboard."
  type        = bool
  default     = false
}

variable "rbac_aad_admin_group_names" {
  description = "Group name of groups with admin access."
  type        = list(string)
  default     = ["AKS-cluster-admins"]
}

## Node Pools ########################################################

variable "default_node_pool" {
  description = "AKS default node pool. Reserved for AKs stuff."
  default = {
    enable_auto_scaling          = true
    enable_host_encryption       = true
    enable_node_public_ip        = false
    max_count                    = 2
    max_pods                     = 110
    min_count                    = 1
    name                         = "system"
    node_labels                  = {}
    node_taints                  = []
    node_tags                    = {}
    only_critical_addons_enabled = true
    orchestrator_version         = null
    os_disk_size_gb              = 50
    os_disk_type                 = null
    os_sku                       = null
    type                         = "VirtualMachineScaleSets"
    vm_size                      = "Standard_D2s_v3"
    vnet_subnet_id               = null
    zones                        = []
  }
}

variable "node_pools" {
  description = "AKS node pools. Will merge with var.default_node_pool"
  default = {
    infra = {
      min_count   = 2
      max_count   = 2
      node_taints = ["dedicated=infra:NoSchedule"]
    }
    app = {
      min_count = 2
      max_count = 4
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
