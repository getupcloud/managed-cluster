variable "name" {
  description = "Cluster name"
  type        = string
}

variable "description" {
  description = "Cluster description"
  type        = string
}

variable "kubeconfig_filename" {
  description = "Kubeconfig path"
  type        = string
  default     = "~/.kube/config"
}

variable "get_kubeconfig_command" {
  description = "Command to create/update kubeconfig"
  type        = string
  default     = "true"
}

variable "flux_git_repo" {
  description = "GitRepository URL."
  type        = string
  default     = ""
}

variable "flux_wait" {
  description = "Wait for all manifests to apply"
  type        = bool
  default     = true
}

variable "manifests_path" {
  description = "Manifests dir inside GitRepository"
  type        = string
  default     = ""
}

variable "customer_name" {
  description = "Customer name (Informative only)"
  type        = string
}

variable "cronitor_api_key" {
  description = "Cronitor API key. Leave empty to destroy"
  type        = string
  default     = ""
}

variable "cronitor_pagerduty_key" {
  description = "Cronitor PagerDuty key"
  type        = string
  default     = ""
}

variable "manifests_template_vars" {
  description = "Template vars for use by cluster manifests"
  type        = any
  default = {
    alertmanager_pagerduty_key : ""
  }
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "zones" {
  description = "GCP Zones"
  type        = list(string)
}

variable "node_pools" {
  description = "List of maps containing node pools"
  type        = list(map(string))
  default = [ 
    { 
      "name": "default-node-pool" 
    } 
  ]
}

variable "maintenance_exclusions" {
  description = "Description: List of maintenance exclusions. A cluster can have up to three"
  type        = list(object({ name = string, start_time = string, end_time = string }))
}

variable "maintenance_start_time" {
  description = "Time window specified for daily or recurring maintenance operations in RFC3339 format"
  type        = string
}

variable "configure_ip_masq" {
  description = " Enables the installation of ip masquerading, which is usually no longer required when using aliasied IP addresses. IP masquerading uses a kubectl call, so when you have a private cluster, you will need access to the APIs"
  type        = bool
  default     = false
}

variable "default_max_pods_per_node" {
  description = "The maximum number of pods to schedule per node"
  type        = int
  default     = 110
}

variable "kubernetes_version" {
  description = "
    The version of Kubernetes to install 
    Options: https://cloud.google.com/kubernetes-engine/docs/release-notes#current_versions
    Example: 1.20.11-gke.1300
    "
  type        = string
  default     = "latest"
}

variable "release_channel" {
  description = "The release channel of this cluster. Accepted values are `UNSPECIFIED`, `RAPID`, `REGULAR` and `STABLE`."
  type        = string
  default     = "STABLE"
}

variable "remove_default_node_pool" {
  description = "Remove the default node pool"
  type        = bool
  default     = false
}

variable "initial_node_count" {
  description = "The number of nodes to create in this cluster's default node pool."
  type        = int
  default     = 1
}

variable "cluster_autoscaling" {
  description = "Cluster autoscaling configuration"
  type = object({ 
    enabled = bool 
    min_cpu_cores = number 
    max_cpu_cores = number 
    min_memory_gb = number 
    max_memory_gb = number 
    gpu_resources = list(object({ 
      resource_type = string, 
      minimum = number, 
      maximum = number 
    }))
  })
  default = { 
    "enabled": false, 
    "gpu_resources": [], 
    "max_cpu_cores": 0, 
    "max_memory_gb": 0, 
    "min_cpu_cores": 0, 
    "min_memory_gb": 0 
  }
}

variable "grant_registry_access" {
  description = "Grants created cluster-specific service account storage.objectViewer and artifactregistry.reader roles."
  type = bool
  default = false
}