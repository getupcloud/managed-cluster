variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "customer_name" {
  description = "Customer name"
  type        = string
}

variable "modules" {
  description = "Configure AWS modules to install"
  type        = any
  default     = {}
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = ""
}
