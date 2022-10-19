## Common variables

variable "name" {
  description = "Cluster name"
  type        = string
}

variable "customer" {
  description = "Customer name"
  type        = string
}

variable "sla" {
  description = "Cluster SLA"
  type        = string
  default     = "none"

  validation {
    condition     = contains(["high", "low", "none"], var.sla)
    error_message = "The Cluster SLA is invalid."
  }
}

variable "manifests_template_vars" {
  description = "Template vars for use by cluster manifests"
  type        = any
  default = {
    alertmanager_pagerduty_service_key : ""
    alertmanager_slack_channel : ""
    alertmanager_slack_api_url : ""
    alertmanager_msteams_url : ""
    alertmanager_default_receiver : "blackhole" ## opsgenie, pagerduty, slack, blackhole
    alertmanager_ignore_alerts : ["CPUThrottlingHigh"]
    alertmanager_ignore_namespaces : [
      "cert-manager", "getup", "ingress-.*", "logging", "monitoring", "velero",
      ".*-controllers", ".*-ingress", ".*istio.*", ".*-operator", ".*-provisioner", ".*-system"
    ]
  }
}

variable "flux_git_repo" {
  description = "GitRepository URL"
  type        = string
  default     = ""
}

variable "flux_wait" {
  description = "Wait for all manifests to apply"
  type        = bool
  default     = true
}

variable "flux_version" {
  description = "Flux version to install"
  type        = string
  default     = "v0.35.0"
}

variable "manifests_path" {
  description = "Manifests dir inside GitRepository"
  type        = string
  default     = ""
}

variable "cronitor_enabled" {
  description = "Creates and enables Cronitor monitor."
  type        = bool
  default     = false
}

variable "cronitor_api_key" {
  description = "Cronitor API key"
  type        = string
  default     = ""
}

variable "cronitor_pagerduty_key" {
  description = "Cronitor PagerDuty key"
  type        = string
  default     = ""
}

variable "cronitor_notification_lists" {
  description = "Cronitor Notification lists by SLA"
  type        = any
  default = {
    high : ["default", "opsgenie-high-sla"]
    low : ["default", "opsgenie-low-sla"]
    none : []
  }
}

variable "opsgenie_enabled" {
  description = "Creates and enables Opsgenie integration."
  type        = bool
  default     = false
}

variable "opsgenie_api_key" {
  description = "Opsgenie API key to create prometheus integration"
  type        = string
  default     = ""
}

variable "use_kubeconfig" {
  description = "Should kubernetes/kubectl providers use local kubeconfig or credentials from cloud module"
  type        = bool
  default     = false
}

variable "kubeconfig_filename" {
  description = "Kubeconfig path"
  type        = string
  default     = "/cluster/.kube/config"
}

variable "teleport_auth_token" {
  description = "Teleport Agent Auth Token"
  type        = string
  default     = ""
}

variable "pre_create" {
  description = "Scripts to execute before cluster is created."
  type        = list(string)
  default     = []
}

variable "post_create" {
  description = "Scripts to execute after cluster is created."
  type        = list(string)
  default     = []
}

variable "modules_defaults" {
  description = "Configure modules to install (defaults)"
  type = object({
    linkerd = object({ enabled = bool })
    trivy = object({ enabled = bool })
  })

  default = {
    linkerd = {
      enabled = false
    }
    trivy = {
      enabled = false
    }
  }
}
