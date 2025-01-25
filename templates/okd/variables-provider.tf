## Provider-specific variables
## Copy to toplevel

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "cluster_monitoring_config" {
  description = "Configure cluster monitoring"
  type = object({
    enabled                       = optional(bool, false)
    enable_user_workload          = optional(bool, false)
    prometheus_k8s_requests_cpu   = optional(string, "1")
    prometheus_k8s_requests_mem   = optional(string, "4Gi")
    prometheus_k8s_limits_cpu     = optional(string, "2")
    prometheus_k8s_limits_mem     = optional(string, "12Gi")
    prometheus_k8s_retention      = optional(string, "15d")
    prometheus_k8s_retention_size = optional(string, "100GiB")
    prometheus_k8s_log_level      = optional(string, "info")
  })
  default = {}
}

variable "user_workload_monitoring_config" {
  description = "Configure user workload monitoring"
  type = object({
    enabled = optional(bool, false)
    //    prometheus_requests_cpu   = optional(string, "1")
    //    prometheus_requests_mem   = optional(string, "4Gi")
    //    prometheus_limits_cpu     = optional(string, "2")
    //    prometheus_limits_cmem    = optional(string, "12Gi")
    prometheus_retention                    = optional(string, "15d")
    prometheus_retention_size               = optional(string, "100GiB")
    alertmanager_enabled                    = optional(bool, false)
    alertmanager_enable_alertmanager_config = optional(bool, false)
    alertmanager_log_level                  = optional(string, "info")
  })
  default = {}
}
