provider "aws" {
  region     = var.region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

provider "kubectl" {
  config_path       = var.kubeconfig_filename
  apply_retry_count = 2
}
