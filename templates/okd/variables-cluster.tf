## Cluster type specific variables
## Copy to toplevel

variable "generic_pre_create" {
  description = "Scripts to execute before cluster is created."
  type        = list(string)
  default     = []
}

variable "generic_post_create" {
  description = "Scripts to execute after cluster is created."
  type        = list(string)
  default     = ["./generic-post-create.sh"]
}

variable "api_endpoint" {
  description = "Kubernetes API endpoint (Informative only)"
  type        = string
  default     = ""
}

variable "region" {
  description = "Cluster Region"
  type        = string
  default     = "unknown"
}

variable "cluster_type" {
  description = "Overrides cluster type"
  type        = string
  default     = "generic"
}

variable "get_kubeconfig_command" {
  description = "Command to create/update kubeconfig"
  type        = string
  default     = "true"
}

variable "install_on_okd" {
  description = "Apply all required patches to install on OKD (Openshift)"
  type        = bool
  default     = false
}

variable "kubeconfig_client_certificate_data" {
  description = "Kubeconfig Cluster Client Certificate Data"
  type        = string
  default     = null
}

variable "kubeconfig_client_key_data" {
  description = "Kubeconfig Cluster Client Certificate Key Data"
  type        = string
  default     = null
}

variable "kubeconfig_client_token" {
  description = "Kubeconfig Client Auth Token"
  type        = string
  default     = null
}

variable "kubeconfig_cluster_certificate_authority_data" {
  description = "Kubeconfig Cluster CA Certificate"
  type        = string
  default     = null
}
