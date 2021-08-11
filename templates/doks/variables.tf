## Common variables

variable "name" {
  description = "Cluster name"
  type        = string
}

variable "do_token" {
  description = "AWS Access Key ID"
  type        = string
  default     = null
}

variable "region" {
  description = "Region where to create cluster"
  type        = string
  default     = null
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
    node_count = 2
    auto_scale = false
    min_nodes  = 2
    max_nodes  = 2
    labels = {
      role = "infra"
    }
    taint = {
      key    = "dedicated"
      value  = "infra"
      effect = "NoSchedule"
    }
    tags = []
  }
}

variable "node_pools" {
  description = "List of node pools"
  type        = any
  default = [
    {
      name       = "app"
      size       = "s-4vcpu-8gb"
      node_count = 2
      auto_scale = true
      min_nodes  = 2
      max_nodes  = 4
      labels = {
        role = "app"
      }
      tags  = []
      taint = {}
    }
  ]
}

variable "flux_git_repo" {
  description = "GitRepository URL"
  type        = string
  default     = ""
}
