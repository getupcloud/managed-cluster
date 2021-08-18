## Common variables

variable "name" {
  description = "Cluster name"
  type        = string
}

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
    min_nodes  = 2
    max_nodes  = 2
    node_count = 2
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
      tags  = []
      taints = []
    }
  ]
}

variable "flux_git_repo" {
  description = "GitRepository URL"
  type        = string
  default     = ""
}
