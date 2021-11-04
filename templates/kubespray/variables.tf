variable "name" {
  description = "Cluster name"
  type        = string
}

variable "customer_name" {
  description = "Customer name (Informative only)"
  type        = string
}

variable "flux_git_repo" {
  description = "GitRepository URL"
  type        = string
  default     = ""
}

variable "kubeconfig_filename" {
  description = "Kubeconfig path"
  type        = string
  default     = "/cluster/.kube/config"
}

variable "kubespray_git_ref" {
  description = "Kubespray ref name"
  type        = string
  default     = "remotes/origin/release-2.17"
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
