variable "name" {
  description = "Cluster name"
  type        = string
}

variable "flux_git_repo" {
  description = "GitRepository URL"
  type        = string
  default     = ""
}

variable "api_endpoint" {
  description = "Kubernetes API endpoint"
  type        = string
  default     = ""
}

variable "kubeconfig_filename" {
  description = "Kubeconfig path"
  type        = string
  default     = "/cluster/.kube/config"
}

variable "get_kubeconfig_command" {
  description = "Command to create/update kubeconfig"
  type        = bool
  default     = "true"
}
