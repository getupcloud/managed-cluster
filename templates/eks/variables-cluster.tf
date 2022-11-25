## Cluster type specific variables
## Copy to toplevel

variable "eks_pre_create" {
  description = "Scripts to execute before cluster is created."
  type        = list(string)
  default     = []
}

variable "eks_post_create" {
  description = "Scripts to execute after cluster is created."
  type        = list(string)
  default     = ["./eks-post-create.sh"]
}
