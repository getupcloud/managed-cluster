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
}

variable "manifests_template_vars" {
  description = "Template vars for use by cluster manifests"
  type        = any
  default = {
    alertmanager_pagerduty_service_key : ""
    alertmanager_opsgenie_api_key : ""
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
  default     = "v0.15.3"
}

variable "manifests_path" {
  description = "Manifests dir inside GitRepository"
  type        = string
  default     = ""
}

variable "cronitor_api_key" {
  description = "Cronitor API key. Leave empty to destroy"
  type        = string
  default     = ""
}

variable "cronitor_pagerduty_key" {
  description = "Cronitor PagerDuty key"
  type        = string
  default     = ""
}

variable "kubeconfig_filename" {
  description = "Kubeconfig path"
  type        = string
  default     = "/cluster/.kube/config"
}

variable "teleport_auth_key" {
  description = "Teleport Agent Auth Key"
  type        = string
  default     = ""
}
