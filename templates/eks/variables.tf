## Common variables

variable "name" {
  description = "Cluster name"
  type        = string
}

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
    instance_types   = ["m5.xlarge"]
    desired_capacity = 1
    min_capacity     = 1
    max_capacity     = 1
    disk_size        = 50
    additional_tags  = {}
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

variable "flux_git_repo" {
  description = "GitRepository URL"
  type        = string
  default     = ""
}
variable "s3_access_id" {
  description = "s3 Access Key ID for Backups"
  type        = string
  default     = null
}

variable "s3_secret_key" {
  description = "s3 Access Key ID for Backups"
  type        = string
  default     = null
}

variable "s3_buckets" {
  description = "List of Space Buckets (See s3.tf for defaults)"
  type        = any
  default     = []

  # See s3.tf for defaults
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