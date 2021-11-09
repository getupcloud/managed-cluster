## Common variables

variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  default     = null
}

variable "aws_secret_access_key" {
  description = "AWS Secret Key"
  type        = string
  default     = null
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "AWS VPC ID. Example: vpc-xxxxxxxxxxxxxxxxx"
  type        = string
}

variable "subnet_ids" {
  description = "AWS VPC subnet IDs. Applies to all node_groups by default. Example: [\"subnet-xxxxxxxxxxxxxxxxx\",\"subnet-yyyyyyyyyyyyyyyyy\"]"
  type        = list(string)
}

variable "node_groups_defaults" {
  description = "AWS EKS default node_groups definition"
  type        = any
  default = {
    instance_types   = []
    desired_capacity = 1
    min_capacity     = 1
    max_capacity     = 1
    disk_size        = 50
    additional_tags  = {}
  }

  validation {
    condition     = length(var.node_groups_defaults.instance_types) > 0
    error_message = "Missing instance_types[]. Ex: [\"m5.xlarge\"]."
  }
}

variable "node_groups" {
  description = "AWS EKS node_groups definition"
  type        = any
  default = {
    "infra" : {
      "min_capacity" : 2,
      "max_capacity" : 2,
      "k8s_labels" : {
        "role" : "infra"
      },
      "taints" : [
        {
          "key" : "dedicated"
          "value" : "infra"
          "effect" : "NO_SCHEDULE"
        }
      ]
    },
    "app" : {
      "min_capacity" : 2,
      "max_capacity" : 4,
      "k8s_labels" : {
        "role" : "app"
      }
    }
  }
}

variable "auth_iam_users" {
  description = "List of IAM users to allow kubernetes access. Example: [\"eks-admin\"]"
  type        = list(string)
}

variable "auth_iam_roles" {
  description = "List of IAM roles to allow kubernetes access."
  type        = list(string)
  default     = ["getupcloud"]
}

variable "tags" {
  description = "AWS tags to apply to resources"
  type        = any
  default     = {}
}
