provider "cronitor" {
  api_key = var.cronitor_api_key
}

provider "kubernetes" {
  config_path = var.kubeconfig_filename
}

provider "shell" {
  enable_parallelism = true
  interpreter        = ["/bin/bash", "-c"]
}
