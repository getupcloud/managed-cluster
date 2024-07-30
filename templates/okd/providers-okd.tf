provider "kubernetes" {
  config_path = local.kubeconfig_filename
}

provider "kubectl" {
  load_config_file  = true
  config_path       = local.kubeconfig_filename
  apply_retry_count = 2
}
