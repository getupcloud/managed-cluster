terraform {
  required_providers {
    cronitor = {
      source  = "nauxliu/cronitor"
      version = "~> 1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1"
    }

    kubernetes = {
      version = "~> 2.3.2"
    }

    opsgenie = {
      source  = "opsgenie/opsgenie"
      version = "~> 0.6"
    }

    random = {
      version = "~> 2"
    }

    shell = {
      source  = "scottwinkler/shell"
      version = "~> 1"
    }

    # requires.txt placeholder ## DO NOT REMOVE ##

  }
}
