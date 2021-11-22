variable "kubeconfig_filename" {
  description = "Kubeconfig path"
  type        = string
  default     = "/cluster/.kube/config"
}

variable "api_endpoint" {
  description = "Kubernetes API endpoint (Informative only)"
  type        = string
  default     = ""
}
