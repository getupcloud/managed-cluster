variable "do_token" {
  description = "DigitalOcean API Token"
  type        = string
}

variable "region" {
  description = "Region where to create cluster"
  type        = string
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

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.21.2-do.2"
}

variable "auto_upgrade" {
  description = "Should the cluster will be automatically upgraded to new patch releases during its maintenance window"
  type        = bool
  default     = false
}

variable "surge_upgrade" {
  description = "Should upgrades bringing up new nodes before destroying the outdated nodes"
  type = bool
  default     = true
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
    tags       = []

    labels = {
      role = "infra"
    }

    ## Format is list(taint): [{key:XXX, value: XXX, effect:XXX},...]
    taints = [{
      key    = "dedicated"
      value  = "infra"
      effect = "NoSchedule"
    }]
  }
}

variable "node_pools" {
  description = "List of node pools"
  type        = list(any)
  default = [
    {
      name       = "app"
      size       = "s-4vcpu-8gb"
      node_count = 2
      auto_scale = true
      min_nodes  = 2
      max_nodes  = 4
      tags       = []

      labels = {
        role = "app"
      }

      ## Format is list(taint): [{key:XXX, value: XXX, effect:XXX},...]
      taints = []
    }
  ]
}

variable "tags" {
  description = "DO tags to apply to resources"
  type        = list(string)
  default     = []
}
