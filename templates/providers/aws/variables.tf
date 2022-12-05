variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "customer_name" {
  description = "Customer name"
  type        = string
}

variable "modules" {
  description = "Configure AWS modules to install"
  type        = any
  default     = {}
}

variable "modules_defaults" {
  description = "Default AWS modules to install"
  type = object({
    cert-manager = object({
      enabled                   = bool
      cluster_oidc_issuer_url   = string
      service_account_namespace = string
      service_account_name      = string
      tags                      = map(string)
      hosted_zone_ids           = list(string)
    })
    velero = object({
      enabled                   = bool
      cluster_oidc_issuer_url   = string
      service_account_namespace = string
      service_account_name      = string
      tags                      = map(string)
      bucket_name               = string
    })
  })

  default = {
    cert-manager = {
      enabled                   = false
      cluster_oidc_issuer_url   = ""
      service_account_namespace = "cert-manager"
      service_account_name      = "cert-manger"
      tags                      = {}
      hosted_zone_ids           = []
    }
    velero = {
      enabled                   = false
      cluster_oidc_issuer_url   = ""
      service_account_namespace = "velero"
      service_account_name      = "velero"
      tags                      = {}
      bucket_name               = ""
    }
  }
}

locals {
  modules = {
    cert-manager = {
      enabled                   = try(var.modules.cert-manager.enabled, var.modules_defaults.cert-manager.enabled)
      cluster_oidc_issuer_url   = try(var.modules.cert-manager.cluster_oidc_issuer_url, var.modules_defaults.cert-manager.cluster_oidc_issuer_url)
      service_account_namespace = try(var.modules.cert-manager.service_account_namespace, var.modules_defaults.cert-manager.service_account_namespace)
      service_account_name      = try(var.modules.cert-manager.service_account_name, var.modules_defaults.cert-manager.service_account_name)
      tags                      = try(var.modules.cert-manager.tags, var.modules_defaults.cert-manager.tags)
      hosted_zone_ids           = try(var.modules.cert-manager.hosted_zone_ids, var.modules_defaults.cert-manager.hosted_zone_ids)
    }
    velero = {
      enabled                   = try(var.modules.velero.enabled, var.modules_defaults.velero.enabled)
      cluster_oidc_issuer_url   = try(var.modules.velero.cluster_oidc_issuer_url, var.modules_defaults.velero.cluster_oidc_issuer_url)
      service_account_namespace = try(var.modules.velero.service_account_namespace, var.modules_defaults.velero.service_account_namespace)
      service_account_name      = try(var.modules.velero.service_account_name, var.modules_defaults.velero.service_account_name)
      tags                      = try(var.modules.velero.tags, var.modules_defaults.velero.tags)
      bucket_name               = try(var.modules.velero.bucket_name, var.modules_defaults.velero.bucket_name)
    }
  }
}
