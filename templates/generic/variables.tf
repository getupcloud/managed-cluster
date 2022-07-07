variable "api_endpoint" {
  description = "Kubernetes API endpoint (Informative only)"
  type        = string
  default     = ""
}

variable "generic_modules" {
  description = "Configure modules to install"
  type        = any
  default     = {}
}
