variable "name" {
  description = "Cluster name"
  type        = string
}

variable "flux_git_repo" {
  description = "GitRepository URL"
  type        = string
  default     = ""
}
