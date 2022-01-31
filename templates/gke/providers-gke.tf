provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = var.service_account_key
}

provider "kubectl" {
  config_path       = var.kubeconfig_filename
  apply_retry_count = 2
}
