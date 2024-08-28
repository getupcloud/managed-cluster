## Provider specific variables

variable "region" {
  description = "Cluster Region"
  type        = string
  default     = "unknown"
}

variable "get_kubeconfig_command" {
  description = "Command to create/update kubeconfig"
  type        = string
  default     = "kind export kubeconfig --name $CLUSTER_NAME"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "kubeadm_config_patches" {
  description = "Patches to apply on each node group"
  type        = any
  default = {
    master : []

    infra : [
      <<-EOT
      kind: JoinConfiguration
      nodeRegistration:
        kubeletExtraArgs:
          node-labels: "role=infra"
    EOT
    ]

    app : [
      <<-EOT
      kind: JoinConfiguration
      nodeRegistration:
        kubeletExtraArgs:
          node-labels: "role=app"
    EOT
    ]
  }
}

variable "http_port" {
  description = "Host port to expose container HTTP ingress port"
  type        = number
  default     = 8080
}

variable "https_port" {
  description = "Host port to expose container HTTPS ingress port"
  type        = number
  default     = 8443
}

variable "ssh_port" {
  description = "Host port to expose container HTTP ingress port"
  type        = number
  default     = 2222
}
