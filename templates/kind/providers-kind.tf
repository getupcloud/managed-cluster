provider "kubectl" {
  config_path       = var.kubeconfig_filename
  apply_retry_count = 2
}
