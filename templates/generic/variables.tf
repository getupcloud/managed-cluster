variable "name" {
  description = "Cluster name"
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