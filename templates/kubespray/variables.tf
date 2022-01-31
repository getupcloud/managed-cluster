variable "kubespray_git_ref" {
  description = "Kubespray ref name"
  type        = string
  default     = "remotes/origin/release-2.17"
}

variable "kubespray_dir" {
  description = "Kubespray target dir"
  type        = string
  default     = "/cluster/kubespray"
}

variable "deploy_components" {
  description = "Either to deploy or not kubernetes components. Set to true after kubernetes is up and running."
  type        = bool
  default     = false
}
