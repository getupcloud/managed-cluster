terraform {
  required_providers {
    cronitor = {
      source  = "nauxliu/cronitor"
      version = "~> 1"
    }

    shell = {
      source  = "scottwinkler/shell"
      version = "~> 1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1"
    }

    random = {
      version = "~> 2"
    }

    kubernetes = {
      version = "~> 2.3.2"
    }
  }
}

provider "shell" {
  enable_parallelism = true
  interpreter        = ["/bin/bash", "-c"]
}

provider "kubectl" {
  config_path       = var.kubeconfig_filename
  apply_retry_count = 2
}

provider "kubernetes" {
  config_path = var.kubeconfig_filename
}

provider "cronitor" {
  api_key = var.cronitor_api_key
}

