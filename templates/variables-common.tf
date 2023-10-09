## Common variables to all providers
## Copy to cluster repo

variable "cronitor_enabled" {
  description = "Creates and enables Cronitor monitor."
  type        = bool
  default     = false
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

variable "cronitor_pagerduty_key" {
  description = "Cronitor PagerDuty key"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "cluster_sla" {
  description = "Cluster SLA"
  type        = string
  default     = "none"

  validation {
    condition     = contains(["high", "low", "none"], var.cluster_sla)
    error_message = "The Cluster SLA is invalid."
  }
}

variable "customer_name" {
  description = "Customer name"
  type        = string
}

variable "cluster_provider" {
  description = "Cluster provider name"
  type        = string
  default     = "none"

  validation {
    condition     = contains(["aws", "azure", "do", "gcp", "none", "oci"], var.cluster_provider)
    error_message = "The Cluster Provider is invalid."
  }
}

variable "flux_git_repo" {
  description = "GitRepository URL"
  type        = string
  default     = ""
}

variable "flux_version" {
  description = "Flux version to install"
  type        = string
  default     = "v0.41.2"
}

variable "flux_install_file" {
  description = "Use this file to install flux instead default files. Using this options will ignore var.flux_version"
  type        = string
  default     = ""
}

variable "flux_wait" {
  description = "Wait for all manifests to apply"
  type        = bool
  default     = true
}

variable "kubeconfig_filename" {
  description = "Kubeconfig path"
  default     = "~/.kube/config"
  type        = string
}

variable "manifests_path" {
  description = "Manifests dir inside GitRepository"
  type        = string
  default     = ""
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

variable "modules" {
  description = "Configure modules to install"
  type        = any
  default     = {}
}

variable "opsgenie_enabled" {
  description = "Creates and enables Opsgenie integration."
  type        = bool
  default     = false
}

variable "opsgenie_team_name" {
  description = "Opsgenie Owner team name of the integration."
  type        = string
  default     = "Operations"
}

variable "post_create" {
  description = "Scripts to execute after cluster is created."
  type        = list(string)
  default     = []
}

variable "pre_create" {
  description = "Scripts to execute before cluster is created."
  type        = list(string)
  default     = []
}

variable "teleport_auth_token" {
  description = "Teleport Agent Auth Token"
  type        = string
  default     = ""
}

variable "use_kubeconfig" {
  description = "Should kubernetes/kubectl providers use local kubeconfig or credentials from cloud module"
  type        = bool
  default     = false
}

variable "dump_debug" {
  description = "Dump debug info to files .debug-*.json"
  type        = bool
  default     = false
}
