## Common variables

variable "do_token" {
  description = "Digital Ocean Token"
  type        = string
  default     = null
}

variable "region" {
  description = "Region where to create cluster"
  type        = string
  default     = null
}

variable "spaces_access_id" {
  description = "Spaces Access Key ID for Backups"
  type        = string
  default     = null
}

variable "spaces_secret_key" {
  description = "Spaces Access Key ID for Backups"
  type        = string
  default     = null
}

variable "spaces_buckets" {
  description = "List of Space Buckets (See spaces.tf for defaults)"
  type        = any
  default     = []

  # See spaces.tf for defaults
  # Example:
  # [
  #   {
  #     name: "mybucket",
  #     region: "nyc3",
  #     acl: "public",
  #     force_destroy: true
  #   },
  #   {
  #     name_prefix: "velero",
  #     region: "nyc3",
  #     acl: "private",
  #     force_destroy: false
  #   }
  # ]
}

variable "vpc_uuid" {
  description = "VPC UUID where to create cluster"
  type        = string
}

variable "node_pool" {
  description = "Default node pool config"
  type        = any
  default = {
    name       = "infra"
    size       = "s-4vcpu-8gb"
    min_nodes  = 1
    max_nodes  = 2
    node_count = 1
    auto_scale = true
    labels = {
      role = "infra"
    }
    taints = [{
      key    = "dedicated"
      value  = "infra"
      effect = "NoSchedule"
    }]
    tags = []
  }

  validation {
    condition     = length(var.node_pool.size) > 0
    error_message = "Missing node_pool.size. Ex: \"s-4vcpu-8gb\"."
  }
}

variable "node_pools" {
  description = "List of node pools"
  type        = any
  default = [
    {
      name       = "app"
      size       = "s-4vcpu-8gb"
      min_nodes  = 2
      max_nodes  = 4
      node_count = 2
      auto_scale = true
      labels = {
        role = "app"
      }
      tags   = []
      taints = []
    }
  ]

  validation {
    condition     = alltrue([for np in var.node_pools : length(np.size) > 0])
    error_message = "Missing one or more node_pools[].size. Ex: \"s-4vcpu-8gb\"."
  }
}
