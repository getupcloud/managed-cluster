variable "api_endpoint" {
  description = "Kubernetes API endpoint (Informative only)"
  type        = string
  default     = ""
}

variable "okd_modules" {
  description = "Configure OKD modules to install"
  type        = any
  default     = {}
}
